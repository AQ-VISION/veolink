
PRJ_CROSS=$(VE_CROSS_COMPILER)

AS              = $(PRJ_CROSS)as
LD              = $(PRJ_CROSS)ld
CC              = $(PRJ_CROSS)gcc
CPP             = $(PRJ_CROSS)g++
AR              = $(PRJ_CROSS)ar
NM              = $(PRJ_CROSS)nm
STRIP           = $(PRJ_CROSS)strip
OBJCOPY         = $(PRJ_CROSS)objcopy
OBJDUMP         = $(PRJ_CROSS)objdump
RANLIB          = $(PRJ_CROSS)ranlib

QMAKE ?= qmake
SHARED_EXT = so
SHARED_FLAGS = -shared
ifeq ($(strip $(VE_OS)),macos)
CC = clang
CPP = clang++
CXX = clang++
SHARED_EXT = dylib
SHARED_FLAGS = -dynamiclib
MACOS_CFLAGS = -arch $(VE_MACOS_ARCH) -mmacosx-version-min=$(MACOSX_DEPLOYMENT_TARGET)
MACOS_CXXFLAGS = $(MACOS_CFLAGS) -stdlib=libc++
MACOS_LDFLAGS = $(MACOS_CXXFLAGS) -Wl,-rpath,$(VE_PATH)/output/$(VE_INSTALL_DIR)/lib
MACOS_CMAKE_FLAGS = -DCMAKE_OSX_ARCHITECTURES=$(VE_MACOS_ARCH) -DCMAKE_OSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) -DCMAKE_POLICY_VERSION_MINIMUM=3.5
endif
