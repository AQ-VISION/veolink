# Repo root. Auto-detected when sourced from the repo root; override by
# exporting VE_PATH before sourcing.
export VE_PATH=${VE_PATH:-$(pwd)}

export VE_OS=macos
export VE_MACOS_ARCH=${VE_MACOS_ARCH:-$(uname -m)}
case "$VE_MACOS_ARCH" in
    arm64) export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET:-11.0} ;;
    x86_64) export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET:-10.13} ;;
    *) printf 'Unsupported macOS architecture: %s\n' "$VE_MACOS_ARCH" >&2; return 1 ;;
esac
export VE_ARCH=$VE_MACOS_ARCH
export VE_VER=$MACOSX_DEPLOYMENT_TARGET
export VE_CROSS_COMPILER=
export VE_INSTALL_DIR=$VE_OS-$VE_VER-$VE_ARCH
export SDKROOT=${SDKROOT:-$(xcrun --sdk macosx --show-sdk-path)}
export DYLD_LIBRARY_PATH="$VE_PATH/output/$VE_INSTALL_DIR/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
export PATH="$VE_PATH/output/$VE_INSTALL_DIR/bin${VE_QT_PREFIX:+:$VE_QT_PREFIX/bin}:$PATH"

