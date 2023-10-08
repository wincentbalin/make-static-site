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
	-e '    s/(^|\n)( *)\&gt\; *([^\n]+)/\1\2<p>\3<\/p>/g' \
	-e '    s/(^|\n)<p>[^\n]+<\/p>(\n *<p>[^\n]+<\/p>)*/\1<blockquote>&\n<\/blockquote>/g' \
	-e '    s/(^|\n)( )<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g' \
	-e '    s/(^|\n)( {2})<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g' \
	-e '    s/(^|\n)( {3})<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g' \
	-e '    s/(^|\n)( {4})<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g' \
	-e '    s/(^|\n)( {5,})<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g' \
	-e '}' \
	-e '/\n *<[ou]li>|\n *<p>/{' \
	-e '    s/<(\/?)[ou]li>/<\1li>/g' \
	-e '    s/([^\\])\\\(.)/\1\2/g' \
	-e '    s/^\n+//' \
	-e '    p' \
	-e '    s/.*//' \
	-e '}' \
	-e 'x' \
	-e 's/([^\\])\\\(.)/\1\2/g' \
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
	echo "</body>" >> $@
	echo "</html>" >> $@
