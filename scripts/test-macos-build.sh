#!/bin/bash
# Exercise the native preflight and dylib packaging without installing Qt.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
fixture="$(mktemp -d "${TMPDIR:-/tmp}/veolink-macos-test.XXXXXX")"
trap 'rm -rf "$fixture"' EXIT
export VE_MACOS_ARCH="$(uname -m)"
export VE_PATH="$fixture"
export VE_INSTALL_DIR="macos-test-$VE_MACOS_ARCH"
export MACOSX_DEPLOYMENT_TARGET=11.0
prefix="$fixture/output/$VE_INSTALL_DIR"
export TEST_QT_PREFIX="$fixture/qt"
mkdir -p "$prefix/lib" "$TEST_QT_PREFIX/bin" "$TEST_QT_PREFIX/lib"

clang -arch "$VE_MACOS_ARCH" -mmacosx-version-min=11.0 -dynamiclib -x c - -o "$prefix/lib/libdep.dylib" -Wl,-install_name,@rpath/libdep.dylib <<< 'int dep(void) { return 7; }'
clang -arch "$VE_MACOS_ARCH" -mmacosx-version-min=11.0 -dynamiclib -x c - -o "$prefix/lib/libwrapper.dylib" -L"$prefix/lib" -ldep -Wl,-install_name,@rpath/libwrapper.dylib <<< 'extern int dep(void); int wrapper(void) { return dep(); }'
cp "$prefix/lib/libdep.dylib" "$TEST_QT_PREFIX/lib/libQt5Core.dylib"
printf '%s\n' '#!/bin/sh' 'case "$2" in' 'QT_VERSION) printf "%s\n" "${TEST_QT_VERSION:-5.15.2}" ;;' 'QT_HOST_BINS) printf "%s\n" "$TEST_QT_PREFIX/bin" ;;' 'QT_INSTALL_LIBS) printf "%s\n" "$TEST_QT_PREFIX/lib" ;;' '*) exit 1 ;;' 'esac' > "$TEST_QT_PREFIX/bin/qmake"
printf '%s\n' '#!/bin/sh' 'exit 0' > "$TEST_QT_PREFIX/bin/macdeployqt"
cp "$TEST_QT_PREFIX/bin/macdeployqt" "$TEST_QT_PREFIX/bin/cmake"
chmod +x "$TEST_QT_PREFIX/bin/"*
export PATH="$TEST_QT_PREFIX/bin:$PATH"
export QMAKE="$TEST_QT_PREFIX/bin/qmake"

sh "$root/scripts/check-macos.sh"
if TEST_QT_VERSION=6.8.0 sh "$root/scripts/check-macos.sh" > "$fixture/rejected.log" 2>&1; then
    printf 'Preflight incorrectly accepted Qt 6.\n' >&2; exit 1
fi
if VE_MACOS_ARCH=invalid sh "$root/scripts/check-macos.sh" > "$fixture/rejected.log" 2>&1; then
    printf 'Preflight incorrectly accepted an unsupported architecture.\n' >&2; exit 1
fi
if [ "$VE_MACOS_ARCH" = arm64 ]; then
    clang -arch x86_64 -mmacosx-version-min=11.0 -dynamiclib -x c - -o "$TEST_QT_PREFIX/lib/libQt5Core.dylib" <<< 'int qt_fixture(void) { return 0; }'
    if sh "$root/scripts/check-macos.sh" > "$fixture/rejected.log" 2>&1; then
        printf 'Preflight incorrectly accepted Intel-only Qt for arm64.\n' >&2; exit 1
    fi
    cp "$prefix/lib/libdep.dylib" "$TEST_QT_PREFIX/lib/libQt5Core.dylib"
fi

for name in VeoLinkClient VeoLinkServer; do
    app="$prefix/$name.app"
    mkdir -p "$app/Contents/MacOS"
    /usr/libexec/PlistBuddy -c "Add :CFBundleExecutable string $name" "$app/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string org.veolink.test.$name" "$app/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c 'Add :CFBundlePackageType string APPL' "$app/Contents/Info.plist"
    clang -arch "$VE_MACOS_ARCH" -mmacosx-version-min=11.0 -x c - -o "$app/Contents/MacOS/$name" -L"$prefix/lib" -lwrapper -Wl,-rpath,"$prefix/lib" -Wl,-headerpad_max_install_names <<< 'extern int wrapper(void); int main(void) { return wrapper() == 7 ? 0 : 1; }'
done

bash "$root/maclink.sh"
# Re-running deployment must still traverse already bundled dylibs.
bash "$root/maclink.sh"
mv "$prefix/lib" "$fixture/unavailable-build-libraries"
unset DYLD_LIBRARY_PATH
for name in VeoLinkClient VeoLinkServer; do
    app="$prefix/$name.app"
    "$app/Contents/MacOS/$name"
    codesign --verify --deep --strict "$app"
done
printf 'macOS preflight, recursive deployment, repeat deployment and relocation tests passed.\n'
