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

PKG_NAME="meowpc98"
PKG_VERSION="b005f6b7f608e22ab33bccafe581c62a025050bb"
PKG_SHA256="97f01caac41bd909bdcf0f3dbc31aabfff77da06b6f6e329e2be5221c514921f"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="Unknown"
PKG_SITE="https://github.com/libretro/libretro-meowPC98"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Neko Project 2 (PC98 emulator) port for libretro/RetroArch"
PKG_LONGDESC="Neko Project 2 (PC98 emulator) port for libretro/RetroArch"

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"

make_target() {
  make -C libretro -f Makefile.libretro
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp libretro/nekop2_libretro.so $INSTALL/usr/lib/libretro/
}
