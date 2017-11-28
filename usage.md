---
basename: usage
lang: en
title: Usage
---

## Getting Tapir

Please see [download](download.html) page.

## Obtaining a game

Tapir itself is not a game. You can download or buy RPG Maker games, for example, at [Freem (Japanese)](https://www.freem.ne.jp/), [DLsite (Japanese)](http://www.dlsite.com/), and [Steam](http://store.steampowered.com/tag/en/RPGMaker/).

## Extracting a game

RPG Maker games are typically distributed in a ZIP or EXE archive.

### Extracting a ZIP archive

Mostly you'll have to specify the encoding for filenames. This is typically `unzip -O cp932`, because it is the default for Japanese Windows environment.

For example, if you downloaded a game [Hero and Daughter (Japanese)](https://gamemaga.denfaminicogamer.jp/had/), you can extract the zip like this:

```
$ unzip -O cp932 Hero_and_Daughter_3c.zip
```

### Extracting an EXE archive

In most cases, EXE archives for RPG Maker games can be unpacked with [cabextract](https://www.cabextract.org.uk/).

For example, if you downloaded a game [ぼくらの大革命](http://www.vector.co.jp/soft/dl/winnt/game/se501851.html), you'll at first see a ZIP file.

```
$ unzip -O cp932 daikakumei.zip
Archive:  daikakumei.zip
  inflating: ぼくらの大革命！ver15.exe
```

Then you'll figure out you have to extract it for the second time!. Then you can use cabextract.

```
$ cabextract -d daikakumei ぼくらの大革命！ver15.exe
```

Note that in general, you should be enough careful to **specify subdirectory to extract to**. Otherwise you may mess up your working directory.

## Playing a game

You can use the `tapir` command to play the game you extracted. Move to the directory where `Game.ini` exists and just type:

```
$ tapir
```

Or, invoke `tapir -d path/to/game/directory`.

## Configuring

In Linux, we use [`libconfig`](https://hyperrealm.github.io/libconfig/) to make Tapir configurable.

### Location

Tapir looks for configuration files in the following places:

- `$HOME/.tapir.cfg`
- `/etc/tapir.cfg`

### File format

Configuration is in [libconfig format](https://hyperrealm.github.io/libconfig/libconfig_manual.html#Configuration-Files). Here is a brief description of the format:

- Lines starting with `#` are comments. You can also use `//`, and `/* */`.
- `hoge = "foo";` means a field `hoge` has a string value `"foo"`. You can also use integer, floating point, array, list, and boolean values.
- `hoge: { fuga = "bar"; piyo = "baz"; }` means a field `hoge` is a set of two fields.

This is a list of fields that are accepted by Tapir:

|Path|Example|Description|
|-|-|-|
|`rgss.KEY`|`rgss: { key_z = "C"; }`|Key assignments. See below for details.|
|`rgssN.KEY`|`rgss1: { key_z = "C"; }`|Key assignments for specific RGSS version.|
|`rgssN.rtp.RTPNAME`|`rgss3: { rtp: { RPGVXAce = "/usr/share/Enterbrain/RGSS3/RPGVXAce"; }}`|RTP Path for a specific RTP name in `Game.ini`.|
|`rgss.rtp_base_path`|`rgss: { rtp_base_path: "/usr/share/Enterbrain";}`|Default place to look for RTP.|
{: .pure-table}

### Key assignment

RGSS and Tapir maps external key codes to internal inputs.

Here is a list of external keys:

|Key|Description|Default map|
|-|-|-|
|`button1`|Gamepad Button 1|A|
|`button2`|Gamepad Button 2|B|
|`button3`|Gamepad Button 3|C|
|`button4`|Gamepad Button 4|X|
|`button5`|Gamepad Button 5|Y|
|`button6`|Gamepad Button 6|Z|
|`button7`|Gamepad Button 7|L|
|`button8`|Gamepad Button 8|R|
|`button9`|Gamepad Button 9|-|
|`button10`|Gamepad Button 10|-|
|`space`|SPACE key|C|
|`enter`|Enter|C|
|`esc`|Escape|B|
|`num0`|0 on the numpad|B|
|`shift`|Shift|A|
|`key_z`|Z|C (In RGSS1, A)|
|`key_x`|X|B|
|`key_c`|C|- (In RGSS1, C)|
|`key_v`|V|-|
|`key_b`|B|-|
|`key_a`|A|X|
|`key_s`|S|Y|
|`key_d`|D|Z|
|`key_q`|Q|L|
|`key_w`|W|R|
{: .pure-table}

For example, if you want to map `key_z` to C and `key_c` to nothing in RGSS1, the corresponding configuration will be the following:

```
rgss1: {
  key_z = "C";
  key_c = "";
}
```

If you want to assign `R` to `key_v` in all RGSS versions:

```
rgss: {
  key_v = "R";
}
```

### RTP Path

Tapir looks for RTP Path in these three ways:

- `rgssN.rtp.RTPNAME`, where RTPNAME is specified in `Game.ini`
- `rgss.rtp_base_path` concatenated by `RGSS`/`RGSS2`/`RGSS3` and RTPNAME.
- Ground default of `rgss.rtp_base_path`.

RTPNAME is typically `RPGVXAce` for RGSS3, `RPGVX` for RGSS2, and `Standard` for RGSS. Therefore you can specify RTP path in the following way:

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

However, since the paths are very regular, you can just specify a default base path.

```
rgss: {
  rtp_base_path = "/home/someone/share/Enterbrain";
}
```

If `rtp_base_path` isn't even specified, Tapir employs a ground default. The ground default is one of the following:

- `/usr/share/Enterbrain`
- `/usr/local/share/Enterbrain`

Tapir uses as a ground default any one of the above which seems to contain RTP.
