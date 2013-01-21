<%!
import locale
from time import time, strftime, gmtime

def human_size(sz):
    if sz < 1024:
        return '%d bytes' % sz
    sz /= 1024.
    for s in 'KiB', 'MiB', 'GiB':
        if sz < 1024:
            return '%.2f %s' % (sz, s)
        sz /= 1024.
    return '%.2f TiB' % (sz, s)

def human_time(t):
    if t < 60:
        return '%d second%s' % (t, 's' if t != 1 else '')
    t = round(t / 60.)
    if t < 60:
        return '%d minute%s' % (t, 's' if t != 1 else '')
    t = round(t / 60.)
    if t < 24:
        return '%d hour%s' % (t, 's' if t != 1 else '')
    t = round(t / 24.)
    return '%d day%s' % (t, 's' if t != 1 else '')

def human_duration(t):
    d = []

    days, t = t // 86400, t % 86400
    if days:
        d.append('%d day%s' % (days, 's' if days != 1 else ''))

    hours, t = t // 3600, t % 3600
    if hours:
        d.append('%d hour%s' % (hours, 's' if hours != 1 else ''))

    minutes, t = t // 60, t % 60
    if minutes:
        d.append('%d minute%s' % (minutes, 's' if minutes != 1 else ''))

    if t or not d:
        d.append('%.2f second%s' % (t, 's' if t != 1 else ''))

    return ', '.join(d)

locale.setlocale(locale.LC_ALL, '')
%>
<!DOCTYPE html>
<html>
<head>
    <title>world4search</title>
    <link rel="stylesheet" href="/static/styles.css" type="text/css" />
</head>
<body class="status">
<a href="/"><img src="/static/logo.png" id="biglogo" alt="world4search" title="world4search" /></a>
<h1>Server</h1>
<table class="server">
<tr>
    <td class="key">Hostname:</td>
    <td>${uname[1]}</td>
</tr>
<tr>
    <td class="key">Operating System:</td>
    <td>${uname[0]} ${uname[4]} (${os_details})</td>
</tr>
<tr>
    <td class="key">Local Time:</td>
    <td>${strftime('%Y-%m-%d %H:%M %Z', gmtime())}</td>
</tr>
% if uptime is not None:
<tr>
    <td class="key">Uptime:</td>
    <td>${human_duration(uptime)}</td>
</tr>
% endif
</table>

<h1>Index</h1>
<p><strong>Total Index Size:</strong> ${human_size(totalsize)}
% if freesize is not None:
(${human_size(freesize)} free)
% endif
</p>
<table class="stats">
    <tr>
        <th>Board</th>
        <th>Index Size</th>
        <th># of Posts</th>
        <th>Last Updated</th>
        <th>
    <tr>
% for board in sorted(boards):
    <tr>
        <td class="board">/${board}/</td>
        <td>${human_size(boards[board]['size'])}</td>
        <td>${locale.format('%d', boards[board]['num'], grouping=True)}</td>
        <td>
            <span title="${strftime('%Y-%m-%d %H:%M %Z', gmtime(boards[board]['updated']))}">
                ${human_time(int(time() - boards[board]['updated']))} ago
            </span>
        </td>
        <td><a href="/status/${board}.subject.txt">subject.txt</a></td>
    </tr>
% endfor
</table>
<div id="footer">
    &#169; 2012, W4S Working Group ::
    <a href="/about">About World4search</a> ::
    <strong>Status</strong> ::
    <a href="https://github.com/Cairnarvon/world4search">Code on Github</a>
</div>
</body>
</html>
