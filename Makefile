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
HTML_FILES := $(patsubst %.md, $(OUT_DIR)/%.html, $(SRC))

.PHONY: prereqs

all: prereqs $(HTML_FILES)

prereqs: $(OUT_DIR) $(OUT_DIR)/style.css

$(OUT_DIR):
	mkdir $(OUT_DIR)

$(OUT_DIR)/style.css: $(OUT_DIR)
	echo "/* Style for Makefile static generator */" > $@
	echo "body {" >> $@
	echo "}" >> $@

$(OUT_DIR)/%.html: %.md
	cat $< > $@
