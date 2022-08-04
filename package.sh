#!/bin/sh

set -o errexit
# set -o pipefail
# set -o nounset
set -o xtrace

if ! command -v brew > /dev/null; then
  echo " --- Command brew does not exist" >&2
  exit 1
fi

echo " --- :homebrew: Installing libgdiplus and tools ..."
brew install mono-libgdiplus patchelf

cd runtime.linux-x64.eugeneereno.System.Drawing

OUT=$(pwd)/out/usr/local/lib
rm -rf $OUT

mkdir -p $OUT

HOMEBREW_LIB=/home/linuxbrew/.linuxbrew/lib
LIBGDIPLUS_SHARED_OBJ=$HOMEBREW_LIB/libgdiplus.so
LIBGDIPLUS_DEPS=`ldd "$LIBGDIPLUS_SHARED_OBJ" | grep "/home/linuxbrew/.linuxbrew/" | awk -F' ' '{ print $3 }'`

cp $HOMEBREW_LIB/libgdiplus.so* "$OUT/"

for SHARED_OBJ in $LIBGDIPLUS_DEPS; do
  cp $SHARED_OBJ "$OUT/"
done;

echo " --- :ldd: Printing libcairo dependencies ..."
ldd $OUT/libcairo.so.2

echo " --- :ldd: Printing libxcb dependencies ..."
ldd $OUT/libxcb.so.1

echo " --- :ldd: Printing libglib dependencies ..."
ldd $OUT/libglib-2.0.so.0

echo " --- :patch: Patching dependencies ..."
for FILE in "$OUT/"*.so*; do
  chmod +w "$FILE"

  SHARED_OBJS=`ldd "$FILE" | grep "/home/linuxbrew/.linuxbrew/" | awk -F' ' '{ print $3 }'`

  for OBJ in $SHARED_OBJS; do
    BASENAME=`basename "$OBJ"`

    if [ ! -f "$OUT/$BASENAME" ]; then
      echo " --- :ERROR: The shared object file '$OUT/$BASENAME' does not exist in the output folder; referenced from $FILE" 1>&2
      exit 1
    fi

    patchelf --set-rpath \$ORIGIN $FILE
  done;
done

