#!/usr/bin/python

import re
import sys
import syslog
import time
import urllib
import ConfigParser

import bottle
from mako.lookup import TemplateLookup
import whoosh.index
import whoosh.qparser


CONFIG_FILE = '/etc/world4search.conf'


@bottle.route('/')
def searchform():
    return templates.get_template('index.mako').render(boards=config['boards'])

@bottle.route('/about')
def about():
    return templates.get_template('about.mako').render(you=config['maintainer'])

@bottle.post('/q')
def dispatcher():
    query = bottle.request.forms.query
    board = bottle.request.forms.board
    if not query or not board:
        bottle.redirect('/')
    else:
        bottle.redirect('/q/%s/%s' % (urllib.quote_plus(board),
                                      urllib.quote_plus(query)))

@bottle.route('/q/<board>/<query>')
@bottle.route('/q/<board>/<query>/<page:int>')
def query(board, query, page=1):
    if board not in config['boards']:
        abort(404, 'Invalid board.')

    dt = time.time()

    query = urllib.unquote_plus(query).decode('utf8', 'ignore')
    try:
        ix = whoosh.index.open_dir(config['index'], indexname=board)
        with ix.searcher() as searcher:
            # Parse query
            qparse = whoosh.qparser.QueryParser('body', ix.schema)
            q = qparse.parse(query)

            # Query the index
            results = searcher.search_page(q, page)
            hits = len(results)
            results = map(dict, results)
    except:
        results = []
        hits = 0

    dt = time.time() - dt

    syslog.syslog(syslog.LOG_INFO,
                  'Query for "%s" on %s satisfied in %.2f seconds.' % \
                  (query, board, dt)) 

    return templates.get_template('results.mako').render(
        boards=config['boards'],
        board=board, query=query, page=page,
        results=results, hits=hits, time=dt
    )
                                                        
@bottle.route('/favicon.ico')
@bottle.route('/static/<filename>')
def static(filename='favicon.ico'):
    return bottle.static_file(filename, root=config['static'])

def read_config():
    config = {}
    cfg = ConfigParser.ConfigParser()

    try:
        with open(CONFIG_FILE) as cfgf:
            cfg.readfp(cfgf)
        config['boards'] = dict(cfg.items('boards'))
        config['maintainer'] = dict(cfg.items('maintainer'))
        config['templates'] = cfg.get('web', 'templates')
        config['static'] = cfg.get('web', 'static')
        config['cache'] = cfg.get('web', 'cache')
        config['index'] = cfg.get('global', 'index')
    except IOError:
        syslog.syslog(syslog.LOG_ERR,
                      "Couldn't open configuration file. Aborted.")
        sys.exit(1)
    except ConfigParser.Error:
        syslog.syslog(syslog.LOG_ERR,
                      "Couldn't parse configuration file. Aborted.")
        sys.exit(1)

    return config


syslog.openlog('[world4search] web',
               syslog.LOG_PERROR if sys.stderr.isatty() else 0)
config = read_config()
templates = TemplateLookup(directories=[config['templates']],
                           module_directory=config['cache'])
application = bottle.app()

if __name__ == '__main__':
    bottle.run(host='localhost', port=8080, debug=True)
