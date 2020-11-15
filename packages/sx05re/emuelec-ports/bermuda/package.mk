# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="bermuda"
PKG_VERSION="cf6bdb68d53a1618967da565a44c931b15daf791"
PKG_SHA256="5e71a82c38a9496baea8a20d6463630f848aa20db9db90de0cccb4e68e159851"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL2"
PKG_SITE="https://github.com/cyxx/bermuda"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2-git"
PKG_LONGDESC="An open-source port of the DOS shoot-em-up Tyrian."
PKG_TOOLCHAIN="make"

pre_configure_target(){
sed -i "s|sdl2-config|${SYSROOT_PREFIX}/usr/bin/sdl2-config|g" $PKG_BUILD/Makefile
}
makeinstall_target() {
  mkdir -p $INSTALL/usr/config/emuelec/bin
  cp bs $INSTALL/usr/config/emuelec/bin
}
