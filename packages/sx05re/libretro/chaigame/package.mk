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

PKG_NAME="chaigame"
PKG_VERSION="f144ff83a22465d102e0f4a127e638d7b0a7848b"
PKG_SHA256="83b9e1ebfac4fe05e9a86a5bfff6e16084c50fc1ac6a5fb55fd5cd2a74e9a0a5"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/RobLoach/ChaiGame"
PKG_URL="https://github.com/RobLoach/ChaiGame/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="ChaiGame: 2D Game Framework"
PKG_LONGDESC="Framework to create 2D games with ChaiScript."

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"

configure_target() {
  cd $PKG_BUILD
}

makeinstall_target() {
  make install INSTALLDIR="$INSTALL/usr/lib/libretro"
}
