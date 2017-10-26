#!/bin/sh
set -ue

if [ -z "${PREFIX+x}" ]; then
  PREFIX="/usr/local"
fi
RTP_URL="http://cached-downloads.degica.com/degica-downloads/RPGVXAce_RTP.zip"
RTP_FILENAME="RPGVXAce_RTP.zip"
RTP_FILENAME2="RTP100/Setup.exe"
RTP_EXTRACT_DIR="vxace_rtp"
RTP_INSTALL_DIR="$PREFIX/share/Enterbrain/RGSS3/RPGVXAce"

if [ ! -e "$RTP_FILENAME" ]; then
  echo "Downloading $RTP_FILENAME..." >&2
  wget "$RTP_URL" -O "$RTP_FILENAME"
fi

echo "Extracting $RTP_FILENAME..." >&2
unzip -o "$RTP_FILENAME"

while true; do
  cat RTP100/ReadMe.txt
  echo
  echo
  echo "Agree? [y/n]"
  read answer
  case "$answer" in
    y*|Y*)
      break;;
    n*|N*)
      exit 1;;
  esac
done

echo "Extracting $RTP_FILENAME2..." >&2
mkdir -p "$RTP_EXTRACT_DIR"
innoextract -s -d "$RTP_EXTRACT_DIR" "$RTP_FILENAME2"

echo "Installing RTP to $RTP_INSTALL_DIR..." >&2
sudo sh -ue <<EOD
for dir in \\
    Audio/BGM Audio/BGS Audio/ME Audio/SE Fonts/VLGothic \\
    Graphics/Animations Graphics/Battlebacks1 Graphics/Battlebacks2 \\
    Graphics/Battlers Graphics/Characters Graphics/Faces \\
    Graphics/Parallaxes Graphics/System Graphics/Tilesets \\
    Graphics/Titles1 Graphics/Titles2; do
  install -d "$RTP_INSTALL_DIR/\$dir"
  install -m 644 "$RTP_EXTRACT_DIR/app/\$dir"/* "$RTP_INSTALL_DIR/\$dir"
done
install -m 644 "$RTP_EXTRACT_DIR/app/Fonts"/*.ttf "$RTP_INSTALL_DIR/Fonts"
install -m 644 "$RTP_EXTRACT_DIR/app/Game.ico" "$RTP_INSTALL_DIR"
EOD
