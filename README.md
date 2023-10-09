# Make static site

This is a static site generator in a single `Makefile`, using `make` and `sed` on Markdown files.

# Usage

...

# Requirements

* (GNU) Make
* (GNU) sed

# Known problems

* Does not work in Windows, neither in CMD nor in Powershell
* GNU Make does not handle spaces in file names: http://savannah.gnu.org/bugs/?712
* CSS file `style.css` is recreated on the second run even if unchanged

# License

[MIT](LICENSE)

# Acknowledgement

This project is based on this Markdown-to-HTML converter in `sed`: https://github.com/stamby/md-to-html/
