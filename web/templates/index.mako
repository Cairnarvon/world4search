<!DOCTYPE html>
<html>
<head>
    <title>world4search</title>
    <link rel="stylesheet" href="/static/styles.css" type="text/css" />
</head>
<body class="main">
<img src="/static/logo.png" id="biglogo" alt="world4search" title="world4search" />
<form method="post" action="/q">
    <input type="text" name="query" autofocus />
    <select name="board">
% for board in sorted(boards):
        <option value="${board}"${' selected' if board == 'prog' else ''}>
            /${board}/ &#8211; ${boards[board] | h}
        </option>
% endfor
    </select>
    <input type="submit" value="search" />
</form>
<div id="footer">
    &#169; 2012, W4S Working Group ::
    <a href="/about">About World4search</a> ::
    <a href="https://github.com/Cairnarvon/world4search">Code on Github</a>
</div>
</div>
</body>
</html>
