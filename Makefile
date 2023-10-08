#
# This is make-static-site, a static site generator in a single Makefile, using make and sed on Markdown files.
#

# TODO
# * Create list of target files and perform translation
# * Translation rule from .md to .html
# * Copy multimedia files as in previous point
# * Create index HTML file
# * Create RSS feed
# * Create help message for this Makefile

ifndef OUT_DIR
OUT_DIR = out
endif
MD_FILES := $(wildcard *.md)
HTML_FILES := $(patsubst %.md, $(OUT_DIR)/%.html, $(MD_FILES))

.PHONY: prereqs

all: prereqs $(HTML_FILES)

prereqs: $(OUT_DIR) $(OUT_DIR)/style.css

$(OUT_DIR):
	mkdir $(OUT_DIR)

$(OUT_DIR)/style.css: $(OUT_DIR)
	echo "/* Style for Makefile static generator */" > $@
	echo "body {" >> $@
	echo "}" >> $@

$(OUT_DIR)/%.html: %.md  # Mostly from https://github.com/stamby/md-to-html/
	echo "<!DOCTYPE html>" > $@
	echo "<html>" >> $@
	echo "<head>" >> $@
	echo "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" >> $@
	echo "<link rel=\"stylesheet\" href=\"style.css\">" >> $@
	echo "<title>" >> $@
	sed -n -e '/^#/ {s/^#\s*//p;q}' $< >> $@
	echo "</title>" >> $@
	echo "</head>" >> $@
	echo "<body>" >> $@
	sed -E -e 's/\t/  /g' $< | \
	sed -E -e 's/^ +\$$//' | \
	sed -E -e 's/(>=|=>)/\&ge\;/g' | \
	sed -E -e 's/(<=|=<)/\&le\;/g' | \
	sed -E -e 's/\&/\&amp\;/g' | \
	sed -E -e 's/"/\&quot\;/g' | \
	sed -E -e "s/'/\&apos\;/g" | \
	sed -E -e 's/>/\&gt\;/g' | \
	sed -E -e 's/</\&lt\;/g' | \
	sed -E -e 's/([^\\]):[a-zA-Z0-9]+:/\1\&#x2B50\;/g' | \
	sed -E -e 's/\\\&ge\;/=>/g' | \
	sed -E -e 's/\\\&le\;/<=/g' | \
	sed -E -e 's/\\\&amp\;/\&/g' | \
	sed -E -e 's/\\\&quot\;/"/g' | \
	sed -E -e "s/\\\&apos\;/'/g" | \
	sed -E -e 's/\\\&gt\;/>/g' | \
	sed -E -e 's/\\\&lt\;/</g' | \
	sed -E -e '/^ *```/{x;/^ *```/!{N;s/.*\n/\n\\<pre\\>\\<code\\>/;D};s/.*//;x;s/.*/<\/code><\/pre>/;b};' | \
	sed -E -e 'x;/^ *```/{x;b};x' | \
	sed -E -e 's/(^| )\&lt\; *([^ ]*[:\/][^ ]*) *\&gt\;( |$$)/\1<a href="\2">\2<\/a>\3/g' | \
	sed -E -e 's/(^| )\&lt\; *([^ ]*@[^ ]+) *\&gt\;( |$$)/\1<a href="mailto:\2">\2<\/a>\3/g' | \
	sed -E -e 's/\[!\[ *([[:alnum:] \&\;\?!,\)\+]*.{0,10}[[:alnum:] \&\;\?!,\)\+]+) *\] *\( *([^ ]+) *\) *] *\( *([^ ]+) *\)/<a href="\3"><img src="\2" alt="\1"><\/a>/g' | \
	sed -E -e 's/!\[ *([[:alnum:] \&\;\?!,\)\+]*.{0,10}[[:alnum:] \&\;\?!,\)\+]) *\] *\( *([^ ]+) *\)/<img src="\2" alt="\1">/g' | \
	sed -E -e 's/\[ *([[:alnum:] \&\;\?!,\)\+]*.{0,10}[[:alnum:] \&\;\?!,\)\+-]) *\] *\( *([^ ]+) *"([^"]+)"\)/<a href="\2" title="\3">\1<\/a>/g' | \
	sed -E -e 's/\[ *([[:alnum:] \&\;\?!,\)\+]*.{0,10}[[:alnum:] \&\;\?!,\)\+]+) *\] *\( *([^ ]+) *\)/<a href="\2">\1<\/a>/g' | \
	sed -E -e 's/(^|[^\\\*])\*{3}([^\*]+)\*{3}([^\*]|$$)/\1<strong><em>\2<\/em><\/strong>\3/g' | \
	sed -E -e 's/(^|[^\\_])_{3}([^_]+)_{3}([^_]|$$)/\1<strong><em>\2<\/em><\/strong>\3/g' | \
	sed -E -e 's/(^|[^\\\*])\*{2}([^\*]+)\*{2}([^\*]|$$)/\1<strong>\2<\/strong>\3/g' | \
	sed -E -e 's/(^|[^\\_])_{2}([^\_]+)_{2}([^_]|$$)/\1<strong>\2<\/strong>\3/g' | \
	sed -E -e 's/(^|[^\\\*])\*([^\*]+)\*([^\*]|$$)/\1<em>\2<\/em>\3/g' | \
	sed -E -e 's/(^|[^\\_])_([^_]+)_([^_]|$$)/\1<em>\2<\/em>\3/g' | \
	sed -E -e 's/(^|[^\\~])~~([^~]+)~~([^~]|$$)/\1<del>\2<\/del>\3/g' | \
	sed -E -e 's/(^|[^\\~])~([^~]+)~([^~]|$$)/\1<s>\2<\/s>\3/g' | \
	sed -E -e 's/(^|[^\\`])`([^`]+)`([^`]|$$)/\1<code>\2<\/code>\3/g' | \
	sed -E -e '/^ *[0-9]+ *[\.-]|^ *[\*\+-] *[^\*\+-]|^ *\&gt\;/{H;$$!d};x;/(^|\n) *[0-9]+ *[\.-]/{s/(^|\n)( *)[0-9]+ *[\.-] *([^\n]+)/\1\2<oli>\3<\/oli>/g;s/(^|\n)<oli>[^\n]+<\/oli>(\n *<oli>[^\n]+<\/oli>)*/\1<ol>&\n<\/ol>/g;s/(^|\n)( )<oli>[^\n]+<\/oli>(\n\2 *<oli>[^\n]+<\/oli>)*/\1\2<ol>&\n\2<\/ol>/g;s/(^|\n)( {2})<oli>[^\n]+<\/oli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ol>&\n\2<\/ol>/g;s/(^|\n)( {3})<oli>[^\n]+<\/oli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ol>&\n\2<\/ol>/g;s/(^|\n)( {4})<oli>[^\n]+<\/oli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ol>&\n\2<\/ol>/g;s/(^|\n)( {5,})<oli>[^\n]+<\/oli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ol>&\n\2<\/ol>/g}' | \
	sed -E -e '/(^|\n) *[\*\+-]/{s/(^|\n)( *)[\*\+-] *([^\n]+)/\1\2<uli>\3<\/uli>/g;s/(^|\n)<uli>[^\n]+<\/uli>(\n *<uli>[^\n]+<\/uli>)*/\1<ul>&\n<\/ul>/g;s/(^|\n)( )<uli>[^\n]+<\/uli>(\n\2 *<uli>[^\n]+<\/uli>)*/\1\2<ul>&\n\2<\/ul>/g;s/(^|\n)( {2})<uli>[^\n]+<\/uli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ul>&\n\2<\/ul>/g;s/(^|\n)( {3})<uli>[^\n]+<\/uli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ul>&\n\2<\/ul>/g;s/(^|\n)( {4})<uli>[^\n]+<\/uli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ul>&\n\2<\/ul>/g;s/(^|\n)( {5,})<uli>[^\n]+<\/uli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ul>&\n\2<\/ul>/g}' | \
	sed -E -e '/(^|\n) *\&gt\;/{:b;/(^|\n) *\&gt\; */{s/(^|\n)( *)\&gt\;/\1 /g;tb};s/(^|\n)( *)\&gt\; *([^\n]+)/\1\2<p>\3<\/p>/g;s/(^|\n)<p>[^\n]+<\/p>(\n *<p>[^\n]+<\/p>)*/\1<blockquote>&\n<\/blockquote>/g;s/(^|\n)( )<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g;s/(^|\n)( {2})<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g;s/(^|\n)( {3})<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g;s/(^|\n)( {4})<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g;s/(^|\n)( {5,})<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g}' | \
	sed -E -e '/\n *<[ou]li>|\n *<p>/{s/<(\/?)[ou]li>/<\1li>/g}' >> $@
	echo "</body>" >> $@
	echo "</html>" >> $@

