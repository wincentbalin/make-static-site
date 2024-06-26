#
# This is make-static-site, a static site generator in a single Makefile, using make and sed on Markdown files.
#

ifndef OUT_DIR
OUT_DIR = out
endif
ifndef TITLE
TITLE = A page
endif
ifndef INTRO
INTRO = These are the pages listed:
endif
MD_FILES := $(wildcard *.md)
HTML_FILES := $(patsubst %.md, $(OUT_DIR)/%.html, $(MD_FILES))
IMAGE_FILES := $(wildcard *.jpg *.jpeg *.png *.gif *.webp)
MEDIA_FILES := $(patsubst %, $(OUT_DIR)/%, $(IMAGE_FILES))
INDEX_INC_FILES := $(patsubst %.md, $(OUT_DIR)/%.inc, $(MD_FILES))

.PHONY: prereqs postreqs
.INTERMEDIATE: $(INDEX_INC_FILES)

all: prereqs $(HTML_FILES) $(MEDIA_FILES) postreqs

prereqs: $(OUT_DIR)/style.css

ifdef BUILD_FEED_WITH_URL
postreqs: $(OUT_DIR)/index.html $(OUT_DIR)/feed.xml
else
postreqs: $(OUT_DIR)/index.html
endif

$(OUT_DIR):
	mkdir $(OUT_DIR)

$(OUT_DIR)/style.css: $(OUT_DIR)
	echo '/* Style for Makefile static generator, mostly from https://jblevins.org/ */' > $@
	echo 'body {' >> $@
	echo '    margin: 0 auto;' >> $@
	echo '    max-width: 60rem;' >> $@
	echo '    font-family: "Minion Pro Caption", minion-pro-caption, "Minion Pro", "Garamond Premier Pro Caption", "Garamond Premier Pro", "Hoefler Text", Constantia, Garamond, Palatino, "Palatino Linotype", Baskerville, "Book Antiqua", Georgia, "Century Schoolbook L", serif;' >> $@
	echo '    color: #333232' >> $@
	echo '}' >> $@
	echo '' >> $@
	echo 'h1, h2, h3, h4, h5, h6 {' >> $@
	echo '    font-family: "Garamond Premier Pro", garamond-premier-pro, "Adobe Caslon Pro", "Minion Pro", Constantia, serif;' >> $@
	echo '    font-weight: normal;' >> $@
	echo '    font-style: normal;' >> $@
	echo '    color: #111' >> $@
	echo '}' >> $@
	echo '' >> $@
	echo 'p {' >> $@
	echo '    margin-top: 0;' >> $@
	echo '    margin-bottom: 1.5rem;' >> $@
	echo '    text-align: justify;' >> $@
	echo '    hyphens: auto' >> $@
	echo '}' >> $@
	echo '' >> $@
	echo 'img {' >> $@
	echo '    max-width: 100%' >> $@
	echo '}' >> $@
	echo '' >> $@
	echo 'blockquote {' >> $@
	echo '    margin: 0 0 1.5rem;' >> $@
	echo '    border-left: 0.4rem solid #C4BCB3;' >> $@
	echo '    padding: 0 0 0 1.1rem' >> $@
	echo '}' >> $@
	echo '' >> $@
	echo 'ul, ol {' >> $@
	echo '    padding-left: 1.8rem;' >> $@
	echo '    margin-bottom: 1.5rem' >> $@
	echo '}' >> $@
	echo '' >> $@
	echo 'li {' >> $@
	echo '    line-height: 1.5rem' >> $@
	echo '}' >> $@
	echo '' >> $@
	echo 'code, pre {' >> $@
	echo '    font-family: Inconsolata, inconsolata, "Source Code Pro", Terminus, Consolas, "Liberation Mono", "Bitstream Vera Sans Mono", "Andale Mono WT", "Andale Mono", Monaco, "Lucida Console", "Lucida Sans Typewriter", "Nimbus Mono L", "Courier New", Courier, monospace' >> $@
	echo '}' >> $@
	echo '' >> $@
	echo 'pre {' >> $@
	echo '    border: 1px solid #C4BCB3;' >> $@
	echo '    margin: 0 0 1.5rem 0;' >> $@
	echo '    padding: 0.6875rem;' >> $@
	echo '    background-color: #f1efec;' >> $@
	echo '    white-space: pre;' >> $@
	echo '    overflow-x: auto;' >> $@
	echo '    border-radius: 0.5rem' >> $@
	echo '}' >> $@

