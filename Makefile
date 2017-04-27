CC := gcc
CFLAGS := -Wall -Wextra -Werror -pedantic --std=gnu99 -g -Wno-error=pointer-sign # to handle broken gdk-pixbuf-csource output
SDL := `sdl-config --libs` -lSDL_image
SDLFLAGS := `sdl-config --cflags`
GTK := `pkg-config --libs gtk+-2.0`
GTKFLAGS := `pkg-config --cflags gtk+-2.0`
VERSION := `git describe --tags`
LIBS := colourspace.o bits.o libscrplus.o
INCLUDES := colourspace.h bits.h libscrplus.h

all: scrplus gscrplus libscrplus.o

clean:
	rm -f *.o
	rm -f scrplus gscrplus

scrplus: scrplus.c $(LIBS) $(INCLUDES)
	$(CC) $(CFLAGS) $(SDLFLAGS) -o scrplus scrplus.c -lm $(LIBS) $(SDL)

gscrplus: gscrplus.c $(LIBS) $(INCLUDES) icondata.h
	$(CC) $(CFLAGS) $(SDLFLAGS) $(GTKFLAGS) -o gscrplus gscrplus.c -lm $(LIBS) $(SDL) $(GTK)

bits.o: bits.c bits.h
	$(CC) $(CFLAGS) -o bits.o -c bits.c

icondata.h: icon.png
	gdk-pixbuf-csource --build-list --struct icondata icon.png > icondata.h

colourspace.h: bits.h
	touch -c colourspace.h

libscrplus.h: colourspace.h
	touch -c libscrplus.h

libscrplus.o: libscrplus.c libscrplus.h
	$(CC) $(CFLAGS) -c $< -o $@ $(SDLFLAGS)

%.o: %.c %.h
	$(CC) $(CFLAGS) -c $< -o $@

dist: distu distw

distu: all
	-rm -r scrplus_$(VERSION)
	mkdir scrplus_$(VERSION)
	-for p in $$(ls); do cp $$p scrplus_$(VERSION)/$$p; done;
	-rm scrplus_$(VERSION)/*.tar.gz scrplus_$(VERSION)/*.zip
	tar -cvvf scrplus_$(VERSION).tar scrplus_$(VERSION)/
	gzip scrplus_$(VERSION).tar
	rm -r scrplus_$(VERSION)

distw: all
	-rm -r scrplus_w$(VERSION)
	mkdir scrplus_w$(VERSION)
	-for p in $$(ls); do cp $$p scrplus_w$(VERSION)/$$p; done;
	-for p in $$(ls w); do cp w/$$p scrplus_w$(VERSION)/$$p; done;
	-rm scrplus_w$(VERSION)/*.tar.gz scrplus_w$(VERSION)/*.zip
	-rm scrplus_w$(VERSION)/*.o
	-rm scrplus_w$(VERSION)/scrplus
	-rm scrplus_w$(VERSION)/gscrplus
	make -C scrplus_w$(VERSION) -fMakefile all

.PHONY: clean
