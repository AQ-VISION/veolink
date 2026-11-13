# VeoLink - VMS Software Community Edition #

VeoLink CE is an open-source Video Management System (VMS), derived from the
[rapidvms](https://github.com/veyesys/rapidvms) project (AGPL, project closed upstream).

It includes:

* **VeoLinkServer** — server/recorder (formerly RapidStor)
* **VeoLinkClient** — desktop client (formerly RapidClient)

## Upstream history ##
5.0 features
1. OpenCV support.
2. H265 support.
3. Remove gsoap depends.


# Build #
### Linux (Ubuntu 22.04 / 24.04 x86_64) ###
	sudo apt-get install build-essential cmake git yasm nasm shtool libtool automake autoconf \
	    qtbase5-dev qt5-qmake libqt5sql5-sqlite \
	    "^libxcb.*-dev" libx11-xcb-dev libx11-dev libxext-dev libxrender-dev libxi-dev \
	    libglu1-mesa-dev libgl1-mesa-dev freeglut3-dev \
	    zlib1g-dev uuid-dev libbsd-dev lsb-release

	$git submodule update --init --recursive
	$source ./rules.mk
	$make

	Notes:
	* The desktop client and server UI link against the distro Qt 5.15
	  (qtbase5-dev / qt5-qmake). The vendored Qt 5.7.1 tarball in 3rdparty/qt
	  is only used for cross-compile targets (e.g. Raspberry Pi).
	* rules.mk auto-detects the repo root from the current directory; export
	  VE_PATH beforehand to override.

### macOS (Apple Silicon, native arm64) ###

macOS 11 or newer and Xcode Command Line Tools are required. Install native
CMake and Qt 5.15, including Widgets, Network, SQL/SQLite and `macdeployqt`.
Qt 6 is not supported by the current application sources. For Homebrew
installations where the Qt 5 formula is available:

```sh
xcode-select --install
brew install cmake qt@5
export VE_QT_PREFIX="$(brew --prefix qt@5)"
source ./rules-macos.mk
make check-macos
git submodule update --init --recursive
make
make linkprocess
```

For another Qt 5.15 installation, set `VE_QT_PREFIX` to its prefix before
sourcing the rules. The preflight rejects Intel-only Qt on an arm64 build.
Output is placed in `output/macos-11.0-arm64/`; override
`MACOSX_DEPLOYMENT_TARGET` before sourcing to target a newer macOS release.
`make rel` creates a package containing self-contained `.app` bundles.
Local bundles are ad-hoc signed, not Developer ID signed or notarized.
`make test-macos` checks the preflight and recursive dylib deployment using
small native fixtures; it does not require an installed Qt SDK.

The native bring-up preserves the vendored FFmpeg/OpenSSL APIs and the custom
SDL Cocoa backend used for Qt video tiles. Legacy assembly, VDA/VideoToolbox
and SDL haptics are disabled in this build. These old dependencies still need
a separate security upgrade before production deployment. Clean application
and dependency objects before switching between Intel and arm64 builds.
The portable RapidMedia/RTSP implementation, previously removed while its API
was still referenced, is restored from the Git revision before `20a80c2a`.

For an isolated local smoke-run, launch each binary with
`VEOLINK_LOCAL_ONLY=1` and `VEOLINK_RUNTIME_DIR` set to its own absolute writable
directory, using that directory as the working directory. Server API port 9080
and debug ports 9100/9200 then bind to 127.0.0.1; ONVIF notification and embedded
RTSP/RTMP/HTTP listeners are not started. Configuration, events and logs use the
runtime directory instead of existing home-directory databases. For unpackaged
development binaries, use the installed Qt 5 plugin path. This mode limits
exposure but does not repair the legacy authentication defects.

### Windows ###
	1. Install VS2013
	2. Install Qt 5.x.x in the http://download.qt-project.org/official_releases/qt/
	3. http://download.qt-project.org/official_releases/vsaddin/
	4. Add Qt version to VS2013
	5. Change scripts\dllprepare* QT_WIN32 and QT_WIN64
	6. run the dllprepare.bat
	7. veuilib\prj_win32\veuilib.sln build
	8. vecvr\prj_win32\vecvr.sln build
	9. client\prj_win32\veclient.sln build
	
### Raspberry pi 3 ###
	Change VE_CROSS_COMPILER_PATH in the rules-pi3.mk
	$source ./rules-pi3.mk
	$make 

# Wiki #

*  [Upstream rapidvms manual](https://linkingv.gitbooks.io/rapidvmsusermanual/content/)


----------
![](https://raw.githubusercontent.com/xsmart/ve-img/master/opencvr2/opencvrclient.png)

![](https://raw.githubusercontent.com/xsmart/ve-img/master/opencvr2/playback.png)

![](https://raw.githubusercontent.com/xsmart/ve-img/master/opencvr2/configure.png)

![](https://raw.githubusercontent.com/xsmart/ve-img/master/opencvr2/opencvrstoradd.png)

![](https://raw.githubusercontent.com/xsmart/ve-img/master/snapshot/linkvms.jpg)


#### Upstream project ####
[https://github.com/veyesys/rapidvms](https://github.com/veyesys/rapidvms)

### Features list ###
	ONVIF profile S support.
    Unlimited timeline playback.
	Anti file system fragment recording system.
	Multi Display screen support.
	Alarm Support
	PTZ Support
	Emap
	HW accel Decoding
	MJPEG/MPEG4/H264/H265 support
	Linux(ARM X64 X86) Windows MacOS(Coming sonn)support
	RTSP over SSL(HTTPS)
	RTSP Server/RTMP Server/HLS Server





