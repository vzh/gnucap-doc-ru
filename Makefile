# Translation template
pofile := gnucap.ru.po

# Input files
inputs := \
  $(shell sed -n -e "/type:\s*text/ {s/.*\]\s\+//; s/\s.*//;p}" po4a.conf)

# Output files
outputs := $(inputs:.txt=.ru.txt)

# Targets for input files downloading
# use 'make download-path_to_file' to download any file,
# e.g. 'make download-manual/commands.txt'
downloads := $(inputs:%=download-%)

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

# Download sources ###############################################

.PHONY: download
download: $(downloads)
# After downloading a file all trailing spaces in it are removed
$(downloads): %:
	filename=$$(echo $@| sed -e 's/download-//'); wget -O $$filename \
	  $$(echo $@|sed -e 's/\//:/g; s/download-\(.*\)\.txt/http:\/\/gnucap.org\/dokuwiki\/doku.php?id=gnucap:\1\&do=export_raw/') && \
	sed -i 's/\s\+$$//' $$filename

# Remove any temporary files #####################################

.PHONY: clean
clean:
	find . -type f -name '*.ru.txt' |xargs rm


# Help on the targets ############################################

.PHONY: help
help:
	@echo "all:      build all the translation files      "
	@echo "install:  install them to the default directory"
	@echo "download: download source files from gnucap.org"
	@echo "download-path/to/file.txt:                     "
	@echo "          download only specified file         "
	@echo "clean:    delete temporary files               "
	@echo "help:     this help                            "
