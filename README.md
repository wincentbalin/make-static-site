# Make static site

This is a static site generator in a single `Makefile`, using `make` and `sed` on Markdown files, and `cp` on image files.

# Usage

There are several useful scenarios, listed below. You can combine them if needed.

## Create a site

Put the `Makefile` into the directory with Markdown and image files and simply run

```
make
```

The results are in the directory `out`.

## Create a site in the specified directory

Do as above, but with the command

```
make OUT_DIR=../website
```

The results are in the directory `../website`.

## Create a site with changed title and/or introduction text

Do as above, but with the command

```
make TITLE="A beautiful website" INTRO="On this beautiful website you will find:"
```

Omit parameter `TITLE` or `INTRO`, if you do not intend to change the respective contents.

## Create a site with a RSS feed

Do as above, but with the command

```
make BUILD_FEED_WITH_URL=http://xyz.xyz/
```

Change the parameter `BUILD_FEED_WITH_URL` to the approprate URL. _Do not_ forget the trailing slash, or the feed URL will fail!

# Requirements

* (GNU) Make
* (GNU) sed
* cp

# Known problems

* Does not work in Windows, neither in CMD nor in Powershell
* GNU Make does not handle spaces in file names: http://savannah.gnu.org/bugs/?712
* CSS file `style.css` is recreated on the second run even if unchanged

# License

[MIT](LICENSE)

# Acknowledgement

This project is based on this Markdown-to-HTML converter in `sed`: https://github.com/stamby/md-to-html/
