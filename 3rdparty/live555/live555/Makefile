-include ../../../common.mk

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

CPROG = live555
#CXXPROG = h5s

# build tools
MKDIR = mkdir -p
RMF = rm -f
RMRF = rm -rf

BUILD_DIR = out.linux


BUILD_DIRS = $(BUILD_DIR) $(BUILD_DIR)/src 
LIB_SOURCES = src/live555_rtsp_client.cpp
LIB_INLINE  = 
APP_SOURCES = 

SOURCE_DIRS =

OBJECTS = $(LIB_SOURCES:.c=.o) $(APP_SOURCES:.c=.o)
OBJECTS = $(LIB_SOURCES:.cpp=.o) $(APP_SOURCES:.c=.o)
BUILD_RESOURCES =


CFLAGS += -Wall -Wextra -Wshadow -Wformat-security -Winit-self -Wmissing-prototypes -O2 -D$(TARGET_OS) -Iinclude 
CFLAGS +=
CXXFLAGS+= -I../BasicUsageEnvironment/include  -I../groupsock/include -I../liveMedia/include -I../UsageEnvironment/include
LDFLAGS+= -L../BasicUsageEnvironment/  -L../groupsock/ -L../liveMedia/ -L../UsageEnvironment/
LDFLAGS+= -lliveMedia -lUsageEnvironment -lBasicUsageEnvironment  -lgroupsock 

LIBS = -lpthread -lm



ifdef WITH_DEBUG
  CFLAGS += -g -DDEBUG_ENABLED
else
  CFLAGS += -DNDEBUG
endif

BUILD_DIRS += $(addprefix $(BUILD_DIR)/, $(SOURCE_DIRS))
BUILD_OBJECTS = $(addprefix $(BUILD_DIR)/, $(OBJECTS))
MAIN_OBJECTS = $(addprefix $(BUILD_DIR)/, $(APP_SOURCES:.c=.o))
LIB_OBJECTS = $(filter-out $(MAIN_OBJECTS), $(BUILD_OBJECTS))

ifeq ($(TARGET_OS),LINUX)
  LIBS += -lrt -ldl
  CAN_INSTALL = 1
endif

SHARED_LIB = $(SHARED_EXT)
ifeq ($(strip $(VE_OS)),macos)
CFLAGS += $(MACOS_CFLAGS)
CXXFLAGS += -std=c++11 $(MACOS_CXXFLAGS)
LDFLAGS += $(MACOS_LDFLAGS) -Wl,-install_name,@rpath/lib$(CPROG).$(SHARED_LIB)
endif

all: build


#build: $(CPROG) $(CXXPROG)
build: slib

lib: lib$(CPROG).a

slib: lib$(CPROG).$(SHARED_LIB)

clean:
	$(RMRF) $(BUILD_DIR)
	$(RMRF) lib$(CPROG).a
	$(RMRF) lib$(CPROG).$(SHARED_LIB)
	$(RMRF) $(CPROG)

distclean: clean
	$(RMF) $(CPROG) lib$(CPROG).so lib$(CPROG).a lib$(CPROG).dll.a

lib$(CPROG).a: CFLAGS += -fPIC
lib$(CPROG).a: $(LIB_OBJECTS)
	@$(RMF) $@
	ar cq $@ $(LIB_OBJECTS)

lib$(CPROG).$(SHARED_LIB): CFLAGS += -fPIC
lib$(CPROG).$(SHARED_LIB): $(LIB_OBJECTS)
	$(CPP) $(SHARED_FLAGS) -o $@ $(CFLAGS) $(LIB_OBJECTS) $(LDFLAGS)


$(CPROG): $(BUILD_OBJECTS) $(BUILD_RESOURCES)
	$(CPP) -o $@ $(CFLAGS) $(LDFLAGS) $(BUILD_OBJECTS) $(BUILD_RESOURCES) $(LIBS)

$(CXXPROG): $(BUILD_OBJECTS)
	$(CPP) -o $@ $(CFLAGS) $(LDFLAGS) $(BUILD_OBJECTS) $(LIBS)

$(BUILD_OBJECTS): $(BUILD_DIRS)

$(BUILD_DIRS):
	-@$(MKDIR) "$@"

$(BUILD_DIR)/%.o : %.cpp
	$(CPP) -c $(CFLAGS) $(CXXFLAGS) $< -o $@

$(BUILD_DIR)/%.o : %.c
	$(CC) -c $(CFLAGS) $< -o $@

.PHONY: all help build install clean lib so
