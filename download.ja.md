---
basename: download
lang: ja
title: ダウンロード
---

## コンパイル済みバイナリのインストール

今のところ、Ubuntu用のバイナリのみ提供しています。

### Ubuntu

[TapirのLaunchpad PPA](https://launchpad.net/~qnighy/+archive/ubuntu/tapir)からインストールできます。

```
$ sudo add-apt-repository ppa:qnighy/tapir
$ sudo apt update
$ sudo apt install tapir
```

## ソースコード

ソースコードは[GitHub上](https://github.com/qnighy/tapir)にあります。[安定版リリースのソースコードをダウンロードする](https://github.com/qnighy/tapir/releases)か、以下のようにGitリポジトリをクローンしてください:

```
$ git clone https://github.com/qnighy/tapir.git --recursive
```

[ソースコード中のREADME](https://github.com/qnighy/tapir/blob/master/README.ja.md)に、Tapirのビルド方法が書いてあります。
