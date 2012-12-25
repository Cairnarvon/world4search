<!DOCTYPE html>
<html>
<head>
    <title>world4search :: About</title>
    <link rel="stylesheet" href="/static/styles.css" type="text/css" />
</head>
<body class="about">

<a href="/"><img src="/static/logo.png" alt="world4search" /></a>

<h1>What</h1>
<p>
    <em>world4search</em> is a search service for the textboards that
    historically made up <a href="http://www.4chan.org/faq#were">world4ch</a>
    but are now part of <a href="http://4chan.org">4chan</a> proper.
</p>

<h1>Why</h1>
<p>
    Several scrapers already existed for Shiichan in general and world4ch
    specifically
    (<a href="https://github.com/Cairnarvon/progscrape">/prog/scrape</a> being 
    the first and most popular), but they tend to dump a board's content into a
    local SQL-style database, which is difficult to query and less than
    convenient for the casual discussionist. A search engine has a lower
    entrance barrier and doesn't require that everyone maintain their own index.
</p>

<h1>Who</h1>
<p>
    <em>world4search</em> was written by <b>Xarn</b> and is maintained by the
    community. The code is available on
    <a href="https://github.com/Cairnarvon/world4search">Github</a> under the
    GNU GPL license.
</p>
<p>
    This instance is maintained by

    % if 'url' in you:
        <a href="${you['url']}">${you['name']}</a>.
    % else:
        ${you['name']}.
    %endif

    Please direct inquiries to
    <a href="mailto:${you['email']}">${you['email']}</a>.
</p>

<div id="footer">
    &#169; 2012, W4S Working Group ::
    <strong>About World4search</strong> ::
    <a href="https://github.com/Cairnarvon/world4search">Code on Github</a>
</div>

</body>
</html>
