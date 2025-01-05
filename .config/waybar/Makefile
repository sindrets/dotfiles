SCSS_SRC := $(shell find themes -name '*.scss')
SCSS_OUT := $(patsubst %.scss,%.css,$(SCSS_SRC))

.PHONY: all
all: build-css

.PHONY: build-css
build-css: $(SCSS_OUT)

.PHONY: watch
watch:
	scss --watch --sourcemap=none ./themes/

$(SCSS_OUT): $(SCSS_SRC)
	@ scss --update --sourcemap=none $(SCSS_SRC)
