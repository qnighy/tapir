# Tapir

Tapir is a re-implementation project of RGSS/RGSS2/RGSS3 game engines.

## Dependencies

It works currently on Linux. Porting to Android is planned.

It depends on:

- C/C++ Compiler (e.g. GCC)
- autoconf (used to build Ruby)
- bison/flex (used to build Ruby)
- SDL2 and its development package

## How to build

First, build Ruby1.9.2p0.

```
$ sudo apt install autoconf bison flex
$ ./build-ruby192.sh -j4
```

Next, build Tapir/Accordion.

```
$ cd accordion
$ make
```

## How to use

1. Install Enterbrain's "RPG Maker VX Ace RTP" on your Windows.
2. Copy it into `/usr/local/share/Enterbrain`. Make sure that `/usr/local/share/Enterbrain/RGSS3/RPGVXAce/Game.ico` exists.
3. Copy `accordion/tapir` to the RPG Maker VX Ace game directory, where Game.exe exists.
4. run `./tapir` in the game directory.

## Compatibility

Currently we are working on the game library. This enables us to run non-extended games, such as Sakusaku.

Some distributed scripts make use of Win32API. So we have to fake the API in order to run these scripts.
