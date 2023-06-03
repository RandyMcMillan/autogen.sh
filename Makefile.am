SUBDIRS = src
bin_SCRIPTS = nostril
EXTRA_DIST = include test lib

CLEANFILES = $(bin_SCRIPTS)
ACLOCAL_AMFLAGS = -I m4

.PHONY:src
src:
	pushd src && make all
