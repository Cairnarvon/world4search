#!/usr/bin/python

import glob
import logging
import os
import platform
import re
import sys
import time
import urllib
import ConfigParser

import bottle
from mako.lookup import TemplateLookup
import uptime
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
    query = bottle.request.forms.query.replace('/', ' ').strip().encode('utf-8')
    board = bottle.request.forms.board.replace('/', ' ').strip().encode('utf-8')
    if not query or not board:
        bottle.redirect('/')
    else:
        bottle.redirect('/q/%s/%s' % (urllib.quote_plus(board),
                                      urllib.quote_plus(query)))

@bottle.route('/q/<board>/<query>')
@bottle.route('/q/<board>/<query>/<page:int>')
def query(board, query, page=1):
    if board not in config['boards']:
        bottle.abort(404, 'Invalid board.')

    dt = time.time()

    query = urllib.unquote_plus(query).decode('utf8', 'ignore')
    try:
        ix = whoosh.index.open_dir(config['index'], board, readonly=True)
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

    logging.info(u'Query for "%s" on %s satisfied in %.2f seconds.',
                 query, board, dt)

    return templates.get_template('results.mako').render(
        boards=config['boards'],
        board=board, query=query, page=page,
        results=results, hits=hits, time=dt
    )

@bottle.route('/status')
def status():
    boards, totalsize = {}, 0

    for board in config['boards']:
        # Index size on disk
        size = 0
        for f in glob.glob(os.path.join(config['index'], '%s_*' % board)):
            st = os.stat(f)
            size += st.st_size

        # Other information
        try:
            ix = whoosh.index.open_dir(config['index'], board, readonly=True)
            num = ix.doc_count()
            updated = ix.last_modified()
            ix.close()
        except whoosh.index.EmptyIndexError:
            num = 0
            updated = None

        totalsize += size
        boards[board] = {'size': size, 'num': num, 'updated': updated}

    # Misc. information
    try:
        statvfs = os.statvfs(config['index'])
        freesize = statvfs.f_bavail * statvfs.f_bsize
    except AttributeError:
        freesize = None
    uname = platform.uname()
    os_details = {
        'Linux': ('%s %s' % platform.linux_distribution()[:2]).capitalize(),
        'FreeBSD': uname[2],
        'Darwin': platform.mac_ver()[0],
        'Windows': '%s %s' % platform.win32_ver()[0::2],
    }.get(platform.system(), 'Unknown version')

    return templates.get_template('status.mako').render(
        uname=uname, os_details=os_details, uptime=uptime.uptime(),
        totalsize=totalsize, freesize=freesize,
        boards=boards
    )

@bottle.route('/status/<board>.subject.txt')
def subjectdottxt(board):
    if board in config['boards']:
        return bottle.static_file('%s.subject.txt' % board,
                                  root=config['index'])
    else:
        bottle.abort(404, 'Invalid board')

@bottle.route('/robots.txt')
@bottle.route('/favicon.ico')
@bottle.route('/static/<filename>')
def static(filename=None):
    if filename is None:
        filename = bottle.request.path.lstrip('/')
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
        config['logfile'] = cfg.get('global', 'logfile')
    except IOError:
        print >>sys.stderr, "Couldn't open configuration file. Aborted."
        sys.exit(1)
    except ConfigParser.Error:
        print >>sys.stderr, "Couldn't parse configuration file. Aborted."
        sys.exit(1)

    return config

config = read_config()
logging.basicConfig(
    filename=config['logfile'], level=logging.INFO,
    format="%(asctime)s [web]    %(levelname)-8s %(message)s"
)
templates = TemplateLookup(directories=[config['templates']],
                           module_directory=config['cache'])
application = bottle.app()

if __name__ == '__main__':
    bottle.run(host='localhost', port=8080, debug=True)
