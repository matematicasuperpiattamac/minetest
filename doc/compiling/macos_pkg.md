# Compiling on MacOS

## Requirements

- [Homebrew](https://brew.sh/)
- [Git](https://git-scm.com/downloads)

Install dependencies with homebrew:

```bash
# https://gist.github.com/progrium/b286cd8c82ce0825b2eb3b0b3a0720a0
# use the following cmd to install and use brew for x86 libs
arch -x86_64 zsh
brew install cmake freetype gettext gmp hiredis jpeg-turbo jsoncpp leveldb libogg libpng libvorbis luajit zstd gettext
```

## Download

Download source (this is the URL to the latest of source repository, which might not work at all times) using Git:

```bash
git clone https://github.com/matematicasuperpiattamac/minetest.git ms_client_mac
cd ms_client_mac
```

Download Minetest's fork of Irrlicht:

```bash
git clone https://github.com/minetest/irrlicht.git lib/irrlichtmt
cd lib/irrlichtmt
git checkout 1.9.0mt13
cd ../..
```

## Build

```bash
mkdir build
cd build

cmake .. \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.14 \
    -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_INSTALL_PREFIX=../build/macos/ \
    -DRUN_IN_PLACE=FALSE -DENABLE_GETTEXT=TRUE

make -j$(sysctl -n hw.logicalcpu)
make install
```

## Sign

```bash
cd macos

# to edit
iddev="<NAME> (<ID>)"

# sign libs
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libvorbisfile.3.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libogg.0.8.5.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libsnappy.1.2.1.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libintl.8.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libvorbis.0.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libleveldb.1.23.0.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libpng16.16.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libfreetype.6.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libluajit-5.1.2.1.1716656478.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libzstd.1.5.6.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libjpeg.8.3.2.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libjsoncpp.25.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libhiredis.1.1.0.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libtcmalloc.4.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libgmp.10.dylib

# sign links
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libjpeg.8.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libleveldb.1.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libogg.0.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libluajit-5.1.2.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libsnappy.1.dylib
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/Frameworks/libzstd.1.dylib

# sign binary
codesign --force --verify --verbose --sign "Developer ID Application: ${iddev}" minetest.app/Contents/MacOS/minetest

# sign app
```

## Create Package

```bash
mkdir Scripts
cp ../../Scripts/postinstall Scripts/postinstall
chmod +x Scripts/postinstall

pkgbuild --root "minetest.app" \
         --identifier "com.stemblocks.matematicasuperpiatta" \
         --version "1.1.4" \
         --scripts Scripts \
         --install-location "Applications/Matematica Superpiatta.app" \
         --sign "Developer ID Installer: <NAME> (<ID>)" \
         MatematicaSuperpiatta1.1.4.pkg
         
```