$(OUT_DIR)/%.html: %.md  # Mostly from https://github.com/stamby/md-to-html/
	echo '<!DOCTYPE html>' > $@
	echo '<html>' >> $@
	echo '<head>' >> $@
	echo '<meta charset="utf-8">' >> $@
	echo '<meta name="viewport" content="width=device-width, initial-scale=1.0">' >> $@
	echo '<link rel="stylesheet" href="style.css">' >> $@
	echo '<title>' >> $@
	sed -n -e '/^#/ {s/^#\s*//p;q}' $< >> $@
	echo '</title>' >> $@
	echo '</head>' >> $@
	echo '<body>' >> $@
	sed -E \
	-e 's/\t/  /g' \
	-e 's/^ +$$//' \
	-e 's/(>=|=>)/\&ge\;/g' \
	-e 's/(<=|=<)/\&le\;/g' \
	-e 's/\&/\&amp\;/g' \
	-e 's/"/\&quot\;/g' \
	-e "s/'/\&apos\;/g" \
	-e 's/>/\&gt\;/g' \
	-e 's/</\&lt\;/g' \
	-e 's/([^\\]):[a-zA-Z0-9]+:/\1\&#x2B50\;/g' \
	-e 's/\\\&ge\;/=>/g' \
	-e 's/\\\&le\;/<=/g' \
	-e 's/\\\&amp\;/\&/g' \
	-e 's/\\\&quot\;/"/g' \
	-e "s/\\\&apos\;/'/g" \
	-e 's/\\\&gt\;/>/g' \
	-e 's/\\\&lt\;/</g' \
	-e '/^ *```/{' \
	-e '    x' \
	-e '    /^ *```/!{' \
	-e '        N' \
	-e '        s/.*\n/\n\\\\<pre\\\\>\\\\<code\\\\>/' \
	-e '        D' \
	-e '    }' \
	-e '    s/.*//' \
	-e '    x' \
	-e '    s/.*/<\/code><\/pre>/' \
	-e '    b' \
	-e '}' \
	-e 'x' \
	-e '/^ *```/{' \
	-e '    x' \
	-e '    b' \
	-e '}' \
	-e 'x' \
	-e 's/(^| )\&lt\; *([^ ]*[:\/][^ ]*) *\&gt\;( |$$)/\1<a href="\2">\2<\/a>\3/g' \
	-e 's/(^| )\&lt\; *([^ ]*@[^ ]+) *\&gt\;( |$$)/\1<a href="mailto:\2">\2<\/a>\3/g' \
	-e 's/\[!\[ *([[:alnum:] \&\;\?!,\)\+]*.{0,10}[[:alnum:] \&\;\?!,\)\+]+) *\] *\( *([^ ]+) *\) *] *\( *([^ ]+) *\)/<a href="\3"><img src="\2" alt="\1"><\/a>/g' \
	-e 's/!\[ *([[:alnum:] \&\;\?!,\)\+]*.{0,10}[[:alnum:] \&\;\?!,\)\+]) *\] *\( *([^ ]+) *\)/<img src="\2" alt="\1">/g' \
	-e 's/\[ *([[:alnum:] \&\;\?!,\)\+]*.{0,10}[[:alnum:] \&\;\?!,\)\+-]) *\] *\( *([^ ]+) *"([^"]+)"\)/<a href="\2" title="\3">\1<\/a>/g' \
	-e 's/\[ *([[:alnum:] \&\;\?!,\)\+]*.{0,10}[[:alnum:] \&\;\?!,\)\+]+) *\] *\( *([^ ]+) *\)/<a href="\2">\1<\/a>/g' \
	-e 's/(^|[^\\\*])\*{3}([^\*]+)\*{3}([^\*]|$$)/\1<strong><em>\2<\/em><\/strong>\3/g' \
	-e 's/(^|[^\\_])_{3}([^_]+)_{3}([^_]|$$)/\1<strong><em>\2<\/em><\/strong>\3/g' \
	-e 's/(^|[^\\\*])\*{2}([^\*]+)\*{2}([^\*]|$$)/\1<strong>\2<\/strong>\3/g' \
	-e 's/(^|[^\\_])_{2}([^\_]+)_{2}([^_]|$$)/\1<strong>\2<\/strong>\3/g' \
	-e 's/(^|[^\\\*])\*([^\*]+)\*([^\*]|$$)/\1<em>\2<\/em>\3/g' \
	-e 's/(^|[^\\_])_([^_]+)_([^_]|$$)/\1<em>\2<\/em>\3/g' \
	-e 's/(^|[^\\~])~~([^~]+)~~([^~]|$$)/\1<del>\2<\/del>\3/g' \
	-e 's/(^|[^\\~])~([^~]+)~([^~]|$$)/\1<s>\2<\/s>\3/g' \
	-e 's/(^|[^\\`])`([^`]+)`([^`]|$$)/\1<code>\2<\/code>\3/g' \
	-e '/^ *[0-9]+ *[\.-]|^ *[\*\+-] *[^\*\+-]|^ *\&gt\;/{' \
	-e '    H' \
	-e '    $$!d' \
	-e '}' \
	-e 'x' \
	-e '/(^|\n) *[0-9]+ *[\.-]/{' \
	-e '    s/(^|\n)( *)[0-9]+ *[\.-] *([^\n]+)/\1\2<oli>\3<\/oli>/g' \
	-e '    s/(^|\n)<oli>[^\n]+<\/oli>(\n *<oli>[^\n]+<\/oli>)*/\1<ol>&\n<\/ol>/g' \
	-e '    s/(^|\n)( )<oli>[^\n]+<\/oli>(\n\2 *<oli>[^\n]+<\/oli>)*/\1\2<ol>&\n\2<\/ol>/g' \
	-e '    s/(^|\n)( {2})<oli>[^\n]+<\/oli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ol>&\n\2<\/ol>/g' \
	-e '    s/(^|\n)( {3})<oli>[^\n]+<\/oli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ol>&\n\2<\/ol>/g' \
	-e '    s/(^|\n)( {4})<oli>[^\n]+<\/oli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ol>&\n\2<\/ol>/g' \
	-e '    s/(^|\n)( {5,})<oli>[^\n]+<\/oli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ol>&\n\2<\/ol>/g' \
	-e '}' \
	-e '/(^|\n) *[\*\+-]/{' \
	-e '    s/(^|\n)( *)[\*\+-] *([^\n]+)/\1\2<uli>\3<\/uli>/g' \
	-e '    s/(^|\n)<uli>[^\n]+<\/uli>(\n *<uli>[^\n]+<\/uli>)*/\1<ul>&\n<\/ul>/g' \
	-e '    s/(^|\n)( )<uli>[^\n]+<\/uli>(\n\2 *<uli>[^\n]+<\/uli>)*/\1\2<ul>&\n\2<\/ul>/g' \
	-e '    s/(^|\n)( {2})<uli>[^\n]+<\/uli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ul>&\n\2<\/ul>/g' \
	-e '    s/(^|\n)( {3})<uli>[^\n]+<\/uli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ul>&\n\2<\/ul>/g' \
	-e '    s/(^|\n)( {4})<uli>[^\n]+<\/uli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ul>&\n\2<\/ul>/g' \
	-e '    s/(^|\n)( {5,})<uli>[^\n]+<\/uli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ul>&\n\2<\/ul>/g' \
	-e '}' \
	-e '/(^|\n) *\&gt\;/{' \
	-e '    :b' \
	-e '    /(^|\n) *\&gt\; */{' \
	-e '        s/(^|\n)( *)\&gt\;/\1 /g' \
	-e '        tb' \
	-e '    }' \
	-e '    s/(^|\n) *([^\n]+)/\1<p>\2<\/p>/g' \
	-e '    s/(^|\n)<p>[^\n]+<\/p>(\n *<p>[^\n]+<\/p>)*/\1<blockquote>&\n<\/blockquote>/g' \
	-e '}' \
	-e '/\n *<[ou]li>|\n *<p>/{' \
	-e '    s/<(\/?)[ou]li>/<\1li>/g' \
	-e '    s/([^\\])\\\\(.)/\1\2/g' \
	-e '    s/^\n+//' \
	-e '    p' \
	-e '    s/.*//' \
	-e '}' \
	-e 'x' \
	-e 's/([^\\])\\\\(.)/\1\2/g' \
	-e '/^ *[^#]/{' \
	-e '    $${' \
	-e '        /^ *[0-9]+ *[\.-]|^ *[\*\+-] *[^\*\+-]|^ *\&gt\;/d' \
	-e '        /<\/pp>$$/{' \
	-e '            s/<\/pp>$$/<\/p>/' \
	-e '            b' \
	-e '        }' \
	-e '        s/.*/<p>&<\/p>/' \
	-e '        b' \
	-e '    }' \
	-e '    N' \
	-e '    /\n *[=-]+ *$$/{' \
	-e '        s/^ *(.*)\n *=+ */# \1/' \
	-e '        s/^ *(.*)\n *-+ */## \1/' \
	-e '    }' \
	-e '    /^ *#/!{' \
	-e '        /\n *[0-9]+ *[\.-]|\n *[\*\+-]|\n *>|\n *#|\n *$$/{' \
	-e '            /<\/pp>\n/{' \
	-e '                s/ *<\/pp>\n/<\/p>\n/' \
	-e '                P' \
	-e '                D' \
	-e '            }' \
	-e '            s/^ *([^\n]+)/<p>\1<\/p>/' \
	-e '            P' \
	-e '            D' \
	-e '        }' \
	-e '        /<\/pp>\n/{' \
	-e '            s/ *<\/pp>\n/\n/' \
	-e '            s/$$/\\<\/pp\\>/' \
	-e '            P' \
	-e '            D' \
	-e '        }' \
	-e '        s/.*/<p>&\\<\/pp\\>/' \
	-e '        P' \
	-e '        D' \
	-e '    }' \
	-e '}' \
	-e 's/^ *(#+) *(.*[^# ])[# ]*$$/\1 \2/' \
	-e 'h' \
	-e 'x' \
	-e 's/^[# ]+ (.*[^#])[# ]*$$/\L\1/' \
	-e 's/[^[:alnum:]]+/-/g' \
	-e 's/^-+|-+$$//g' \
	-e 'H' \
	-e 's/.*//' \
	-e 'x' \
	-e 's/^#{6} (.*)\n(.*)$$/<h6 id="\2">\1<\/h6>/' \
	-e 's/^#{5} (.*)\n(.*)$$/<h5 id="\2">\1<\/h5>/' \
	-e 's/^#{4} (.*)\n(.*)$$/<h4 id="\2">\1<\/h4>/' \
	-e 's/^#{3} (.*)\n(.*)$$/<h3 id="\2">\1<\/h3>/' \
	-e 's/^#{2} (.*)\n(.*)$$/<h2 id="\2">\1<\/h2>/' \
	-e 's/^# (.*)\n(.*)$$/<h1 id="\2">\1<\/h1>/' \
	-e 's/\n//g' $< >> $@
	echo '</body>' >> $@
	echo '</html>' >> $@

