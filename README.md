# Tapir

<img src="imgs/vxace-title.png" height="150"><img src="imgs/vx-title.png" height="150"><img src="imgs/xp-title.png" height="150">

<img src="imgs/talk1.png" height="150"><img src="imgs/enter-battle1.png" height="150"><img src="imgs/battle1.png" height="150"><img src="imgs/talk2.png" height="150">

Tapir is a re-implementation project of RGSS/RGSS2/RGSS3 game runtimes. In other words, Tapir aims to run RPG Maker XP/VX/VX Ace games on Linux (and other platforms).

TapirはRGSS/RGSS2/RGSS3ゲームエンジンの再実装プロジェクトです。言い換えると、tapirはLinux上(あるいは他のプラットフォーム上)でRPGツクールXP/VX/VX Aceのゲームを動かすことを目標としています。

# How to build / ビルド方法

Following is the instruction for Ubuntu 16.04. It may also work on another platforms.

以下に示すのはUbuntu 16.04でのビルド方法ですが、他のプラットフォームでも同様にしてビルドできるかもしれません。

```
$ sudo apt install build-essential autoconf bison flex libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libfontconfig1-dev libconfig-dev
$ ./autogen.sh
$ ./configure
$ make
$ sudo make install
```

# Install RTPs / RTPのインストール

There are two ways to install RTP. / RTPのインストールには2つの方法があります。

## Installation using Windows or Wine / WindowsまたはWineを用いたインストール

In Windows, RTPs will be installed to these directories by default:

Windowsでは、RTPはデフォルトで以下のディレクトリにインストールされます:

- `C:\Program Files (x86)\Common Files\Enterbrain\RGSS\Standard`
- `C:\Program Files (x86)\Common Files\Enterbrain\RGSS2\RPGVX`
- `C:\Program Files (x86)\Common Files\Enterbrain\RGSS3\RPGVXAce`

(In 32bit windows, `Program Files (x86)` becomes `Program Files`. / 32bitのWindowsでは、 `Program Files (x86)` ではなく `Program Files` になります。)

Tapir currently looks for them in these directories:

Tapirは今のところ、以下のディレクトリを探索します。

- `/usr/local/share/Enterbrain/RGSS/Standard`
- `/usr/local/share/Enterbrain/RGSS2/RPGVX`
- `/usr/local/share/Enterbrain/RGSS3/RPGVXAce`

## Installation using scripts / スクリプトを用いたインストール

You can even install RTPs without Windows or Wine. / WindowsやWineがなくてもRTPをインストールすることができます。

Use the script at your own risk. / このスクリプトは自己責任で使ってください。

```
$ sudo apt install innoextract
$ cd rtp
$ ./install1.sh
$ ./install2.sh
$ ./install3.sh
```

# Run tapir / tapirの実行

Tapir looks for the current directory by default. You can change this by using `-d` option.

Tapirはデフォルトではカレントディレクトリを参照します。`-d`を用いてディレクトリを変更することができます。

```
% tapir -h
Tapir: RGSS (RPG Maker XP, VX and VX Ace) compatible game engine

Usage: ./tapir [-h] [-d DIR] [-1] [-2] [-3] [test] [btest] [console]
    -h      show this help
    -d DIR  move to DIR before running the game
    -1      force RGSS version 1 (RPG Maker XP)
    -2      force RGSS version 2 (RPG Maker VX)
    -3      force RGSS version 3 (RPG Maker VX Ace)
    test    enable test mode
    btest   enable battle test mode
    console show console (not yet implemented)
```

# Configuring tapir / tapirの設定

Tapir reads configuration from `/etc/tapir.cfg` and `$HOME/.tapir.cfg`. This is in the `libconfig` format.

Tapirは `/etc/tapir.cfg` と `$HOME/.tapir.cfg` から設定を読み取ります。設定ファイルは `libconfig` 形式です。

Below is an example configuration file:

以下に設定ファイルの例を挙げます:

```
# Put version-agnostic configs here
rgss:
{
  button1 = "A";
  button2 = "B";
  button3 = "C";
  button4 = "X";
  button5 = "Y";
  button6 = "Z";
  button7 = "L";
  button8 = "R";
  button9 = "";
  button10 = "";
  space = "C";
  enter = "C";
  esc = "B";
  num0 = "B";
  shift = "A";
  key_x = "B";
  key_v = "";
  key_b = "";
  key_a = "X";
  key_s = "Y";
  key_d = "Z";
  key_q = "L";
  key_w = "R";
};

# Put version-specific configs here
rgss1:
{
  key_z = "A";
  key_c = "C";
}

rgss2:
{
  key_z = "C";
  key_c = "";
}

rgss3:
{
  key_z = "C";
  key_c = "";
};
```

# Extracting a game archive / ゲームアーカイブの展開

Often a game is provided in a self-extracting form (i.e. `*.exe). / RPGツクールのゲームは自己展開書庫形式 (`*.exe`) で提供される場合があります。

If the archive was packed by RPG Maker, it can be extracted by cabextract. / RPGツクール標準の自己展開書庫の場合は、cabextractにより展開できます。

```
$ sudo apt install cabextract
$ cabextract -dSakusaku Sakusaku.exe
(it will extract the game to Sakusaku/ directory.)
```
