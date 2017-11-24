---
basename: usage
lang: ja
title: 使い方
---

## Tapirの入手

[ダウンロード](download.ja.html)のページを参照してください。

## ゲームの入手

Tapir自体はゲームではなく、単なるエミュレータ(のようなもの)です。RPGツクール製のゲームは例えば、[ふりーむ](https://www.freem.ne.jp/)、[DLsite](http://www.dlsite.com/)、[Steam](http://store.steampowered.com/tag/ja/RPGMaker/)などで配布・販売されています。

## ゲームの展開

RPGツクール製のゲームはZIPかEXEの形で配布されていることが多いです。

### ZIPの展開

多くの場合、ファイル名の文字コードを指定する必要があります。日本語版WindowsのデフォルトがCP932なので、 `unzip -O cp932` とするとよいことがほとんどです。

例えば、[Hero and Daughter](https://gamemaga.denfaminicogamer.jp/had/)というゲームのZIPは以下のように展開できます。

```
$ unzip -O cp932 Hero_and_Daughter_3c.zip
```

### EXEの展開

RPGツクールのEXEは、[cabextract](https://www.cabextract.org.uk/)で展開できる場合がほとんどです。

例えば、[ぼくらの大革命](http://www.vector.co.jp/soft/dl/winnt/game/se501851.html)をダウンロードしてくると、まずZIPが目に入るので、上記の方法で解凍します。

```
$ unzip -O cp932 daikakumei.zip
Archive:  daikakumei.zip
  inflating: ぼくらの大革命！ver15.exe
```

するとEXEが出てきます。これは、このゲームを展開するのにもう一手間必要ということです。ここでcabextractを使います。

```
$ cabextract -d daikakumei ぼくらの大革命！ver15.exe
```

なお、一般論として、このように展開をするときは、**展開先のサブディレクトリを指定**するのが無難です。そうしないと作業ディレクトリがむちゃくちゃなことになります。

## ゲームの実行

ゲームを展開したら、`tapir` コマンドによりそれを遊ぶことができます。 `Game.ini` があるディレクトリまで移動して、以下のコマンドを実行してください。

```
$ tapir
```

あるいは、`cd`で移動するかわりに、 `tapir -d ゲーム/ディレクトリ/の/ある/場所` のようにして起動することもできます。

