# What

**world4search** is a search engine for the textboards that historically made up [world4ch](http://www.4chan.org/faq#were) but are now part of [4chan](http://4chan.org/) proper.

# Why

Several scrapers already existed for Shiichan in general and world4ch specifically ([/prog/scrape](https://github.com/Cairnarvon/progscrape) being the first and most popular), but they tend to dump a board's content into a local SQL-style database, which is difficult to query and less than convenient for the casual discussionist. A search engine has a lower entrance barrier and doesn't require that everyone maintain their own index.

# How

If all you want is to use the search engine, you'll find a running copy [here](http://world4search.no-ip.org:8080).

If you want to deploy your own search engine, here's more or less what you do:

* Clone the repository.

```
$ git clone git://github.com/Cairnarvon/world4search.git
```

* Install the dependencies.

```
$ pip install requests whoosh bottle mako
```

* Edit `world4search.conf` and move it to `/etc/world4search.conf`.

* Run the spider once for every board you want to index.

```
$ spider/spider.py sjis
[world4search] spider: created new index sjis in /var/www/index.
[world4search] spider: 13689 posts indexed from sjis.
$ spider/spider.py book
[world4search] spider: created new index book in /var/www/index.
[world4search] spider: 24699 posts indexed from book.
```

* Set up cron jobs to run the spider automatically.

```
$ vim spider/crontab
$ crontab < spider/crontab
```

* Deploy the web service somehow.

```
$ uwsgi --http :80 --wsgi-file web/world4search.py
```

* Periodically check logs to ensure good functioning, probably in `/var/log/user.log` (depending on your syslogd).

Two things to consider:

1. The spider uses world4ch's JSON interface, so it can't be used to index arbitrary Shiichan boards. You know, if those exist.

2. If proper deployment is too much of a pain, you can also just run the web service script normally, in which case it will start its own server on localhost:8080. Not recommended.

Best of luck. If you have any questions or suggestions, feel free to contact me.
