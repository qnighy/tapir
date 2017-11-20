# Tapir

<img src="imgs/vxace-title.png" height="150"><img src="imgs/vx-title.png" height="150"><img src="imgs/xp-title.png" height="150">

<img src="imgs/talk1.png" height="150"><img src="imgs/enter-battle1.png" height="150"><img src="imgs/battle1.png" height="150"><img src="imgs/talk2.png" height="150">

TapirはRGSS/RGSS2/RGSS3ゲームエンジンの再実装プロジェクトです。言い換えると、tapirはLinux上(あるいは他のプラットフォーム上)でRPGツクールXP/VX/VX Aceのゲームを動かすことを目標としています。

(English version of this README is at README.md.)

# ビルド方法

以下に示すのはUbuntu 16.04でのビルド方法ですが、他のプラットフォームでも同様にしてビルドできるかもしれません。

```
$ sudo apt install build-essential autoconf automake bison flex libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libfontconfig1-dev libconfig-dev
$ ./autogen.sh
$ ./configure
$ make
$ sudo make install
```

# RTPのインストール

RTPのインストールには2つの方法があります。

## WindowsまたはWineを用いたインストール

Windowsでは、RTPはデフォルトで以下のディレクトリにインストールされます:

- `C:\Program Files (x86)\Common Files\Enterbrain\RGSS\Standard`
- `C:\Program Files (x86)\Common Files\Enterbrain\RGSS2\RPGVX`
- `C:\Program Files (x86)\Common Files\Enterbrain\RGSS3\RPGVXAce`

(32bitのWindowsでは、 `Program Files (x86)` ではなく `Program Files` になります。)

Tapirは今のところ、以下のディレクトリを探索します。

- `/usr/local/share/Enterbrain/RGSS/Standard`
- `/usr/local/share/Enterbrain/RGSS2/RPGVX`
- `/usr/local/share/Enterbrain/RGSS3/RPGVXAce`

## スクリプトを用いたインストール

WindowsやWineがなくてもRTPをインストールすることができます。

このスクリプトは自己責任で使ってください。

```
$ sudo apt install innoextract
$ cd rtp
$ ./install1.sh
$ ./install2.sh
$ ./install3.sh
```

# tapirの実行

Tapirはデフォルトではカレントディレクトリを参照します。`-d`を用いてディレクトリを変更することができます。

```
% tapir -h
Tapir: RGSS (RPG Maker XP, VX and VX Ace) compatible game engine

Usage: ./tapir [-h] [-d DIR] [-1] [-2] [-3] [test] [btest] [console]
    -h      show this help このヘルプを表示する
    -d DIR  move to DIR before running the game ゲーム実行前にDIRに移動
    -1      force RGSS version 1 (RPG Maker XP) RGSSバージョン1を強制
    -2      force RGSS version 2 (RPG Maker VX) RGSSバージョン2を強制
    -3      force RGSS version 3 (RPG Maker VX Ace) RGSSバージョン3を強制
    test    enable test mode テストモード
    btest   enable battle test mode 戦闘テストモード
    console show console (not yet implemented) コンソールを表示 (未実装)
```

# tapirの設定

Tapirは `/etc/tapir.cfg` と `$HOME/.tapir.cfg` から設定を読み取ります。設定ファイルは `libconfig` 形式です。

以下に設定ファイルの例を挙げます:

```
# ここに書いた設定はRGSS全体に適用される
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

# ここに書いた設定はRGSS1, RGSS2, RGSS3に個別に適用される
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

# ゲームアーカイブの展開

RPGツクールのゲームは自己展開書庫形式 (`*.exe`) で提供される場合があります。

RPGツクール標準の自己展開書庫の場合は、cabextractにより展開できます。

```
$ sudo apt install cabextract
$ cabextract -dSakusaku Sakusaku.exe
(このコマンドで、Sakusaku.exeの中身がSakusakuディレクトリに展開されます。)
```

