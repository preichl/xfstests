#
# Copyright (c) 2000-2008 Silicon Graphics, Inc.  All Rights Reserved.
#

TOPDIR = .
HAVE_BUILDDEFS = $(shell test -f $(TOPDIR)/include/builddefs && echo yes || echo no)

ifeq ($(HAVE_BUILDDEFS), yes)
include $(TOPDIR)/include/builddefs
endif

TESTS = $(shell sed -n -e '/^[0-9][0-9][0-9]*/s/ .*//p' group)
CONFIGURE = configure include/builddefs include/config.h
DMAPI_MAKEFILE = dmapi/Makefile
LSRCFILES = configure configure.in aclocal.m4 README VERSION
LDIRT = config.log .dep config.status config.cache confdefs.h conftest* \
	check.log check.time

SUBDIRS = include lib ltp src m4

default: $(CONFIGURE) $(DMAPI_MAKEFILE) new remake check $(TESTS)
ifeq ($(HAVE_BUILDDEFS), no)
	$(MAKE) $@
else
	$(SUBDIRS_MAKERULE)
	# automake doesn't always support "default" target 
	# so do dmapi make explicitly with "all"
	cd $(TOPDIR)/dmapi; make all
endif

ifeq ($(HAVE_BUILDDEFS), yes)
include $(BUILDRULES)
else
clean:  # if configure hasn't run, nothing to clean
endif

$(CONFIGURE):
	autoheader
	autoconf
	./configure \
                --libexecdir=/usr/lib \
                --enable-lib64=yes

$(DMAPI_MAKEFILE):
	cd $(TOPDIR)/dmapi/ ; ./configure

aclocal.m4::
	aclocal --acdir=`pwd`/m4 --output=$@

install install-dev install-lib:

realclean distclean: clean
	rm -f $(LDIRT) $(CONFIGURE)
	rm -rf autom4te.cache Logs