$(OUT_DIR)/%.inc: %.md
	sed -E -n -e '/^#/ {s/^#\s*(.*)$$/<p><a href="$(patsubst %.md,%.html,$<)">\1<\/a><\/p>/p;q}' $< > $@

$(OUT_DIR)/index.html: $(INDEX_INC_FILES)
	echo '<!DOCTYPE html>' > $@
	echo '<html>' >> $@
	echo '<head>' >> $@
	echo '<meta charset="utf-8">' >> $@
	echo '<meta name="viewport" content="width=device-width, initial-scale=1.0">' >> $@
	echo '<link rel="stylesheet" href="style.css">' >> $@
	echo '<title>$(TITLE)</title>' >> $@
	echo '</head>' >> $@
	echo '<body>' >> $@
	echo '<h1>$(TITLE)</h1>' >> $@
	echo '<p>$(INTRO)</p>' >> $@
	sed -n 'p' $^ >> $@
	echo '</body>' >> $@
	echo '</html>' >> $@

$(OUT_DIR)/feed.xml: $(OUT_DIR)/index.html
	echo '<?xml version="1.0" encoding="utf-8"?>' > $@
	echo '<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">' >> $@
	echo '<channel>' >> $@
	echo '<title>$(TITLE)</title>' >> $@
	echo '<link>$(BUILD_FEED_WITH_URL)</link>' >> $@
	echo '<atom:link href="$(BUILD_FEED_WITH_URL)$(notdir $@)" rel="self" type="application/rss+xml"/>' >> $@
	echo '<description>$(INTRO)</description>' >> $@
	sed -E -n -e '/^<p><a.+<\/a><\/p>$$/ {s/^<p><a href="(.+)">(.+)<\/a><\/p>$$/<item>\n<title>\2<\/title>\n<link>$(subst /,\/,$(BUILD_FEED_WITH_URL))\1<\/link>\n<\/item>/p}' $< >> $@
	echo '</channel>' >> $@
	echo '</rss>' >> $@
	sed -i -e '/<\/title>/a\' -e '<link rel="alternate" type="application/rss+xml" title="RSS" href="$(notdir $@)">' $<

$(OUT_DIR)/%: %
	cp $< $@
