<%!
    from time import strftime, gmtime
%>
<!DOCTYPE html>
<html class="${board}">
<head>
<title>world4search</title>
<link rel="stylesheet" href="/static/styles.css" type="text/css" />
</head>
<body>
<div id="header">
    <form method="post" action="/q">
        <a href="/"><img src="/static/logo_small.png" id="logo" alt="world4search" title="world4search" /></a>
        <input type="text" name="query" value="${query | h}" />
        <select name="board">
% for b in sorted(boards):
            <option value="${b}"${' selected' if b == board else ''}>
                /${b}/ &#8211; ${boards[b]}
            </option>
% endfor
        </select>
        <input type="submit" value="search" />
    </form>
</div>

<div id="results">
    <p id="stats">
    % if hits > 0:
        Showing ${(page - 1) * 10 + 1} to ${(page - 1) * 10 + len(results)} of ${hits} result${'s' if hits != 1 else ''}
    % else:
        No results.
    % endif
        (${'%.2f' % time} seconds)
    </p>

% for result in results:
    <div class="result">
        <a href="${result['url']}" class="title">${result['subject']}</a>
        <div>
            <a href="${result['url']}/${result['post']}" class="postnum">${result['post']}</a>
            Name: <span class="author">${result['author']}</span> :
            <span class="date">${strftime("%Y-%m-%d %H:%M %Z", gmtime(result['time']))}</span>
            <div class="body${' aa' if board == 'sjis' else ''}">
                ${result['html']}
            </div>
        </div>
    </div>
% endfor

% if len(results) == 0:
    <div class="noresults">
        <h3>No posts found.</h3>
        <p>Suggestions:</p>
        <ul>
            <li>Make sure all words are spelled correctly.</li>
            <li>Try different keywords.</li>
            <li>Post some original content matching your query.</li>
        </ul>
    </div>
% endif

% if hits > 10:
    <ul id="pagination">
    % if page != 1:
        <li><a href="/q/${board}/${query | u}/${page - 1}" class="arrow">&lt;</a></li>
    % endif
    % for i in range(1, (hits + 9) / 10 + 1):
        % if i != page:
        <li><a href="/q/${board}/${query | u}/${i}">${i}</a></li>
        % else:
        <li><strong>${i}</strong></li>
        % endif
    % endfor
    % if page != i:
        <li><a href="/q/${board}/${query | u}/${page + 1}" class="arrow">&gt;</a></li>
    % endif
    </ul>
% endif
</div>

<div id="footer">
    &#169; 2012, W4S Working Group ::
    <a href="/about">About World4search</a> ::
    <a href="https://github.com/Cairnarvon/world4search">Code on Github</a>
</div>
</body>
</html>
