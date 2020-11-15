# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="eduke"
PKG_VERSION="dfc16b0882fe6ed03aa3e9c7d4948a9ad309f23a"
PKG_ARCH="any"
PKG_LICENSE="GPL2 + BUILDLIC"
PKG_SITE="https://eduke32.com"
PKG_URL="https://voidpoint.io/terminx/eduke32.git"
PKG_DEPENDS_TARGET="toolchain SDL2-git SDL2_mixer timidity"
PKG_LONGDESC="EDuke32 is an awesome, free homebrew game engine and source port of the classic PC first person shooter Duke Nukem 3D"
PKG_TOOLCHAIN="auto"
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="make"

pre_configure_target() {
PKG_MAKE_OPTS_TARGET=" duke3d LTO=0 SDL_TARGET=2 NOASM=1 HAVE_GTK2=0 POLYMER=1 USE_OPENGL=0"
}

makeinstall_target() {
mkdir -p $INSTALL/usr/config/emuelec/bin
cp -rf eduke32 $INSTALL/usr/config/emuelec/bin
}
