#!/bin/bash
set -euo pipefail

: "${VE_PATH:?Source rules-macos.mk first.}"
: "${VE_INSTALL_DIR:?Source rules-macos.mk first.}"
: "${VE_MACOS_ARCH:?Source rules-macos.mk first.}"
install_dir="$VE_PATH/output/$VE_INSTALL_DIR"
qt_bin="$("${QMAKE:-qmake}" -query QT_HOST_BINS)"
qt_lib="$("${QMAKE:-qmake}" -query QT_INSTALL_LIBS)"
macdeployqt="${MACDEPLOYQT:-$qt_bin/macdeployqt}"
[ -x "$macdeployqt" ] || { printf 'macdeployqt not found: %s\n' "$macdeployqt" >&2; exit 1; }

# Resolve and bundle non-system dylibs as well as the Qt frameworks.
deploy_binary() {
    local binary="$1" original="$2" frameworks="$3"
    local dependency relative source name destination directory rpath seen
    for seen in "${deployed[@]}"; do [ "$seen" != "$binary" ] || return 0; done
    deployed+=("$binary")
    while IFS= read -r dependency; do
        case "$dependency" in
            /System/Library/*|/usr/lib/*) continue ;;
            *.framework/*) continue ;; # macdeployqt deploys the Qt frameworks.
        esac
        source=
        case "$dependency" in
            @loader_path/*) source="$(dirname "$original")/${dependency#@loader_path/}" ;;
            @executable_path/*) source="$(dirname "$binary")/${dependency#@executable_path/}" ;;
            @rpath/*) relative="${dependency#@rpath/}" ;;
            /*) source="$dependency" ;;
            *) relative="$dependency" ;;
        esac
        if [ -z "$source" ]; then
            for directory in "$install_dir/lib" "$frameworks" "$qt_lib"; do
                if [ -f "$directory/$relative" ]; then source="$directory/$relative"; break; fi
            done
        fi
        [ -f "$source" ] || { printf 'Unresolved dependency %s in %s\n' "$dependency" "$binary" >&2; exit 1; }
        name="$(basename "$source")"
        destination="$frameworks/$name"
        seen=
        for directory in "${deployed[@]}"; do
            if [ "$directory" = "$destination" ]; then seen=yes; break; fi
        done
        if [ -z "$seen" ]; then
            if [ "$source" != "$destination" ]; then
                cp -L "$source" "$destination"
            fi
            chmod u+w "$destination"
            xcrun lipo -verify_arch "$VE_MACOS_ARCH" "$destination"
            install_name_tool -id "@rpath/$name" "$destination"
            deploy_binary "$destination" "$source" "$frameworks"
        fi
        install_name_tool -change "$dependency" "@rpath/$name" "$binary"
    done < <(otool -L "$binary" | sed '1d; s/^[[:space:]]*//; s/ (compatibility version.*$//')

    # Remove build-machine search paths from the deployable binaries.
    while IFS= read -r rpath; do
        case "$rpath" in
            /*) install_name_tool -delete_rpath "$rpath" "$binary" ;;
        esac
    done < <(otool -l "$binary" | awk '/cmd LC_RPATH/ { getline; getline; print $2 }')
    rpath='@loader_path'
    if [ "$(dirname "$binary")" != "$frameworks" ]; then rpath='@executable_path/../Frameworks'; fi
    if ! otool -l "$binary" | awk '/cmd LC_RPATH/ { getline; getline; print $2 }' | grep -Fxq "$rpath"; then
        install_name_tool -add_rpath "$rpath" "$binary"
    fi
}

for name in VeoLinkClient VeoLinkServer; do
    deployed=("")
    app="$install_dir/$name.app"
    binary="$app/Contents/MacOS/$name"
    [ -f "$binary" ] || { printf 'Build %s before packaging.\n' "$name" >&2; exit 1; }
    xcrun lipo -verify_arch "$VE_MACOS_ARCH" "$binary"
    "$macdeployqt" "$app" -libpath="$install_dir/lib" -always-overwrite
    frameworks="$app/Contents/Frameworks"
    mkdir -p "$frameworks"
    deploy_binary "$binary" "$binary" "$frameworks"
    resources="$app/Contents/Resources/translations"
    mkdir -p "$resources"
    for translation in "$VE_PATH"/client/src/main/translations/*.qm "$VE_PATH"/veuilib/src/translations/*.qm; do
        [ ! -f "$translation" ] || cp "$translation" "$resources/"
    done
    # install_name_tool invalidates arm64 signatures; sign local builds again.
    codesign --force --deep --sign - "$app"
    codesign --verify --deep --strict "$app"
done
