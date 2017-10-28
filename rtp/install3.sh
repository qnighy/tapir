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

fetch_license() {
  echo "Downloading the license term..." >&2
  wget -q http://www.rpgmakerweb.com/download/additional/run-time-packages -O - \
    | sed -n -e '/RPG MAKER VX Ace Runtime Package - End User License Agreement (Mar\. 15th, 2012)/,/^<\/div>/p' \
    | sed -e '4s/<li>/1. /; 5s/<li>/2. /; 6s/<li>/3. /; 7s/<li>/4. /; 8s/<li>/5. /; 9s/<li>/6. /; 10s/<li>/7. /; s/<\/\(p\|h4\)>/\n/; s/<[^>]*>\|^ \+//g' \
    > license3.txt
  if ! sha256sum -c - >/dev/null <<EOD
25f0e90d5b540df453a2eeffae0d513173f9942c1f6df3f1eac661be3b719fd2  license3.txt
EOD
  then
    echo "Could not extract the license term." >&2
    return 1
  fi
}

check_license() {
  if [ -e rgss3_rtp_2012_03_15_agreed ]; then
    echo "Already agreed to RTP 2012-03-15 License" >&2
    return 0
  fi
  fetch_license
  while true; do
    echo
    cat license2.txt
    echo
    echo "Agree? [y/n]"
    read answer
    case "$answer" in
      y*|Y*)
        touch rgss3_rtp_2012_03_15_agreed
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
7e93d0ead93a686218b7c671bf099ef42f09f536083bd0b2f0fa6423a39fc19b  $RTP_FILENAME
EOD

echo "Extracting $RTP_FILENAME..." >&2
unzip -o "$RTP_FILENAME"

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
