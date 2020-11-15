# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="PPSSPPSDL"
PKG_VERSION="087de849bdc74205dd00d8e6e11ba17a591213ab"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/hrydgard/ppsspp"
PKG_URL="https://github.com/hrydgard/ppsspp.git"
PKG_DEPENDS_TARGET="toolchain ffmpeg libzip libpng SDL2-git zlib zip"
PKG_SHORTDESC="PPSSPPDL"
PKG_LONGDESC="PPSSPP Standalone"
GET_HANDLER_SUPPORT="git"
PKG_BUILD_FLAGS="+lto"

PKG_CMAKE_OPTS_TARGET+="-DARMV7=ON  \
                       -DUSE_SYSTEM_FFMPEG=ON \
                       -DUSING_FBDEV=ON \
                       -DUSE_WAYLAND_WSI=OFF \
		       -DCMAKE_BUILD_TYPE=Release \
		       -DCMAKE_SYSTEM_NAME=Linux \
		       -DUSING_GLES2=ON \
                       -DUSING_X11_VULKAN=OFF \
		       -DARM_NO_VULKAN=ON \
                       -DBUILD_SHARED_LIBS=OFF \
		       -DANDROID=OFF \
		       -DWIN32=OFF \
		       -DAPPLE=OFF \
		       -DCMAKE_CROSSCOMPILING=ON \
		       -DVULKAN=OFF \
		       -DUSING_EGL=OFF \
		       -DUSING_QT_UI=OFF \
		       -DUNITTEST=OFF \
		       -DSIMULATOR=OFF \
		       -DHEADLESS=OFF \
                       -fpermissive"

pre_configure_target() {
  sed -i "s|include_directories(/usr/include/drm)|include_directories(${SYSROOT_PREFIX}/usr/include/drm)|" $PKG_BUILD/CMakeLists.txt
}

pre_make_target() {
  # fix cross compiling
  find ${PKG_BUILD} -name flags.make -exec sed -i "s:isystem :I:g" \{} \;
  find ${PKG_BUILD} -name build.ninja -exec sed -i "s:isystem :I:g" \{} \;
}


makeinstall_target() {
  mkdir -p $INSTALL/usr/bin
    cp $PKG_DIR/ppsspp.sh $INSTALL/usr/bin/ppsspp.sh
    cp `find . -name "PPSSPPSDL" | xargs echo` $INSTALL/usr/bin/PPSSPPSDL
    ln -sf /storage/.config/ppsspp/assets $INSTALL/usr/bin/assets
    mkdir -p $INSTALL/usr/config/ppsspp/
    cp -r `find . -name "assets" | xargs echo` $INSTALL/usr/config/ppsspp/
    cp -rf $PKG_DIR/config/* $INSTALL/usr/config/ppsspp/
}
