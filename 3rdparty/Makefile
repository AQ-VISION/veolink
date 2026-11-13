-include ../common.mk
PROTOBUF_BUILD_DIR ?= protobuf/cmake/linux

ifeq ($(strip $(PRJ_CROSS)), )
ifeq ($(strip $(VE_OS)), macos)
all:poco_build ffmpeg_build openssl_build_macos leveldb_build curl_build protobuf_build live555_build 
PROTOBUF_BUILD_DIR = protobuf/cmake/$(VE_INSTALL_DIR)
POCO_BUILD_FLAGS = POCO_TARGET_OSARCH=$(VE_MACOS_ARCH) ARCHFLAGS="$(MACOS_CFLAGS)" DEFAULT_TARGET=shared_release
LEVELDB_BUILD_FLAGS = OPT="-O2 -DNDEBUG $(MACOS_CXXFLAGS)"
LIVE555_BUILD_FLAGS = EXTRA_LDFLAGS="$(MACOS_CFLAGS) -fPIC"
curl_build: openssl_build_macos
else
# Native Linux uses the distro Qt 5.15 (qtbase5-dev / qt5-qmake); the vendored
# Qt 5.7.1 tarball is only built for cross-compile targets.
all:poco_build ffmpeg_build openssl_build leveldb_build curl_build protobuf_build  live555_build 
PROTOBUF_BUILD_DIR = protobuf/cmake/linux
curl_build: openssl_build
endif

else
all:poco_build_cross ffmpeg_build_cross openssl_build_cross leveldb_build qt_build_cross  qtxmlpatterns_build  curl_build_cross protobuf_build_cross live555_build_cross
endif


clean:distclean
distclean:poco_clean ffmpeg_clean openssl_clean leveldb_clean qt_clean qtxmlpatterns_clean  onvifc_clean protobuf_clean curl_clean live555_clean

