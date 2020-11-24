# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL_GameControllerDB"
PKG_VERSION="5de6aa0a1d1a9249a272843e7aba8cdbd601e188"
PKG_LICENSE="OSS"
PKG_SITE="https://github.com/gabomdq/SDL_GameControllerDB"
#PKG_SITE="https://github.com/gabomdq/gamecontrollerdb"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET=""
PKG_LONGDESC="A community sourced database of game controller mappings to be used with SDL2 Game Controller functionality"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p $INSTALL/usr/config/SDL-GameControllerDB
  cp $PKG_BUILD/gamecontrollerdb.txt $INSTALL/usr/config/SDL-GameControllerDB
}
