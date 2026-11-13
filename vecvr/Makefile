-include ../common.mk

all:mediaserver_build vepro_build 


clean:vepro_clean mediaserver_clean

vepro_build: mediaserver_build
	cd ./prj_linux/ && $(QMAKE) .
	$(MAKE) -C ./prj_linux;
	cp -r ./prj_linux/VeoLinkServer* ../output/$(VE_INSTALL_DIR)/ 
ifeq ($(strip $(VE_OS)), macos)
	cp -r ../output/macos/VeoLinkServer* ../output/$(VE_INSTALL_DIR)/
endif

#html5stream (AQ-VISION) provides the embedded media server C SDK (libmk_api)
#Only the SDK is built; MediaServer binary, tests, WebRTC/SRT are disabled
mediaserver_build:
	git submodule update --init --recursive -- src/html5stream
	cmake -S src/html5stream -B src/html5stream/build/$(VE_INSTALL_DIR) $(MACOS_CMAKE_FLAGS) -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX="$(VE_PATH)/output/$(VE_INSTALL_DIR)" -DENABLE_SERVER=OFF -DENABLE_TESTS=OFF -DENABLE_WEBRTC=OFF -DENABLE_SRT=OFF -DENABLE_OPENSSL=OFF -DENABLE_FFMPEG=OFF -DENABLE_PACKAGING=OFF -DDISABLE_REPORT=ON
	+cmake --build src/html5stream/build/$(VE_INSTALL_DIR)
	cmake --install src/html5stream/build/$(VE_INSTALL_DIR)

vepro_clean:
	cd ./prj_linux/ && $(QMAKE) .
	$(MAKE) -C ./prj_linux/ clean;
	rm -rf ./prj_linux/VeoLinkServer*

mediaserver_clean:
	rm -rf src/html5stream/build

	
	
