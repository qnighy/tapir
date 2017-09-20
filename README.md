# Tapir

<img src="imgs/vx-title.png" height="150">

Tapir is a re-implementation project of RGSS/RGSS2/RGSS3 game engines. In other words, Tapir aims to run RPG Maker XP/VX/VX Ace games on Linux (and other platforms).

TapirはRGSS/RGSS2/RGSS3ゲームエンジンの再実装プロジェクトです。言い換えると、tapirはLinux上(あるいは他のプラットフォーム上)でRPGツクールXP/VX/VX Aceのゲームを動かすことを目標としています。

# How to build / ビルド方法

Following is the instruction for Ubuntu 16.04. It may also work on another platforms.

以下に示すのはUbuntu 16.04でのビルド方法ですが、他のプラットフォームでも同様にしてビルドできるかもしれません。

## Install dependencies / 依存関係のインストール

```
$ sudo apt install build-essential autoconf bison flex libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libfontconfig1-dev
```

## Compile Ruby / Rubyのコンパイル

RGSS/RGSS2 are based on Ruby 1.8.1. RGSS3 is based on Ruby 1.9.2p0. These versions with some patches are included in this repository.

RGSS/RGSS2はRuby 1.8.1, RGSS3はRuby 1.9.2p0をベースにしています。これらのRubyバージョンにパッチを当てたものを、このリポジトリに同梱しています。

```
$ git submodule update --init
$ ./build-ruby181.sh
$ ./build-ruby192.sh
```

## Compile tapir / tapirのコンパイル

```
$ make
```

This will make three binaries: `accordion/tapir-a`, `violin/tapir-v`, and `xylophone/tapir-x`. Accordion, Violin, and Xylophone are for RGSS3 (VX Ace), RGSS2 (VX), and RGSS (XP), respectively.

これにより `accordion/tapir-a`, `violin/tapir-v`, `xylphone/tapir-x` という3つのバイナリが生成されます。 Accordion, Violin, Xylophoneという名前はそれぞれ、RGSS3 (VX Ace), RGSS2 (VX), RGSS (XP) のためのバージョンを意味しています。

# Install RTPs / RTPのインストール

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

# Run tapir / tapirの実行

Tapir looks for the current directory by default. You can change this by using `-d` option.

Tapirはデフォルトではカレントディレクトリを参照します。`-d`を用いてディレクトリを変更することができます。

```
% accordion/tapir-a -h
Tapir-accordion: RGSS3 (RPG Maker VX Ace) compatible game engine

Usage: ./tapir [-h] [-d DIR] [test] [btest] [console]
    -h      show this help
    -d DIR  move to DIR before running the game
    test    enable test mode
    btest   enable battle test mode
    console show console (not yet implemented)
```
