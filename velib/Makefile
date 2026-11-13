
CPROG=libvelib

-include ../common.mk

ifeq ($(TARGET_OS),)
  ifeq ($(OS),Windows_NT)
    TARGET_OS = WIN32
  else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        TARGET_OS = LINUX
    else
        ifeq ($(UNAME_S),Darwin)
            TARGET_OS = OSX
        else
            TARGET_OS = BSD
        endif
    endif
  endif
endif

OUTPUT     =
CPPFLAGS	= -std=c++11 -DLINUX -DLINUX_OS -D__STDC_CONSTANT_MACROS 
CFLAGS	= -DLINUX -DLINUX_OS -D__STDC_CONSTANT_MACROS 

ifneq ($(strip $(PRJ_CROSS)), )
CFLAGS += -DARM_LINUX
endif

LIBS	= $(CPROG).$(SHARED_EXT)
CFLAGS += -fpic
CPPFLAGS += -fpic
ifeq ($(strip $(VE_OS)),macos)
CFLAGS += $(MACOS_CFLAGS)
CPPFLAGS += $(MACOS_CXXFLAGS)
endif
PERM = -m 0755

HDRS   = $(wildcard ./*.h) 

MACHINE := $(shell uname -m)

IFLAGS 	= -I. -I./include/utility\
		-I./include/vdb\
		-I./include/vplay\
		-I./include/\
		-I./src/utility\
		-I./src/vdb\
		-I./src/vplay\
		-I./src/vrender\
		-I./3rdparty/libyuv/include/\
		-I../3rdparty/spdlog/include/\
		-I../3rdparty/poco/Data/include\
		-I../3rdparty/poco/Foundation/include\
		-I../3rdparty/poco/Data/SQLite/include\
		-I../xcmnlib/include\
		-I../xcmnlib/include/utility\
		-I$(VE_PATH)/output/$(VE_INSTALL_DIR)/include\
		
ifeq ($(strip $(VE_OS)),macos)
IFLAGS += -I$(VE_PATH)/output/$(VE_INSTALL_DIR)/include/SDL2
else
IFLAGS += -I./3rdparty/SDL2/include
endif

LDFLAGS +=  -L./3rdparty/libyuv/build-linux/\
				-L$(VE_PATH)/output/$(VE_INSTALL_DIR)/lib\
                -lcmnlib  -lyuv -lPocoDataSQLite -lPocoData  -lPocoFoundation -lPocoNet\
		 -lavformat -lavcodec -lavutil -lswscale  -lcurl
 
LDFLAGS += -fpic -lpthread -lm -lcrypto

ifneq ($(strip $(VE_OS)), macos)
LDFLAGS += -Wl,-Bdynamic -lcrypt -ldl -lstdc++
else
LDFLAGS += $(MACOS_LDFLAGS) -Wl,-install_name,@rpath/$(LIBS)
endif

ifeq ($(strip $(PRJ_CROSS)), )
ifneq ($(strip $(VE_OS)), macos)
LDFLAGS += -luuid -lz -lSDL2 
else
LDFLAGS += -lSDL2 -lz -lm -liconv -Wl,-framework,OpenGL  \
	-lobjc -Wl,-framework,Cocoa \
	-Wl,-framework,Carbon -Wl,-framework,IOKit -Wl,-framework,CoreAudio \
	-Wl,-framework,AudioToolbox -Wl,-framework,AudioUnit -Wl,-framework,CoreVideo
endif
endif
 

LIB_SOURCES =   ./src/utility/license.o\
				./src/utility/base64.o\
				./src/vplay/vplay.o\
				./src/vplay/vsmotalgo.o\
				./src/vrender/novideo.o\
				./src/vrender/vehwcmd.o\
				./src/vdb/indexdb.o\
				./src/vdb/veventdb.o\
				./src/vdb/mediafile.o\
				./src/vdb/pbsession.o\
				./src/vdb/pbwrapper.o\
				./src/vdb/recordsession.o\
				./src/vdb/recordwrapper.o\
				./src/vdb/vdb.o\
				./src/vdb/vdbfile.o\
				./src/vdb/hdfsrecsession.o\
				./src/vdb/hdfswrapper.o\
				./src/vdb/vhdfsdb.o\


ifeq ($(strip $(PRJ_CROSS)), )
LIB_SOURCES += ./src/vrender/sdl_render.o
endif

DEBUG	= -g -Wall

ifeq ($(strip $(PRJ_CROSS)), )
ifneq ($(strip $(VE_OS)), macos)
all: libyuv SDL2 $(LIBS)
else
all: libyuv SDL2-macos $(LIBS)
endif
else
all: libyuv $(LIBS)
endif

$(LIB_SOURCES): $(HDRS)

$(LIBS): $(LIB_SOURCES)
	$(CPP) $(SHARED_FLAGS) -o $(LIBS) $(LIB_SOURCES) $(LDFLAGS)
ifneq ($(strip $(VE_OS)), macos)
	$(OBJCOPY) --only-keep-debug $(CPROG).so $(CPROG).so.dbg && \
	$(STRIP) -g $(CPROG).so && \
	$(OBJCOPY) --add-gnu-debuglink=$(CPROG).so.dbg $(CPROG).so
	$(STRIP) $(LIBS)
endif
	cp $(LIBS)* ../output/$(VE_INSTALL_DIR)/lib/

ifeq ($(MACHINE), x86_64)
SDL2:
	cd ./3rdparty/SDL2/; chmod +x ./configure; ./configure --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/ --disable-shared CFLAGS="-fpic -fcommon";
	$(MAKE) -C ./3rdparty/SDL2/ && $(MAKE) -C ./3rdparty/SDL2/ install;
else
SDL2:
	cd ./3rdparty/SDL2/; chmod +x ./configure; ./configure --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/ --disable-shared;
	$(MAKE) -C ./3rdparty/SDL2/ && $(MAKE) -C ./3rdparty/SDL2/ install;

endif

SDL2-macos:
	mkdir -p ./3rdparty/SDL2-2.0.4-osx/build-$(VE_INSTALL_DIR)
	cd ./3rdparty/SDL2-2.0.4-osx/build-$(VE_INSTALL_DIR) && sh ../configure --build=$(if $(filter arm64,$(VE_MACOS_ARCH)),aarch64,x86_64)-apple-darwin --prefix="$(VE_PATH)/output/$(VE_INSTALL_DIR)" --disable-shared --disable-dependency-tracking --disable-assembly --disable-haptic CC="$(CC)" CXX="$(CPP)" CFLAGS="-fPIC $(MACOS_CFLAGS)" CXXFLAGS="$(MACOS_CXXFLAGS)"
	$(MAKE) -C ./3rdparty/SDL2-2.0.4-osx/build-$(VE_INSTALL_DIR) && $(MAKE) -C ./3rdparty/SDL2-2.0.4-osx/build-$(VE_INSTALL_DIR) install

# Dependency libraries must exist before linking, including parallel builds.
$(LIBS): libyuv
ifeq ($(strip $(PRJ_CROSS)),)
ifeq ($(strip $(VE_OS)),macos)
$(LIBS): SDL2-macos
$(LIB_SOURCES): | SDL2-macos
else
$(LIBS): SDL2
endif
endif

libyuv:
	#cd ./3rdparty/libyuv/build-linux;cmake -DCMAKE_CXX_FLAGS=-fPIC -DCMAKE_C_FLAGS=-fPIC ../;
	#$(MAKE) -C ./3rdparty/libyuv/build-linux/ VERBOSE=1
	$(MAKE) -C ./3rdparty/libyuv/ -f linux.mk CXX="$(CPP)" CXXFLAGS="-O2 -fPIC -Iinclude $(MACOS_CXXFLAGS) $(if $(filter arm64,$(VE_MACOS_ARCH)),-DLIBYUV_DISABLE_NEON,)" libyuv.a
	cp ./3rdparty/libyuv/libyuv.a $(VE_PATH)/output/$(VE_INSTALL_DIR)/lib/

clean:distclean 
	rm -f $(LIBS) $(LIB_SOURCES) 
	rm -f $(LIBS).dbg

distclean: 
ifeq ($(strip $(PRJ_CROSS)), )
ifneq ($(strip $(VE_OS)), macos)
	$(MAKE) -C ./3rdparty/SDL2/ distclean
else
	rm -rf ./3rdparty/SDL2-2.0.4-osx/build-$(VE_INSTALL_DIR)
endif
endif
	rm -rf ./3rdparty/libyuv/build-linux/*
	$(MAKE) -C ./3rdparty/libyuv/ -f linux.mk CXX=$(CPP) clean

install:

.cpp.o:
	$(CPP) -c -o $@ $(DEBUG) $(CPPFLAGS) $(IFLAGS) $<
.c.o:
	$(CC) -c -o $@ $(DEBUG) $(CFLAGS) $(IFLAGS) $<
