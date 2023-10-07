#
# This is make-static-site, a static site generator in a single Makefile, using make and sed on Markdown files.
#

# TODO
# * Create prerequisitions
# * Translation rule from .md to .html
# * Create list of target files and perform translation
# * Copy multimedia files as in previous point
# * Create index file
# * Create help message for this Makefile

OUT_DIR = out

.PHONY: prereqs

prereqs: $(OUT_DIR) $(OUT_DIR)/style.css

$(OUT_DIR):
	mkdir $(OUT_DIR)

$(OUT_DIR)/style.css: $(OUT_DIR)
	echo "/* Style for Makefile static generator */" > $@
	echo "body {" >> $@
	echo "}" >> $@
