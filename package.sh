#!/bin/sh

set -o errexit
# set -o pipefail
# set -o nounset
set -o xtrace

LIBGDIPLUS_VERSION="6.0.5"

if ! command -v brew > /dev/null; then
  echo " --- Command brew does not exist" >&2
  exit 1
fi

if ! command -v git > /dev/null; then
  echo " --- Command git does not exist" >&2
  exit 1
fi

echo " --- :homebrew: Installing dev tools ..."
brew install autoconf automake libtool pkg-config

cd runtime.linux-x64.eugeneereno.System.Drawing

echo " --- :git: Downloading sources ..."
rm -rf libgdiplus
git clone https://github.com/mono/libgdiplus --depth 1 --single-branch --branch ${LIBGDIPLUS_VERSION}

echo " --- :homebrew: Installing dependencies ..."
brew install libtiff giflib libjpeg glib-utils glib cairo freetype fontconfig libpng

export LDFLAGS="-L/home/linuxbrew/.linuxbrew/opt/libffi/lib"
export PKG_CONFIG_PATH="/home/linuxbrew/.linuxbrew/opt/libffi/lib/pkgconfig"

rm -rf out/usr/local

cd libgdiplus
./autogen.sh --prefix=$(pwd)/../out/usr/local \
  CPPFLAGS="-I/home/linuxbrew/.linuxbrew/include" \
  --without-x11 \
  --with-cairo

make clean
make
# make check
make install

cd $(pwd)/..
ldd out/usr/local/lib/libgdiplus.so

# SHARED_OBJS=`ldd "out/usr/local/lib/libgdiplus.so" | grep "/lib/x86_64-linux-gnu/" | awk -F' ' '{ print $1 }'`
