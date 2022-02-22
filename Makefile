.PHONY: all \
  raylib swigraylib \
  clean cleangen cleanbuild

## Build mode: DEBUG, RELEASE
BUILD_MODE ?= DEBUG

## Output library type
# - STATIC (.a)
# - SHARED (.dll/.so)
SWIGRAYLIB_LIBTYPE ?= SHARED

## Output library file name
SWIGRAYLIB_LIB_NAME ?= swigraylib
ifeq ($(OS),Windows_NT)
    SWIGRAYLIB_LIB_NAME_PREFIX ?=
else
    SWIGRAYLIB_LIB_NAME_PREFIX ?= lib
endif
SWIGRAYLIB_LIB_NAME_SUFFIX ?=
ifeq ($(SWIGRAYLIB_LIBTYPE),STATIC)
    ifeq ($(OS),Windows_NT)
        SWIGRAYLIB_LIB_NAME_EXTENSION ?= lib
    else
        SWIGRAYLIB_LIB_NAME_EXTENSION ?= a
    endif
else
    ifeq ($(OS),Windows_NT)
        SWIGRAYLIB_LIB_NAME_EXTENSION ?= dll
    else
        SWIGRAYLIB_LIB_NAME_EXTENSION ?= so
    endif
endif
SWIGRAYLIB_LIB_NAME_FULL = $(SWIGRAYLIB_RELEASE_PATH)/$(SWIGRAYLIB_LIB_NAME_PREFIX)$(SWIGRAYLIB_LIB_NAME)$(SWIGRAYLIB_LIB_NAME_SUFFIX).$(SWIGRAYLIB_LIB_NAME_EXTENSION)

## Output library location
SWIGRAYLIB_RELEASE_PATH ?= .

## Raylib library info
# Skip compiling raylib if use external raylib
USE_EXTERNAL_RAYLIB ?= FALSE
RAYLIB_LIB_NAME     ?= raylib
RAYLIB_LIB_PATH     ?= ./raylib
RAYLIB_INCLUDE_PATH ?= ./raylib/src
RAYLIB_BUILD_MODE    = $(BUILD_MODE)
RAYLIB_PROJECT_PATH ?= ./raylib
# Raylib sub-make
RAYLIB_EXTRA_OPTIONS ?=
export
unexport CFLAGS
unexport LDFLAGS
unexport LDLIBS

## Swigraylib options
SWIGRAYLIB_TARGET_LANG ?= lua
SWIGRAYLIB_TARGET_OS   ?= windows
# Requires SWIG
SWIGRAYLIB_BINDING_GENERATOR_OPTIONS_USE_DEFAULT ?= TRUE
# Requires SWIG
SWIGRAYLIB_BINDING_GENERATOR_OPTIONS ?=

## Lua library info
LUA_LIB_NAME     ?= lua5.1
LUA_LIB_PATH     ?= /usr/lib/x86_64-linux-gnu
LUA_INCLUDE_PATH ?= /usr/include/lua5.1

########

OBJS = raylib.i.o
RAYLIB_I_C = ./gen/raylib.i/raylib.i.$(SWIGRAYLIB_TARGET_LANG).$(SWIGRAYLIB_TARGET_OS).c

CFLAGS        += -std=c99 -Wall -D_DEFAULT_SOURCE -Werror=pointer-arith
LDFLAGS       += -L$(RAYLIB_LIB_PATH) -L$(LUA_LIB_PATH)
LDLIBS        += -l$(RAYLIB_LIB_NAME) -l$(LUA_LIB_NAME)
INCLUDE_PATHS += -I$(RAYLIB_INCLUDE_PATH) -I$(LUA_INCLUDE_PATH)
ifeq ($(BUILD_MODE),DEBUG)
    CFLAGS += -g -DSWIGRUNTIME_DEBUG
else
    CFLAGS += -s -O1
endif
ifeq ($(SWIGRAYLIB_LIBTYPE),SHARED)
    CFLAGS += -fPIC -DBUILD_LIBTYPE_SHARED
endif
ifeq ($(RAYLIB_MODULE_PHYSAC),TRUE)
    CFLAGS += -DPHYSAC_IMPLEMENTATION
endif

all: swigraylib

raylib:
ifeq ($(USE_EXTERNAL_RAYLIB),FALSE)
	$(MAKE) -C $(RAYLIB_PROJECT_PATH)/src all $(RAYLIB_EXTRA_OPTIONS)
endif

swigraylib: $(OBJS) raylib
ifeq ($(SWIGRAYLIB_LIBTYPE),STATIC)
	$(AR) rcs $(SWIGRAYLIB_LIB_NAME_FULL) $(OBJS)
	@echo "swigraylib static library generated $(SWIGRAYLIB_LIB_NAME_FULL)!"
endif
ifeq ($(SWIGRAYLIB_LIBTYPE),SHARED)
    # WARNING: you should type "make clean" before doing this target
	$(CC) -shared -o $(SWIGRAYLIB_LIB_NAME_FULL) $(OBJS) $(LDFLAGS) $(LDLIBS)
	@echo "swigraylib shared library generated $(SWIGRAYLIB_LIB_NAME_FULL)!"
endif

raylib.i.o: raylib.i.c
	$(CC) -c $< $(CFLAGS) $(INCLUDE_PATHS) -o $@

$(RAYLIB_I_C):
ifeq ($(SWIGRAYLIB_BINDING_GENERATOR_OPTIONS_USE_DEFAULT),TRUE)
	sh ./gen/generate.default.sh
else
	lua ./gen/generate.lua $(SWIGRAYLIB_BINDING_GENERATOR_OPTIONS)
endif

raylib.i.c: $(RAYLIB_I_C)
	cp --update $< $@

clean: cleangen cleanbuild

cleangen:
ifeq ($(OS),Windows_NT)
	del gen/raylib.i/raylib.i.*.c
else
	rm -fv gen/raylib.i/raylib.i.*.c
endif

cleanbuild:
ifeq ($(USE_EXTERNAL_RAYLIB),FALSE)
	$(MAKE) -C $(RAYLIB_PROJECT_PATH)/src clean $(RAYLIB_EXTRA_OPTIONS)
endif
ifeq ($(OS),Windows_NT)
	del *.o /s
	del raylib.i.c
	del *$(RAYLIB_LIB_NAME)*.lib
	del *$(RAYLIB_LIB_NAME)*.dll
else
	rm -rfv *.o
	rm -fv raylib.i.c
	rm -fv *$(RAYLIB_LIB_NAME)*.a
	rm -fv *$(RAYLIB_LIB_NAME)*.so
endif