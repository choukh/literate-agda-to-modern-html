#
# Author: Jake Zimmerman <jake@zimmerman.io>
#
# ===== Usage ================================================================
#
# make                  Prepare docs/ folder (all markdown & assets)
# make docs/index.html  Recompile just docs/index.html
#
# make watch            Start a local HTTP server and rebuild on changes
# PORT=4242 make watch  Like above, but use port 4242
#
# make clean            Delete all generated files
#
# ============================================================================

SOURCES := $(shell find src -type f -name '*.lagda.md')
TARGETS := $(patsubst src/%.lagda.md,docs/%.html,$(SOURCES))

.PHONY: all
all: docs/.nojekyll $(TARGETS)

.PHONY: clean
clean:
	rm -rf docs

.PHONY: watch
watch:
	./tools/serve.sh --watch

docs/.nojekyll: $(wildcard public/*) public/.nojekyll
	rm -vrf docs && mkdir -p docs && cp -vr public/.nojekyll public/* docs

.PHONY: docs
docs: docs/.nojekyll

# Literate agda markdown to pandoc markdown
docs/%.md: src/%.lagda.md
	cd src && agda --html --html-dir=../docs --highlight-occurrences --html-highlight=auto "$(<F)"

# Generalized rule: how to build a .html file from each .md
# Note: you will need pandoc 2 or greater for this to work
docs/%.html: docs/%.md template.html5 Makefile tools/build.sh
	tools/build.sh "$<" "$@"
