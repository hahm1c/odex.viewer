#! /bin/env bash

echo "Checking for running under WSL (Windows Subsystem for Linux)..."
if ! grep -qi "microsoft" /proc/version; then
    echo "This script is intended to run under WSL to be able to build an odex.viewer distribution package for Windows."
    exit 0
fi

echo "Checking for required commands: wget, unzip, git, python3, 7z..."
for cmd in wget unzip git python3 7z; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Missing dependency: '$cmd' is not installed or not in the PATH."
        exit 0
    fi
done

if test -z "$WINPY_URL"; then
    echo "WINPY_URL is not set, using default value"
    WINPY_URL="https://github.com/winpython/winpython/releases/download/17.2.20260307final/WinPython64-3.14.3.0dot.zip"
fi

REPO_ROOT="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")/..")"

echo "Using repository root directory: $REPO_ROOT"
echo "Using WinPython distribution download URL: $WINPY_URL"

TMP_DIR="/tmp/odex-dist"
if test -e "$TMP_DIR"; then
    echo "Temporary directory \"$TMP_DIR\" already exists."
    exit 0
fi

mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

echo "Downloading WinPython distribution from $WINPY_URL..."
wget -O winpython.zip "$WINPY_URL"

echo "Extracting WinPython distribution..."
unzip winpython.zip

WINPY_DIR_TMP="$(ls -d WPy64*)"

echo "Moving WinPython distribution to folder \"odex.viewer-dist\"..."
mv "$WINPY_DIR_TMP" "odex.viewer-dist"

echo "Cloning the odex.viewer repository from $REPO_ROOT..."
git clone "$REPO_ROOT" "odex.viewer"

cd "odex.viewer"

echo "Building the odex.viewer wheel file..."
python3 ./server/scripts/build_package.py

ODEX_VIEWER_VERSION="$(echo ./server/dist/odex_viewer-*.whl | sed "s/.*odex_viewer-\([.0-9]*\)-.*/\1/")"

echo "Copying the odex.viewer wheel file and required files to the distribution folder \"odex.viewer-dist\"..."
cp ./server/dist/odex_viewer-*.whl ../
cp ./scripts/dist.README.md ../odex.viewer-dist/README.md
cp ./scripts/start_odex-viewer.bat ../odex.viewer-dist/start_odex-viewer.bat

cd "../odex.viewer-dist"

chmod a+x "./python/python.exe"

echo "Installing the odex.viewer package into the WinPython distribution..."
./python/python.exe -m pip install ../odex_viewer-*.whl

cd ..

echo "Creating the odex.viewer distribution archive..."
( cd ./odex.viewer-dist && 7z a "../odex.viewer-$ODEX_VIEWER_VERSION.zip" . )

# Creating a self-extracting archive (SFX) for Windows, disabled because of common problems with signature verification.
if test -n "$MAKE_EXE"; then
    echo "Trying to create a self-extracting archive (SFX) for Windows..."
    if test -z "$LZMA_7ZIP_URL"; then
        echo "LZMA_7ZIP_URL is not set, using default value"
        LZMA_7ZIP_URL="https://www.7-zip.org/a/lzma2601.7z"
    fi

    echo "Downloading 7-Zip LZMA SDK from $LZMA_7ZIP_URL..."
    wget -O lzma.7z "$LZMA_7ZIP_URL"

    echo "Extracting 7-Zip LZMA SDK..."
    7z x lzma.7z -o./lzma

    echo "Creating a self-extracting odex.viewer distribution package..."
    printf ";!@Install@!UTF-8!\r\nTitle=\"odex.viewer\"\r\nRunProgram=\"start_odex-viewer.bat\"\r\n;!@InstallEnd@!\r\n" > config.txt

    # First, create a 7z archive of all odex.viewer files
    ( cd ./odex.viewer-dist && 7z a ../odex.viewer.7z . )
    7z l odex.viewer.7z | tail -3

    # Then, combine SFX, config and 7z archive into odex.viewer.exe (the order matters!)
    # dd is used instead of cat to avoid WSL text-mode translation corrupting the binary SFX stub.
    { dd if=./lzma/bin/7zS2.sfx bs=1M && dd if=config.txt bs=1M && dd if=odex.viewer.7z bs=1M; } 2>/dev/null > "odex.viewer-$ODEX_VIEWER_VERSION.exe"

    echo "Successfully created the self-extracting odex.viewer distribution package: $TMP_DIR/odex.viewer-$ODEX_VIEWER_VERSION.exe"
fi

echo "Successfully created the odex.viewer distribution archive: $TMP_DIR/odex.viewer.zip"
