# Translation template
pofile := gnucap.ru.po

# Input files
inputs := $(shell grep "\[type: text\]" po4a.conf |awk '{print $$3}')

# Output files
outputs := start.txt \
  $(shell grep "\[type: text\]" po4a.conf |awk '{print $$4}' |sed -e 's/^ru://')

# Installation directory
PREFIX = /tmp/gnucap


# Build all translation files ####################################
.PHONY: all

# Use only one output file as a prerequisite since all the other
# will change together anyway
all: manual.ru.txt

# Install the built files in the specified directory #############

installs := $(outputs:%=${PREFIX}/%)

.PHONY:  install
install: ${installs}

${installs}: ${PREFIX}/%: %
	install -D -m 644 $< $@

# Format the translation template ################################
manual.ru.txt: $(pofile) $(inputs)
	msgconv $< -o tmp.po; \
	if $$(diff tmp.po $< >/dev/null); then \
	  rm tmp.po; \
	else \
	  mv -f tmp.po $< ; \
	fi
	po4a -k 0 po4a.conf
	sed -i -e 's/\s\+$$//' $(outputs)

# Remove any temporary files #####################################

.PHONY: clean
clean:
	find . -type f -name '*.ru.txt' |xargs rm


# Help on the targets ############################################

.PHONY: help
help:
	@echo "all:      build all the translation files"
	@echo "install:  install them to the default directory"
	@echo "clean:    delete temporary files"
	@echo "help:     this help"
