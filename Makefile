# ================================================================
# $Id$
# ================================================================
CC=gcc
INSTALL=/usr/bin/install
VERSION=0_1_0
INSTALLBINDIR=/usr/bin
INSTALLSHAREDIR=/usr/share/java
BUILDDIR=build/jwm-$(VERSION)

dircmp: dircmp.c
	$(CC) -Wall -o dircmp dircmp.c

install: dircmp
	$(INSTALL) dircmp $(INSTALLBINDIR)
	$(INSTALL) -m 644 jwm.Makefile $(INSTALLSHAREDIR)

dist: 
	rm -rf $(BUILDDIR)
	mkdir build 
	cp dircmp.c      $(BUILDDIR)
	cp Makefile      $(BUILDDIR)
	cp jwm.Makefile  $(BUILDDIR)
	cp LICENSE       $(BUILDDIR)
	cp README        $(BUILDDIR)
	cp README.dircmp $(BUILDDIR)
	cd build && tar cvzf jwm-$(VERSION).tar.gz jwm-$(VERSION)
	mv build/jwm-$(VERSION).tar.gz .

clean: 
	rm -rf tmp build dircmp.o dircmp jwm-$(VERSION).tar.gz *~

#
# Checks dircmp by creating these dummy files and testing if
# hello.java is newer and thus displayed.  May want to run silent
# (make -s test).  The sleep is nececessary since the system clock
# needs time to run between invocations and therefore hello.java and
# hello.class are assured to have different timestamps.
#
# tmp
# |-- classes
# |   `-- test
# |       `-- hello.class
# `-- src
#     `-- test
#         `-- hello.java    
#
test: dircmp
	mkdir -p tmp tmp/src tmp/classes tmp/src/test tmp/classes/test
	touch tmp/classes/test/hello.class
	sleep 1
	touch tmp/src/test/hello.java
	./dircmp -s tmp/src -d tmp/classes -p .java -q .class test 


