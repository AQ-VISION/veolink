$(eval version=$(shell grep "define VE_VERSION" include/config/confver.hpp | sed 's|.*VERSION "\(.*\)"|\1|g'))
QMAKE ?= qmake
REL=VeoLink-CE-$(version)-$(VE_OS)-$(VE_VER)-$(VE_ARCH)bit
ifeq ($(strip $(VE_OS)),macos)
REL=VeoLink-CE-$(version)-$(VE_INSTALL_DIR)
endif

ifeq ($(strip $(VE_CROSS_COMPILER)), )
subdirs=3rdparty xcmnlib velib veuilib vecvr client
appsubdirs=xcmnlib velib veuilib vecvr client
else
#embeded device only has the server
subdirs=3rdparty xcmnlib velib veuilib vecvr 
appsubdirs=xcmnlib velib veuilib vecvr
endif


all: prepare
	@set -e; for d in $(subdirs); do $(MAKE) -C "$$d"; done

app: prepare
	@set -e; for d in $(appsubdirs); do $(MAKE) -C "$$d"; done

check-macos:
ifeq ($(strip $(VE_OS)),macos)
	@QMAKE="$(QMAKE)" sh ./scripts/check-macos.sh
endif

test-macos:
	bash ./scripts/test-macos-build.sh

prepare: check-macos
	mkdir -p ./output/$(VE_INSTALL_DIR)/lib
ifneq ($(strip $(VE_OS)), macos)
	chmod +x ./output/linux/*.sh
	cp -r ./output/linux/*.sh ./output/$(VE_INSTALL_DIR)/
	cp -r ./output/linux/service/ ./output/$(VE_INSTALL_DIR)/
	cp -r ./output/linux/fonts/ ./output/$(VE_INSTALL_DIR)/lib/
else
	chmod +x ./output/macos/*.sh
	cp -r ./output/macos/* ./output/$(VE_INSTALL_DIR)/
endif

linkprocess:
ifneq ($(strip $(VE_OS)), macos)	
else
	bash ./maclink.sh
endif


cleanapp: 
	for d in $(appsubdirs); do (cd $$d; (if  test -e "Makefile"; then $(MAKE) clean; fi;) ); done

clean:
	for d in $(subdirs); do (cd $$d; (if  test -e "Makefile"; then $(MAKE) clean; fi;) ); done
	#rm -rf ./linux/*.so ./linux/bin ./linux/lib/ ./linux/share ./linux/ssl ./linux/include
	rm -rf ./output/host/ 

install:
	for d in $(subdirs); do (cd $$d; (if  test -e "Makefile"; then $(MAKE) install; fi;) ); done

distclean: clean
	for d in $(subdirs); do (cd $$d; (if  test -e "Makefile"; then $(MAKE) distclean; fi;) ); done
disttest:
	cp ./output/$(VE_INSTALL_DIR)/lib/libve*.so .;
	cp ./output/$(VE_INSTALL_DIR)/lib/libcmnlib.so .;
	cp ./output/$(VE_INSTALL_DIR)/lib/libcover.so .;
	rm -rf ./output/$(VE_INSTALL_DIR)/;
	mkdir -p ./output/$(VE_INSTALL_DIR)/lib/;
	mv ./libve* libcmnlib.so libcover.so ./output/$(VE_INSTALL_DIR)/lib/
	strip ./output/$(VE_INSTALL_DIR)/lib/*.so

ifeq ($(strip $(VE_OS)),macos)
rel: linkprocess
	rm -rf "./$(REL)"
	mkdir -p "./$(REL)"
	cp -R "./output/$(VE_INSTALL_DIR)/VeoLinkClient.app" "./output/$(VE_INSTALL_DIR)/VeoLinkServer.app" "./$(REL)/"
	tar zcvf "$(REL).tar.gz" "$(REL)"
else
rel: linkprocess
	echo $(REL)
	rm -rf ./$(REL)
	mkdir -p ./output/$(VE_INSTALL_DIR)/translations;
	cp -rf client/src/main/translations/*.qm ./output/$(VE_INSTALL_DIR)/translations;
	cp -rf veuilib/src/translations/*.qm ./output/$(VE_INSTALL_DIR)/translations;
ifneq ($(strip $(VE_OS)), macos)
	cp -r ./output/linux/*.sh ./output/$(VE_INSTALL_DIR)/
	cp -r ./output/linux/service/ ./output/$(VE_INSTALL_DIR)/
else
	cp -r ./output/macos/* ./output/$(VE_INSTALL_DIR)/
endif
	cp -rf ./output/$(VE_INSTALL_DIR) $(REL)
	rm -rf ./$(REL)/lib/x86_64-linux-gnu
	rm -rf ./$(REL)/examples
	rm -rf ./$(REL)/doc
	rm -rf ./$(REL)/lib64
	rm -rf ./$(REL)/mkspecs
	mv ./$(REL)/bin/openssl .
	rm -rf ./$(REL)/bin/*
ifeq ($(strip $(VE_CROSS_COMPILER)), )
	rm -rf ./RapidS* 
else
	rm -rf ./$(REL)/lib/libcover.so
	rm -rf ./$(REL)/*Client*
endif
	mv ./openssl ./$(REL)/bin/
	rm -rf ./$(REL)/include
	rm -rf ./$(REL)/share
	rm -rf ./$(REL)/ssl
	rm -rf ./$(REL)/.svn
	rm -rf ./$(REL)/lib/*.a
	rm -rf ./$(REL)/lib/pkgconfig
	rm -rf ./$(REL)/lib/*.dbg
	rm -rf ./$(REL)/lib/libSDL*
ifeq ($(strip $(VE_OS)), macos)
	$(VE_CROSS_COMPILER)strip ./$(REL)/VeoLinkClient.app/Contents/MacOS/VeoLink*
	$(VE_CROSS_COMPILER)strip ./$(REL)/VeoLinkServer.app/Contents/MacOS/VeoLink*
	cp -r ./output/$(VE_INSTALL_DIR)/plugins/* ./$(REL)/VeoLinkClient.app/Contents/MacOS/
	cp -r ./output/$(VE_INSTALL_DIR)/plugins/* ./$(REL)/VeoLinkServer.app/Contents/MacOS/
	
	#$(VE_CROSS_COMPILER)strip ./$(REL)/lib/libveuilib.dylib
	#$(VE_CROSS_COMPILER)strip ./$(REL)/lib/*ve*.so
	#$(VE_CROSS_COMPILER)strip ./$(REL)/lib/*cmn*.so
else
	$(VE_CROSS_COMPILER)strip ./$(REL)/Rapid*
	$(VE_CROSS_COMPILER)strip ./$(REL)/lib/*.so*
endif
	echo "Create zip file"
	#zip -r $(REL).zip $(REL) 
	tar zcvf $(REL).tar.gz $(REL)
endif

.PHONY: all app prepare check-macos test-macos linkprocess cleanapp clean install distclean disttest rel
	
	
