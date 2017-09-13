# Tapir

Tapir is a re-implementation project of RGSS/RGSS2/RGSS3 game engines. In other words, Tapir aims to run RPG Maker XP/VX/VX Ace games on Linux (and other platforms).

# How to build

Following is the instruction for Ubuntu 16.04. It may also work on another platforms.

## Install dependencies

```
$ sudo apt install build-essential autoconf bison flex libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev
```

## Compile Ruby

RGSS/RGSS2 are based on Ruby 1.8.1. RGSS3 is based on Ruby 1.9.2p0. These versions with some patches are included in this repository.

```
$ git submodule update --init
$ ./build-ruby181.sh
$ ./build-ruby192.sh
```

## Compile tapir

```
$ make
```

This will make three binaries: `accordion/tapir-a`, `violin/tapir-v`, and `xylophone/tapir-x`. Accordion, Violin, and Xylophone are for RGSS3 (VX Ace), RGSS2 (VX), and RGSS (XP), respectively.

## Run tapir
