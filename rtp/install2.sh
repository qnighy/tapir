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

fetch_license() {
  echo "Downloading the license term..." >&2
  wget -q http://www.rpgmakerweb.com/download/additional/run-time-packages -O - \
    | sed -n -e '/ON-CLICK LICENSE AGREEMENT FOR RPG MAKER RUNTIME PACKAGE 08\.02\.29/,/^<\/div>/p' \
    | sed -e 's/<\/\(p\|h4\)>/\n/; s/<[^>]*>\|^ \+//g' \
    > license2.txt
  if ! sha256sum -c - >/dev/null <<EOD
f84396d95777f2470123f52ee395b4ede559a89a5849ff85f7c2b075747d290c  license2.txt
EOD
  then
    echo "Could not extract the license term." >&2
    return 1
  fi
}

check_license() {
  if [ -e rgss2_rtp_2008_02_29_agreed ]; then
    echo "Already agreed to RTP 2008-02-29 License" >&2
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
        touch rgss2_rtp_2008_02_29_agreed
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
8c82c02c876391d9585934454a629748d71b421c4957ada1dff8dc4b013ce403  $RTP_FILENAME
EOD

echo "Extracting $RTP_FILENAME..." >&2
unzip -o "$RTP_FILENAME"

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
