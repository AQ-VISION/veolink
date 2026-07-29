all:mediaserver_build vepro_build 


clean:vepro_clean mediaserver_clean

vepro_build:
	cd ./prj_linux/ ; qmake .;
	$(MAKE) -C ./prj_linux;
	cp -r ./prj_linux/VeoLinkServer* ../output/$(VE_INSTALL_DIR)/ 
ifeq ($(strip $(VE_OS)), macos)
	cp -r ../output/macos/VeoLinkServer* ../output/$(VE_INSTALL_DIR)/
endif

#html5stream (AQ-VISION) provides the embedded media server C SDK (libmk_api)
#Only the SDK is built; MediaServer binary, tests, WebRTC/SRT are disabled
mediaserver_build:
	cd src/html5stream; git submodule update --init --recursive; mkdir -p build; cd build; cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-fpic" -DCMAKE_INSTALL_PREFIX=$(VE_PATH)/output/$(VE_INSTALL_DIR)/ -DENABLE_SERVER=OFF -DENABLE_TESTS=OFF -DENABLE_WEBRTC=OFF -DENABLE_SRT=OFF -DENABLE_OPENSSL=OFF -DENABLE_FFMPEG=OFF -DENABLE_PACKAGING=OFF; make; make install;

vepro_clean:
	cd ./prj_linux/ ; qmake .;
	$(MAKE) -C ./prj_linux/ clean;
	rm -rf ./prj_linux/VeoLinkServer*

mediaserver_clean:
	rm -rf src/html5stream/build

	
	
