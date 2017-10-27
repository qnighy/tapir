#!/bin/sh
set -ue

if [ -z "${PREFIX+x}" ]; then
  PREFIX="/usr/local"
fi
RTP_URL="https://s3-ap-northeast-1.amazonaws.com/degica-prod.product-files/20/xp_rtp104e.exe"
RTP_FILENAME="xp_rtp104e.exe"
RTP_EXTRACT_DIR="xp_rtp"
RTP_INSTALL_DIR="$PREFIX/share/Enterbrain/RGSS/Standard"

if [ ! -e "$RTP_FILENAME" ]; then
  echo "Downloading $RTP_FILENAME..." >&2
  wget "$RTP_URL" -O "$RTP_FILENAME"
fi

echo "Checking integrity of $RTP_FILENAME..." >&2
sha256sum -c - <<EOD
b3bd20ad7f413b40ac233aafd2e061de1dc429c2eadb59d0b3157ba3c47f16b2  $RTP_FILENAME
EOD

echo "Extracting $RTP_FILENAME..." >&2
mkdir -p "$RTP_EXTRACT_DIR"
innoextract -s -d "$RTP_EXTRACT_DIR" "$RTP_FILENAME"

echo "Installing RTP to $RTP_INSTALL_DIR..." >&2
sudo sh -ue <<EOD
for dir in \\
    Audio/BGM Audio/BGS Audio/ME Audio/SE \\
    Graphics/Animations Graphics/Autotiles Graphics/Battlebacks \\
    Graphics/Battlers Graphics/Characters Graphics/Fogs Graphics/Gameovers \\
    Graphics/Icons Graphics/Panoramas Graphics/Tilesets \\
    Graphics/Titles Graphics/Transitions Graphics/Windowskins; do
  install -d "$RTP_INSTALL_DIR/\$dir"
  install -m 644 "$RTP_EXTRACT_DIR/app/\$dir"/* "$RTP_INSTALL_DIR/\$dir"
done
install -d "$RTP_INSTALL_DIR/Graphics/Pictures"
install -m 644 "$RTP_EXTRACT_DIR/app/Game.ico" "$RTP_INSTALL_DIR"
EOD
