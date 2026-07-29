# VeoLink CE build environment. Usage: `source ./rules.mk` from the repo root.
#
# Supported baseline: Ubuntu 22.04 / 24.04 x86_64 with the distro toolchain
# (gcc/g++) and distro Qt 5.15 (qtbase5-dev, qt5-qmake). See Readme.md for
# the full package list.

# Repo root. Auto-detected from the current directory when sourced from the
# repo root; override by exporting VE_PATH before sourcing.
export VE_PATH=${VE_PATH:-$(pwd)}

export VE_OS=`lsb_release -si`
export VE_ARCH=`uname -m | sed 's/x86_//;s/i[3-6]86/32/'`
export VE_VER=`lsb_release -sr`
export VE_CROSS_COMPILER=
export VE_INSTALL_DIR=$VE_OS-$VE_VER-$VE_ARCH"bit"
export LD_LIBRARY_PATH=$VE_PATH/output/$VE_INSTALL_DIR/lib/:$LD_LIBRARY_PATH
export PATH=$VE_PATH/output/$VE_INSTALL_DIR"/bin:"$PATH 


