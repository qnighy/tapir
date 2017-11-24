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
