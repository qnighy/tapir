# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  if RGSS >= 2
  class TestSpriteOrdering < Test
    @@imgdir = "../../src/test/Graphics"

    include WithClean

    def filled_bitmap(w, h, color)
      b = Bitmap.new(w, h)
      b.fill_rect(0, 0, w, h, color)
      b
    end

    def checkered_bitmap(w, h, color)
      b = Bitmap.new(w, h)
      b.fill_rect(0, 0, w/2, h/2, color)
      b.fill_rect(w/2, h/2, w, h, color)
      b
    end

    def test_z_ordering_sprite_1
      skip_default
      cleaned do
        s2 = register(Sprite.new)
        s2.z = 100
        s2.bitmap = filled_bitmap(100, 100, Color.new(255, 0, 0, 255))

        s1 = register(Sprite.new)
        s1.z = -100
        s1.bitmap = filled_bitmap(200, 200, Color.new(0, 255, 0, 255))

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_z_ordering_sprite_1", snap)
      end
    end

    def test_z_ordering_sprite_2
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.z = -100
        s1.bitmap = filled_bitmap(200, 200, Color.new(0, 255, 0, 255))

        s2 = register(Sprite.new)
        s2.z = 100
        s2.bitmap = filled_bitmap(100, 100, Color.new(255, 0, 0, 255))

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_z_ordering_sprite_2", snap)
      end
    end

    def test_z_ordering_window_1
      skip_default
      cleaned do
        w1 = register(Window.new)
        w1.z = 150
        w1.windowskin = filled_bitmap(128, 128, Color.new(0, 0, 255, 255))
        w1.back_opacity = 255
        w1.width = 100
        w1.height = 100

        s1 = register(Sprite.new)
        s1.z = -100
        s1.bitmap = filled_bitmap(200, 200, Color.new(0, 255, 0, 255))

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_z_ordering_window_1", snap)
      end
    end

    def test_z_ordering_window_2
      skip_default
      cleaned do
        w1 = register(Window.new)
        w1.z = -150
        w1.windowskin = filled_bitmap(128, 128, Color.new(0, 0, 255, 255))
        w1.back_opacity = 255
        w1.width = 200
        w1.height = 200

        s1 = register(Sprite.new)
        s1.z = -100
        s1.bitmap = filled_bitmap(100, 100, Color.new(0, 255, 0, 255))

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_z_ordering_window_2", snap)
      end
    end

    def test_z_ordering_plane_1
      skip_default
      cleaned do
        p1 = register(Plane.new)
        p1.bitmap = checkered_bitmap(4, 4, Color.new(255, 0, 0, 128))
        p1.z = 105

        s1 = register(Sprite.new)
        s1.z = 100
        s1.bitmap = filled_bitmap(100, 100, Color.new(0, 255, 0, 255))

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_z_ordering_plane_1", snap)
      end
    end

    def test_z_ordering_plane_2
      skip_default
      cleaned do
        p1 = register(Plane.new)
        p1.bitmap = checkered_bitmap(4, 4, Color.new(255, 0, 0, 128))
        p1.z = 95

        s1 = register(Sprite.new)
        s1.z = 100
        s1.bitmap = filled_bitmap(100, 100, Color.new(0, 255, 0, 255))

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_z_ordering_plane_2", snap)
      end
    end

    def test_z_ordering_tilemap
      skip_default
      cleaned do
        t1 = register(Tilemap.new)
        t1.bitmaps[5] = filled_bitmap(512, 512, Color.new(128, 128, 128, 255))
        t1.map_data = Table.new(100, 100, 4)
        t1.map_data[0, 0, 2] = 2
        t1.map_data[1, 0, 2] = 1
        t1.map_data[0, 1, 2] = 1
        t1.map_data[1, 1, 2] = 2
        t1_flags = Table.new(0x2000)
        (t1.flags = t1_flags) rescue (t1.passages = t1_flags)
        t1_flags[2] = 0x10

        s1 = register(Sprite.new)
        s1.z = -10
        s1.bitmap = filled_bitmap(80, 80, Color.new(0, 255, 0, 255))

        s2 = register(Sprite.new)
        s2.z = 100
        s2.bitmap = filled_bitmap(50, 50, Color.new(0, 0, 255, 255))

        s3 = register(Sprite.new)
        s3.z = 300
        s3.bitmap = filled_bitmap(20, 20, Color.new(255, 0, 0, 255))

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_z_ordering_tilemap", snap)
      end
    end

    def test_y_ordering_sprite_1
      skip_default
      cleaned do
        s2 = register(Sprite.new)
        s2.y = 10
        s2.bitmap = filled_bitmap(100, 200, Color.new(255, 0, 0, 255))

        s1 = register(Sprite.new)
        s1.y = 0
        s1.bitmap = filled_bitmap(200, 100, Color.new(0, 255, 0, 255))

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_y_ordering_sprite_1", snap)
      end
    end

    def test_y_ordering_sprite_2
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.y = 0
        s1.bitmap = filled_bitmap(200, 100, Color.new(0, 255, 0, 255))

        s2 = register(Sprite.new)
        s2.y = 10
        s2.bitmap = filled_bitmap(100, 200, Color.new(255, 0, 0, 255))

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_y_ordering_sprite_2", snap)
      end
    end

    def test_y_ordering_window_1
      skip_default
      cleaned do
        w1 = register(Window.new)
        w1.z = 0
        w1.y = 20
        w1.windowskin = filled_bitmap(128, 128, Color.new(0, 0, 255, 255))
        w1.back_opacity = 255
        w1.width = 120
        w1.height = 100

        s1 = register(Sprite.new)
        s1.y = -10
        s1.bitmap = filled_bitmap(140, 100, Color.new(0, 255, 0, 255))

        s1 = register(Sprite.new)
        s1.y = 10
        s1.bitmap = filled_bitmap(100, 100, Color.new(255, 0, 0, 255))

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_y_ordering_window_1", snap)
      end
    end

    def test_y_ordering_plane_1
      skip_default
      cleaned do
        p1 = register(Plane.new)
        p1.bitmap = checkered_bitmap(4, 4, Color.new(255, 0, 0, 128))
        p1.z = 105

        s1 = register(Sprite.new)
        s1.y = -10
        s1.bitmap = filled_bitmap(200, 200, Color.new(0, 255, 0, 255))

        s2 = register(Sprite.new)
        s2.y = 10
        s2.bitmap = filled_bitmap(100, 100, Color.new(0, 0, 255, 255))

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_y_ordering_plane_1", snap)
      end
    end

    def test_y_ordering_tilemap
      skip_default
      cleaned do
        t1 = register(Tilemap.new)
        t1.bitmaps[5] = filled_bitmap(512, 512, Color.new(128, 128, 128, 255))
        t1.map_data = Table.new(100, 100, 4)
        t1.map_data.ysize.times do|y|
          t1.map_data.xsize.times do|x|
            t1.map_data[x, y, 2] = 2 - ((x ^ y) & 1)
          end
        end
        t1_flags = Table.new(0x2000)
        (t1.flags = t1_flags) rescue (t1.passages = t1_flags)
        t1_flags[2] = 0x10

        s1 = register(Sprite.new)
        s1.y = -100
        s1.bitmap = filled_bitmap(200, 300, Color.new(0, 255, 0, 255))

        s2 = register(Sprite.new)
        s2.y = 100
        s2.bitmap = filled_bitmap(230, 300, Color.new(0, 0, 255, 255))

        s3 = register(Sprite.new)
        s3.y = -100
        s3.z = 200
        s3.bitmap = filled_bitmap(100, 300, Color.new(255, 0, 0, 255))

        s4 = register(Sprite.new)
        s4.y = 100
        s4.z = 200
        s4.bitmap = filled_bitmap(130, 300, Color.new(255, 0, 255, 255))

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_y_ordering_tilemap", snap)
      end
    end

    def test_t_ordering_1
      skip_default
      cleaned do
        w1 = register(Window.new)
        w1.z = 0
        w1.windowskin = filled_bitmap(128, 128, Color.new(0, 0, 255, 255))
        w1.back_opacity = 255
        w1.width = 100
        w1.height = 200

        s1 = register(Sprite.new)
        s1.z = 0
        s1.bitmap = filled_bitmap(200, 100, Color.new(0, 255, 0, 255))

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_t_ordering_1", snap)
      end
    end

    def test_t_ordering_2
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.z = 0
        s1.bitmap = filled_bitmap(200, 100, Color.new(0, 255, 0, 255))

        w1 = register(Window.new)
        w1.z = 0
        w1.windowskin = filled_bitmap(128, 128, Color.new(0, 0, 255, 255))
        w1.back_opacity = 255
        w1.width = 100
        w1.height = 200

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_t_ordering_2", snap)
      end
    end

    def test_t_reordering
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.z = 0
        s1.bitmap = filled_bitmap(200, 100, Color.new(0, 255, 0, 255))

        s2 = register(Sprite.new)
        s2.z = 0
        s2.bitmap = filled_bitmap(100, 200, Color.new(255, 0, 0, 255))

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_t_reordering_a", snap)

        s1.y = 1

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_t_reordering_b", snap)

        s1.y = 0

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_t_reordering_c", snap)
      end
    end
  end
  end # if RGSS >= 2
end
