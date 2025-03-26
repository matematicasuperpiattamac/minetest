# Compiling on Windows using MSVC

## Requirements

- [Visual Studio 2015 or newer](https://visualstudio.microsoft.com)
- [CMake](https://cmake.org/download/)
- [vcpkg](https://github.com/Microsoft/vcpkg)
- [Git](https://git-scm.com/downloads)


## Download Minetest's fork of Irrlicht (Obsolete, now irrlicht is included in the repo):

```bash
git clone https://github.com/minetest/irrlicht.git lib/irrlichtmt
cd lib/irrlichtmt
git checkout 1.9.0mt13
cd ../..
```

## Compiling and installing the dependencies

It is highly recommended to use vcpkg as package manager.

After you successfully built vcpkg you can easily install the required libraries:
```powershell
vcpkg install zlib zstd curl[winssl] openal-soft libvorbis libogg libjpeg-turbo sqlite3 freetype luajit gmp jsoncpp opengl-registry gettext --triplet x64-windows
```

- `curl` is optional, but required to read the serverlist, `curl[winssl]` is required to use the content store.
- `openal-soft`, `libvorbis` and `libogg` are optional, but required to use sound.
- `luajit` is optional, it replaces the integrated Lua interpreter with a faster just-in-time interpreter.
- `gmp` and `jsoncpp` are optional, otherwise the bundled versions will be compiled
- `gettext` is optional, but required to use translations.

There are other optional libraries, but they are not tested if they can build and link correctly.

Use `--triplet` to specify the target triplet, e.g. `x64-windows` or `x86-windows`.


## Compile Minetest

### Using the vcpkg toolchain and the commandline

Run the following script in PowerShell:

```cmd
path/to/cmake.exe . -G"Visual Studio 17 2022" -DCMAKE_TOOLCHAIN_FILE=path/to/vcpkg/scripts/buildsystems/vcpkg.cmake -DCMAKE_BUILD_TYPE=Release -DGETTEXT_MSGFMT=path/to/msgfmt.exe -DRUN_IN_PLACE=FALSE
path/to/cmake.exe --build . --config Release
```

Run the following script to create the msi installer (REMEMBER TO INSTALL WiX Toolset before proceeding)
```cmd
path/to/cmake.exe --build . --config Release --target PACKAGE
```
Make sure that the right compiler is selected and the path to the vcpkg toolchain is correct.


## Windows Installer using WiX Toolset

Requirements:
* [Visual Studio 2017](https://visualstudio.microsoft.com/)
* [WiX Toolset](https://wixtoolset.org/)

In the Visual Studio 2017 Installer select **Optional Features -> WiX Toolset**.

Build the binaries as described above, but make sure you unselect `RUN_IN_PLACE`.

Open the generated project file with Visual Studio. Right-click **Package** and choose **Generate**.
It may take some minutes to generate the installer.
