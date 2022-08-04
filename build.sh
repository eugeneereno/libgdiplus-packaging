#!/bin/sh

set -o errexit
# set -o pipefail
# set -o nounset
set -o xtrace

if ! command -v brew > /dev/null; then
  echo " --- Command brew does not exist" >&2
  exit 1
fi

if ! command -v dotnet > /dev/null; then
  echo " --- Command dotnet does not exist" >&2
  exit 1
fi

echo " --- :homebrew: Installing libgdiplus and tools ..."
brew install mono-libgdiplus patchelf

LIBGDIPLUS_VERSION=`brew list --versions | grep libgdiplus | awk -F' ' '{ print $2 }'`
LIBGDIPLUS_VERSION=`echo "$LIBGDIPLUS_VERSION" | sed -r 's/[_]+/./g'`
PATCH_NUMBER="1"

NUGET_PREFIX="ereno.linux-x64"
cd $NUGET_PREFIX.eugeneereno.System.Drawing

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

mkdir -p ./bin

dotnet build -c Release -p:Version=${LIBGDIPLUS_VERSION}.${PATCH_NUMBER}
dotnet pack -c Release -p:Version=${LIBGDIPLUS_VERSION}.${PATCH_NUMBER} -o ./bin/
