#!/bin/sh
set -eu

fail() {
    printf '%s\n' "$*" >&2
    exit 1
}

[ "$(uname -s)" = Darwin ] || fail 'The macOS build requires a macOS host.'
: "${VE_PATH:?Source rules-macos.mk from the repository root first.}"
: "${VE_MACOS_ARCH:?Source rules-macos.mk first.}"
: "${MACOSX_DEPLOYMENT_TARGET:?Source rules-macos.mk first.}"

case "$VE_MACOS_ARCH" in
    arm64|x86_64) ;;
    *) fail "Unsupported macOS architecture: $VE_MACOS_ARCH" ;;
esac
if [ "$VE_MACOS_ARCH" = arm64 ]; then
    major=${MACOSX_DEPLOYMENT_TARGET%%.*}
    case "$major" in ''|*[!0-9]*) fail 'Invalid MACOSX_DEPLOYMENT_TARGET.' ;; esac
    [ "$major" -ge 11 ] || fail 'Apple Silicon requires MACOSX_DEPLOYMENT_TARGET >= 11.0.'
fi

for tool in clang clang++ xcrun make perl cmake "${QMAKE:-qmake}"; do
    command -v "$tool" >/dev/null 2>&1 || fail "Missing build tool: $tool. Install Qt 5.15 and CMake; see Readme.md."
done
xcrun --sdk macosx --show-sdk-path >/dev/null || fail 'Install Xcode Command Line Tools.'

qmake=${QMAKE:-qmake}
qt_version=$("$qmake" -query QT_VERSION)
case "$qt_version" in
    5.15.*) ;;
    *) fail "Qt 5.15 is required; qmake reports $qt_version. Set VE_QT_PREFIX to your native Qt 5.15 installation." ;;
esac
qt_libs=$("$qmake" -query QT_INSTALL_LIBS)
qt_core=
for library in "$qt_libs/QtCore.framework/QtCore" "$qt_libs/libQt5Core.dylib"; do
    if [ -f "$library" ]; then qt_core=$library; break; fi
done
[ -n "$qt_core" ] || fail "QtCore was not found under $qt_libs."
xcrun lipo -verify_arch "$VE_MACOS_ARCH" "$qt_core" || fail "Qt must contain $VE_MACOS_ARCH; do not mix Intel and Apple Silicon libraries."

printf 'macOS toolchain ready: %s, deployment target %s, Qt %s\n' "$VE_MACOS_ARCH" "$MACOSX_DEPLOYMENT_TARGET" "$qt_version"
