#!/bin/sh
set -ue

if [ -z "${PREFIX+x}" ]; then
  PREFIX="/usr/local"
fi
RTP_URL="https://s3-ap-northeast-1.amazonaws.com/degica-prod.product-files/20/xp_rtp104e.exe"
RTP_FILENAME="xp_rtp104e.exe"
RTP_EXTRACT_DIR="xp_rtp"
RTP_INSTALL_DIR="$PREFIX/share/Enterbrain/RGSS/Standard"

fetch_license() {
  echo "Downloading the license term..." >&2
  wget -q http://www.rpgmakerweb.com/download/additional/run-time-packages -O - \
    | sed -n -e '/ON-CLICK LICENSE AGREEMENT FOR RPG MAKER RUNTIME PACKAGE 05\.10\.8/,/^<\/div>/p' \
    | sed -e 's/<\/\(p\|h4\)>/\n/; s/<[^>]*>\|^ \+//g' \
    > license1.txt
  if ! sha256sum -c - >/dev/null <<EOD
837e180eee2c2373dedf8c2a1674a9e88c2b5d0f248959420b1d7b5208600b90  license1.txt
EOD
  then
    echo "Could not extract the license term." >&2
    return 1
  fi
}

check_license() {
  if [ -e rgss1_rtp_2005_10_08_agreed ]; then
    echo "Already agreed to RTP 2005-10-08 License" >&2
    return 0
  fi
  fetch_license
  while true; do
    echo
    cat license1.txt
    echo
    echo "Agree? [y/n]"
    read answer
    case "$answer" in
      y*|Y*)
        touch rgss1_rtp_2005_10_08_agreed
        break;;
      n*|N*)
        exit 1;;
    esac
  done
}


if [ -e "$RTP_FILENAME" ]; then
  echo "Already downloaded $RTP_FILENAME" >&2
else
  check_license
  echo "Downloading $RTP_FILENAME..." >&2
  wget -q "$RTP_URL" -O "$RTP_FILENAME"
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
