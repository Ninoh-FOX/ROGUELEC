################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="puae"
PKG_VERSION="6bcad0b3f3fd19b4c4d35a4befd7bc9535f7410b"
PKG_SHA256="ab9b4d8027043dfa4b1f20b217fee3290379c953b91a6d393fa94c55bb262a7b"
PKG_REV="1"
PKG_ARCH="arm i386 x86_64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libretro/libretro-uae"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="WIP libretro port of UAE (P-UAE and libco) Expect bugs"
PKG_LONGDESC="WIP libretro port of UAE (P-UAE and libco) Expect bugs"
PKG_TOOLCHAIN="make"

pre_configure_target() {
  if [ "$ARCH" == "arm" ]; then
    CFLAGS="$CFLAGS -DARM -marm"
  fi
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp puae_libretro.so $INSTALL/usr/lib/libretro/
}
