# RGSS Test Suite

This directory contains scripts to run tests on the original RGSS.

# Required files

You have to obtain these runtimes from appropriate places.

- `rgss1/Game.exe`
- `rgss1/RGSS104J.dll`
- `rgss1/TRGSSX.dll`, [distributed by KAMESOFT](http://ytomy.sakura.ne.jp/tkool/rpgtech/php/tech.php?tool=VX&cat=tech_xp/draw_function&tech=bitmap_extension) (Not necessary for now)
- `rgss2/Game.exe`
- `rgss2/RGSS202J.dll`
- `rgss2/TRGSSX.dll`, [distributed by KAMESOFT](http://ytomy.sakura.ne.jp/tkool/rpgtech/php/tech.php?tool=VX&cat=tech_xp/draw_function&tech=bitmap_extension) (Not necessary for now)
- `rgss3/Game.exe`
- `rgss3/System/RGSS301.dll`

# Dependencies

You need Cygwin, MSYS2 or WSL with make and ruby.

# Run tests

Just type `make` to run tests. Windows will pop up during tests.

```
$ make
```
