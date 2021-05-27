# == CHANGE THE SETTINGS BELOW TO SUIT YOUR ENVIRONMENT =======================

# Your platform. See PLATS for possible values.
PLAT= guess

LUA_DIR= /usr/local
LUA_INCDIR= $(LUA_DIR)/include

LD= ld
CC= gcc -std=gnu89
CFLAGS= -O2 -Wall -Wextra -I. -I$(LUA_INCDIR) $(SYSCFLAGS) $(MYCFLAGS)
LDFLAGS= $(SYSLDFLAGS) $(MYLDFLAGS)
LIBS= $(SYSLIBS) $(MYLIBS)

AR= ar rcu
RANLIB= ranlib
RM= rm -f
UNAME= uname

SYSCFLAGS=
SYSLDFLAGS=
SYSLIBS=

MYCFLAGS=
MYLDFLAGS=
MYLIBS=

# == END OF USER SETTINGS -- NO NEED TO CHANGE ANYTHING BELOW THIS LINE =======

PLATS= guess generic linux macosx solaris

OBJ=	vararg.o
LIB=	libluavararg.a
SO=	vararg.so

default: $(PLAT)

all:	a so

o:	$(OBJ)

a:	$(LIB)

so:	$(SO)

$(LIB): $(OBJ)
	$(AR) $@ $?
	$(RANLIB) $@

$(SO): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $?

clean:
	$(RM) $(OBJ) $(LIB) $(SO)

echo:
	@echo "PLAT= $(PLAT)"
	@echo "CC= $(CC)"
	@echo "CFLAGS= $(CFLAGS)"
	@echo "LDFLAGS= $(LDFLAGS)"
	@echo "LIBS= $(LIBS)"
	@echo "AR= $(AR)"
	@echo "RANLIB= $(RANLIB)"
	@echo "RM= $(RM)"
	@echo "UNAME= $(UNAME)"

# Convenience targets for usual platforms
ALL= all

help:
	@echo "Do 'make PLATFORM' where PLATFORM is one of these:"
	@echo "   $(PLATS)"

guess:
	@echo Guessing `$(UNAME)`
	@$(MAKE) `$(UNAME)`

generic: $(ALL)

Linux linux:
	$(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_LINUX -fPIC" \
	               SYSLDFLAGS="-shared"

Darwin macos macosx:
	$(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_MACOSX -fno-common" \
	               SYSLDFLAGS="-bundle -undefined dynamic_lookup" \
	               CC='export MACOSX_DEPLOYMENT_TARGET="10.10"; gcc' \
	               LD='export MACOSX_DEPLOYMENT_TARGET="10.10"; gcc'

SunOS solaris:
	$(MAKE) $(ALL) SYSCFLAGS="-fpic" SYSLDFLAGS="-O -shared"

# list targets that do not create files (but not all makes understand .PHONY)
.PHONY: all $(PLATS) default o a so clean depend echo none
