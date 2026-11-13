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

all:veuilib_build 


clean:veuilib_clean 

LIBS=libveuilib

veuilib_build:
	$(MAKE) -C ./onvifcpplib;
ifeq ($(strip $(PRJ_CROSS)), )
	cd ./prj_linux/ && $(QMAKE) .
else
	cd ./prj_linux/ && $(QMAKE) . CONFIG+=ARM_LINUX
endif
	$(MAKE) -C ./prj_linux;
	rm -rf ../linux/lib/libveuilib*
	mkdir -p ./lib/linux 
	cp -f ./prj_linux/libveuilib* ./lib/linux/
ifneq ($(strip $(VE_OS)), macos)
	cd ./lib/linux && \
	$(OBJCOPY) --only-keep-debug $(LIBS).so $(LIBS).so.dbg && $(STRIP) -g $(LIBS).so && $(OBJCOPY) --add-gnu-debuglink=$(LIBS).so.dbg $(LIBS).so
endif
	cp ./lib/linux/libveuilib* ../output/$(VE_INSTALL_DIR)/lib/

veuilib_clean:
	$(MAKE) -C ./onvifcpplib clean;
	cd ./prj_linux/ && $(QMAKE) .
	$(MAKE) -C ./prj_linux/ clean;
	rm -rf ./prj_linux/libveuilib.*
	
	
