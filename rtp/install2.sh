#!/bin/sh
set -ue

if [ -z "${PREFIX+x}" ]; then
  PREFIX="/usr/local"
fi
RTP_URL="https://s3-ap-northeast-1.amazonaws.com/degica-prod.product-files/19/vx_rtp102e.zip"
RTP_FILENAME="vx_rtp102e.zip"
RTP_FILENAME2="RPGVX_RTP/Setup.exe"
RTP_EXTRACT_DIR="vx_rtp"
RTP_INSTALL_DIR="$PREFIX/share/Enterbrain/RGSS2/RPGVX"

if [ ! -e "$RTP_FILENAME" ]; then
  echo "Downloading $RTP_FILENAME..." >&2
  wget "$RTP_URL" -O "$RTP_FILENAME"
fi

echo "Extracting $RTP_FILENAME..." >&2
unzip -o "$RTP_FILENAME"

while true; do
  cat RPGVX_RTP/readme.txt
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
    Audio/BGM Audio/BGS Audio/ME Audio/SE Fonts \\
    Graphics/Animations Graphics/Battlers Graphics/Characters \\
    Graphics/Faces Graphics/Parallaxes Graphics/System; do
  install -d "$RTP_INSTALL_DIR/\$dir"
  install -m 644 "$RTP_EXTRACT_DIR/app/\$dir"/* "$RTP_INSTALL_DIR/\$dir"
done
install -m 644 "$RTP_EXTRACT_DIR/app/Game.ico" "$RTP_INSTALL_DIR"
install -m 644 "$RTP_EXTRACT_DIR/app"/*.dll "$RTP_INSTALL_DIR"
EOD
