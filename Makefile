CFLAGS += -idirafter src/sys
CFLAGS += -I $(COSMO_NCURSES_INC)
CFLAGS += -I .
CFLAGS += -include util.h

mg: src/usr.bin/mg/*.c fparseln.c strtonum.c
	x86_64-unknown-cosmo-cc $(CFLAGS) -o $@ $^ $(COSMO_NCURSES_LIB)
