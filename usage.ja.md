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

## 設定

Linuxでは、Tapirは [`libconfig`](https://hyperrealm.github.io/libconfig/) を使って設定を読み込みます。

### 設定の場所

Tapirは以下の設定ファイルを読み込みます:

- `$HOME/.tapir.cfg`
- `/etc/tapir.cfg`

### 設定のフォーマット

設定は[libconfigフォーマット](https://hyperrealm.github.io/libconfig/libconfig_manual.html#Configuration-Files)に従います。大雑把にいうと次のようなフォーマットです:

- `#` で始まる行はコメントです。 `//` と `/* */` も使えます。
- `hoge = "foo";` と書くと、 `hoge` というフィールドに `"foo"` という文字列を割り当てることになります。整数、浮動小数点数、配列、リスト、ブール値も書けます。
- `hoge: { fuga = "bar"; piyo = "baz"; }` と書くと、 `hoge` は2つの設定をまとめたものになります。

Tapirは以下の設定フィールドを参照します:

|パス|例|説明|
|-|-|-|
|`rgss.KEY`|`rgss: { key_z = "C"; }`|キー割り当て。下を参照。|
|`rgssN.KEY`|`rgss1: { key_z = "C"; }`|特定のRGSSバージョンに対するキー割り当て。|
|`rgssN.rtp.RTPNAME`|`rgss3: { rtp: { RPGVXAce = "/usr/share/Enterbrain/RGSS3/RPGVXAce"; }}`|特定のRTP名に対するパス割り当て。|
|`rgss.rtp_base_path`|`rgss: { rtp_base_path: "/usr/share/Enterbrain";}`|RTPのデフォルト探索先。|
{: .pure-table}

### キー割り当て

RGSSとTapirは、外部からのキー入力を、内部的な値に変換しています。

外部から受け付けるキーとデフォルトの変換は以下の通りです:

|キー|説明|デフォルト|
|-|-|-|
|`button1`|ゲームパッドのボタン1|A|
|`button2`|ゲームパッドのボタン2|B|
|`button3`|ゲームパッドのボタン3|C|
|`button4`|ゲームパッドのボタン4|X|
|`button5`|ゲームパッドのボタン5|Y|
|`button6`|ゲームパッドのボタン6|Z|
|`button7`|ゲームパッドのボタン7|L|
|`button8`|ゲームパッドのボタン8|R|
|`button9`|ゲームパッドのボタン9|-|
|`button10`|ゲームパッドのボタン10|-|
|`space`|スペースキー|C|
|`enter`|Enter|C|
|`esc`|Escape|B|
|`num0`|テンキーの0|B|
|`shift`|Shift|A|
|`key_z`|Z|C (RGSS1ではA)|
|`key_x`|X|B|
|`key_c`|C|- (RGSS1ではC)|
|`key_v`|V|-|
|`key_b`|B|-|
|`key_a`|A|X|
|`key_s`|S|Y|
|`key_d`|D|Z|
|`key_q`|Q|L|
|`key_w`|W|R|
{: .pure-table}

例えば、RGSS1で `key_z` を C に割り当て、 `key_c` には何も割り当てないようにするには、以下のような設定を書きます:

```
rgss1: {
  key_z = "C";
  key_c = "";
}
```

全てのRGSSバージョンで `key_v` に R を割り当てるには、以下のようにします:

```
rgss: {
  key_v = "R";
}
```

### RTPパス

Tapirは以下の3箇所にRTPを探しに行きます:

- `rgssN.rtp.RTPNAME` ただしRTPNAMEは `Game.ini` で指定されているRTP名
- `rgss.rtp_base_path` で指定されたものに `RGSS`/`RGSS2`/`RGSS3` と RTPNAME を連結したもの
- `rgss.rtp_base_path` のデフォルトのデフォルト

RTPNAMEはほとんどの場合、 RGSS3では `RPGVXAce`, RGSS2 では `RPGVX`, RGSS1 では `Standard` です。そのため、以下のようにすればRTPの位置を指定できます:

```
rgss3: {
  rtp: {
    RPGVXAce = "/home/someone/share/Enterbrain/RGSS3/RPGVXAce";
  }
}
rgss2: {
  rtp: {
    RPGVX = "/home/someone/share/Enterbrain/RGSS2/RPGVX";
  }
}
rgss1: {
  rtp: {
    Standard = "/home/someone/share/Enterbrain/RGSS/Standard";
  }
}
```

RTPの位置は上記のように規則的であることが多いので、デフォルトだけ指定すれば十分です。

```
rgss: {
  rtp_base_path = "/home/someone/share/Enterbrain";
}
```

もし `rtp_base_path` すらも指定されていない場合は、デフォルトのデフォルトが採用されます。デフォルトのデフォルトは、以下のいずれかです:

- `/usr/share/Enterbrain`
- `/usr/local/share/Enterbrain`

これらのうち、RTPが入ってそうなほうがデフォルトのデフォルトとして使われます。