poco_build:
ifeq ($(strip $(VE_OS)),macos)
	cd poco && chmod +x ./configure ./build/script/* && ./configure --config=Darwin-clang --no-tests --no-samples --omit=Data/ODBC,Data/MySQL,Crypto,MongoDB,NetSSL_OpenSSL,CppUnit,PDF --prefix="$(VE_PATH)/output/$(VE_INSTALL_DIR)"
else
	cd poco; chmod +x ./configure; chmod +x ./build/script/*; ./configure --no-tests --no-samples --omit=Data/ODBC,Data/MySQL,Crypto,MongoDB,NetSSL_OpenSSL,CppUnit,PDF --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/;
endif
	$(MAKE) -C poco $(POCO_BUILD_FLAGS) && $(MAKE) -C poco $(POCO_BUILD_FLAGS) install

poco_build_cross:
	cd poco; chmod +x ./configure; chmod +x ./build/script/*; ./configure --config=ARM-Linux --no-tests --no-samples --omit=Data/ODBC,Data/MySQL,Crypto,MongoDB,NetSSL_OpenSSL,CppUnit,PDF --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/;
	$(MAKE) -C poco && $(MAKE) -C poco install;

ffmpeg_build:
ifeq ($(strip $(VE_OS)),macos)
	cd ffmpeg && chmod +x ./version.sh && sh ./configure --cc="$(CC)" --cxx="$(CPP)" --arch=$(if $(filter arm64,$(VE_MACOS_ARCH)),aarch64,x86_64) --target-os=darwin --disable-asm --disable-vaapi --disable-vda --disable-videotoolbox --disable-programs --disable-static --enable-shared --extra-cflags="$(MACOS_CFLAGS)" --extra-ldflags="$(MACOS_CFLAGS)" --prefix="$(VE_PATH)/output/$(VE_INSTALL_DIR)"
else
	cd ffmpeg; chmod +x ./configure; chmod +x version.sh; ./configure  --disable-vaapi --disable-programs  --disable-static --enable-shared --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/;
endif
	$(MAKE) -C ffmpeg && $(MAKE) -C ffmpeg install;

ffmpeg_build_cross:
	cd ffmpeg; chmod +x ./configure; chmod +x version.sh; ./configure --enable-cross-compile --cross-prefix=$(VE_CROSS_COMPILER) --arch=arm --target-os=linux --disable-vaapi --disable-programs  --disable-static --enable-shared --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/;
	$(MAKE) -C ffmpeg && $(MAKE) -C ffmpeg install;

openssl_build:
	#cd openssl; chmod +x ./config; chmod +x ./util/pod2mantest; chmod +x ./util/point.sh; ./config --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/ -fPIC;
	cd openssl; chmod +x ./config; chmod +x ./util/pod2mantest; chmod +x ./util/point.sh; ./config --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/ shared;
	$(MAKE) -C openssl && $(MAKE) -C openssl install;
	chmod 777 $(VE_PATH)/output/$(VE_INSTALL_DIR)/lib/libssl*;
	chmod 777 $(VE_PATH)/output/$(VE_INSTALL_DIR)/lib/libcrypto*;

openssl_build_macos:
	cd openssl && chmod +x ./util/pod2mantest ./util/point.sh && perl ./Configure darwin64-$(VE_MACOS_ARCH)-cc shared no-asm --prefix="$(VE_PATH)/output/$(VE_INSTALL_DIR)" -mmacosx-version-min=$(MACOSX_DEPLOYMENT_TARGET)
	$(MAKE) -C openssl && $(MAKE) -C openssl install_sw;

openssl_build_cross:
	cd openssl; chmod +x ./config; chmod +x ./util/pod2mantest; chmod +x ./util/point.sh; ./config --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/ os/compiler:$(VE_CROSS_COMPILER)gcc  -fPIC;
	$(MAKE) -C openssl && $(MAKE) -C openssl install;

leveldb_build:
	cd leveldb-posix; chmod +x ./build_detect_platform ;
	$(MAKE) -C leveldb-posix CC="$(CC)" CXX="$(CPP)" $(LEVELDB_BUILD_FLAGS) out-static/libleveldb.a
	cp leveldb-posix/out-static/*.a $(VE_PATH)/output/$(VE_INSTALL_DIR)/lib/ 

onvifc_build:
	cd onvifc/prj_linux/ ; qmake .;
	$(MAKE) -C onvifc/prj_linux; 

protobuf_build:
	cmake -S protobuf/cmake -B $(PROTOBUF_BUILD_DIR) $(MACOS_CMAKE_FLAGS) -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_CXX_STANDARD=11 -Dprotobuf_MSVC_STATIC_RUNTIME=ON -DCMAKE_BUILD_TYPE=Release -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX="$(VE_PATH)/output/$(VE_INSTALL_DIR)"
	+cmake --build $(PROTOBUF_BUILD_DIR)
	cmake --install $(PROTOBUF_BUILD_DIR)
	if  test -e $(VE_PATH)/output/$(VE_INSTALL_DIR)/lib64/libprotobuf.a; then cp $(VE_PATH)/output/$(VE_INSTALL_DIR)/lib64/*  $(VE_PATH)/output/$(VE_INSTALL_DIR)/lib/; fi;

protobuf_build_cross:
	cd protobuf; chmod +x ./configure ; make distclean; ./configure --prefix=$(VE_PATH)/output/host/
	$(MAKE) -C protobuf; 
	$(MAKE) -C protobuf install; 
	cd protobuf; chmod +x ./configure ; make distclean; ./configure --host=$(VE_CROSS_TOOL) CC=$(CC) CXX=$(CPP)  --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/ --with-protoc=$(VE_PATH)/output/host/bin/protoc
	$(MAKE) -C protobuf; 
	$(MAKE) -C protobuf install; 

qt_build:
	cd qt && tar zxvf qtbase-opensource-src-5.7.1.tar.gz ; 
	cd qt/qtbase-opensource-src-5.7.1; chmod +x ./configure ;./configure  -confirm-license -release -make libs -opensource --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/
	$(MAKE) -C qt/qtbase-opensource-src-5.7.1; 
	$(MAKE) -C qt/qtbase-opensource-src-5.7.1 install; 

qt_build_cross:
	cd qt && rm -rf pcre-8.39
	cd qt && unzip pcre-8.39.zip;
	cd qt/pcre-8.39; chmod +x ./configure ; ./configure --enable-pcre16  CC=$(VE_CROSS_COMPILER)gcc --host=$(VE_CROSS_TOOL)  --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/
	$(MAKE) -C qt/pcre-8.39;
	$(MAKE) -C qt/pcre-8.39 install; 
	cd qt && tar zxvf qtbase-opensource-src-5.7.1.tar.gz ; 
	cp -r qt/linux-cross-g++ qt/qtbase-opensource-src-5.7.1/mkspecs/devices
	cd qt/qtbase-opensource-src-5.7.1; chmod +x ./configure ;./configure  -confirm-license -opensource --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/ -device linux-cross-g++ -device-option CROSS_COMPILE=$(VE_CROSS_COMPILER) -hostprefix $(VE_PATH)/output/$(VE_INSTALL_DIR)/  -release -make libs -no-qpa-platform-guard -L $(VE_PATH)/output/$(VE_INSTALL_DIR)/lib/ -I $(VE_PATH)/output/$(VE_INSTALL_DIR)/include/ 
	#-system-pcre
	$(MAKE) -C qt/qtbase-opensource-src-5.7.1; 
	$(MAKE) -C qt/qtbase-opensource-src-5.7.1 install; 

qtscript_build:
	cd qt && tar zxvf qtscript-opensource-src-5.7.1.tar.gz ;
	cd qt/qtscript-opensource-src-5.7.1; qmake PREFIX=$(VE_PATH)/output/$(VE_INSTALL_DIR)/
	$(MAKE) -C qt/qtscript-opensource-src-5.7.1; 
	$(MAKE) -C qt/qtscript-opensource-src-5.7.1 install; 
qtxmlpatterns_build:
	cd qt && tar zxvf qtxmlpatterns-opensource-src-5.7.1.tar.gz ;
	cd qt/qtxmlpatterns-opensource-src-5.7.1;qmake PREFIX=$(VE_PATH)/output/$(VE_INSTALL_DIR)/ 
	$(MAKE) -C qt/qtxmlpatterns-opensource-src-5.7.1; 
	$(MAKE) -C qt/qtxmlpatterns-opensource-src-5.7.1 install;
curl_build:
ifeq ($(strip $(VE_OS)),macos)
	cd curl && chmod +x ./install-sh && sh ./configure --prefix="$(VE_PATH)/output/$(VE_INSTALL_DIR)" --with-ssl="$(VE_PATH)/output/$(VE_INSTALL_DIR)" CC="$(CC)" CFLAGS="$(MACOS_CFLAGS)" LDFLAGS="$(MACOS_CFLAGS)"
else
	cd curl && chmod +x ./configure ./install-sh && ./configure --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/ --with-ssl=$(VE_PATH)/output/$(VE_INSTALL_DIR)/
endif
	$(MAKE) -C curl && $(MAKE) -C curl install;

curl_build_cross:
	cd curl; chmod +x ./configure ./install-sh; ./configure --host=$(VE_CROSS_TOOL) --prefix=$(VE_PATH)/output/$(VE_INSTALL_DIR)/;
	$(MAKE) -C curl && $(MAKE) -C curl install;
	
live555_build:
ifeq ($(strip $(VE_OS)),macos)
	cd live555 && sh ./genMakefiles macosx
else
	cd live555; chmod +x genMakefiles; ./genMakefiles linux-64bit; 
endif
	$(MAKE) -C live555 $(LIVE555_BUILD_FLAGS)
	$(MAKE) -C live555/live555
	cp ./live555/live555/liblive555.$(SHARED_EXT) "$(VE_PATH)/output/$(VE_INSTALL_DIR)/lib"
	
live555_build_cross:
	cd live555; chmod +x genMakefiles; ./genMakefiles armlinux; 
	$(MAKE) -C live555 CROSS_COMPILE=$(VE_CROSS_COMPILER);
	$(MAKE) -C live555/live555
	cp ./live555/live555/liblive555.so $(VE_PATH)/output/$(VE_INSTALL_DIR)/lib
	
poco_clean:
	$(MAKE) -C poco clean
ffmpeg_clean:
	$(MAKE) -C ffmpeg clean
openssl_clean:
	$(MAKE) -C openssl clean
leveldb_clean:
	$(MAKE) -C leveldb-posix clean
onvifc_clean:
	cd onvifc/prj_linux/ ; qmake .;
	$(MAKE) -C onvifc/prj_linux/ clean
protobuf_clean:
	rm -rf $(PROTOBUF_BUILD_DIR)
qt_clean:
	rm -rf qt/qtbase-opensource-src-5.7.1	
qtxmlpatterns_clean:
	rm -rf qt/qtxmlpatterns-opensource-src-5.7.1;

qtscript_clean:
	rm -rf qt/qtscript-opensource-src-5.7.1;
curl_clean:
	$(MAKE) -C curl clean
	
	
live555_clean:
	$(MAKE) -C live555 clean
	$(MAKE) -C live555/live555 clean
