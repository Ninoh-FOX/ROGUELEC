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

PKG_NAME="yabasanshiro"
PKG_VERSION="73c676680f753e10bfd53ecaf01293ac34b4a678"
PKG_GIT_CLONE_BRANCH="yabasanshiro"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/yabause"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain $OPENGLES"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Port of YabaSanshiro to libretro."
PKG_LONGDESC="Port of YabaSanshiro to libretro."
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

pre_configure_target() { 
  # For some reason linkin to GLESv2 gives error, so we link it to GLESv3
  sed -i "s|-lGLESv2|-lGLESv3|g" $PKG_BUILD/yabause/src/libretro/Makefile.common 

if [[ "$ARCH" == "arm" ]]; then
	if [[ "$DEVICE" == "RG351P" ]]; then
		PKG_MAKE_OPTS_TARGET+=" -C yabause/src/libretro platform=RK3399"
		sed -i "s|-mtune=cortex-a72.cortex-a53|-mtune=cortex-a35|g" $PKG_BUILD/yabause/src/libretro/Makefile
	else
		PKG_MAKE_OPTS_TARGET+=" -C yabause/src/libretro platform=AMLG12B"
	fi
else
	if [[ "$DEVICE" == "RG351P" ]]; then
		sed -i "s|-mtune=cortex-a73.cortex-a53|-mtune=cortex-a35|g" $PKG_BUILD/yabause/src/libretro/Makefile
	fi
	
	if [[ "$PROJECT" == "Amlogic" ]]; then
		sed -i "s|-mtune=cortex-a73.cortex-a53|-mtune=cortex-a53|g" $PKG_BUILD/yabause/src/libretro/Makefile
	fi
	
	PKG_MAKE_OPTS_TARGET+=" -C yabause/src/libretro platform=odroid-n2"
fi
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp yabause/src/libretro/yabasanshiro_libretro.so $INSTALL/usr/lib/libretro/
}
