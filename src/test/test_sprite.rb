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
  class TestSprite < Test
    @@imgdir = "../../src/test/Graphics"

    include WithClean

    def test_positioning_1
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")

        s2.src_rect.x = 18
        s2.src_rect.y = -55
        s2.src_rect.width = 210
        s2.src_rect.height = 211

        s2.ox = 20
        s2.oy = 30

        s2.mirror = true

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_positioning_1", snap)
      end
    end

    def test_zoom_1
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10
        s1.x = 150
        s1.y = 100

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")

        s2.src_rect.x = -37
        s2.src_rect.y = 5
        s2.src_rect.width = 300
        s2.src_rect.height = 330
        s2.x = 216
        s2.y = 166
        s2.ox = 50
        s2.oy = -2
        s2.zoom_x = 0.8
        s2.zoom_y = 1.2

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_zoom_1", snap)
      end
    end

    def test_angle_1
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10
        s1.x = 150
        s1.y = 100

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")

        s2.x = 216
        s2.y = 166
        s2.ox = 50
        s2.oy = -2
        s2.zoom_x = 0.8
        s2.zoom_y = 1.2
        s2.angle = 30

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_angle_1", snap)
      end
    end

    def test_bush_1
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10
        s1.x = 150
        s1.y = 100

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")

        s2.x = 216
        s2.y = 166
        s2.ox = 50
        s2.oy = -2
        s2.bush_depth = 88
        s2.bush_opacity = 150
        s2.opacity = 200

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_bush_1", snap)
      end
    end

    def test_wave_1
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10
        s1.x = 150
        s1.y = 100

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")

        s2.x = 216
        s2.y = 166
        s2.wave_amp = 30
        s2.wave_length = 20
        s2.wave_speed = 13
        s2.wave_phase = 167

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_wave_1", snap)
      end
    end

    def test_sprite_1
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10
        s1.x = 150
        s1.y = 100

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")

        s2.src_rect.x = -37
        s2.src_rect.y = 5
        s2.src_rect.width = 300
        s2.src_rect.height = 330
        s2.x = 216
        s2.y = 166
        s2.ox = 50
        s2.oy = -2
        s2.zoom_x = 0.8
        s2.zoom_y = 1.2
        s2.angle = 0.0
        s2.wave_amp = 50
        s2.wave_length = 30
        s2.wave_speed = 45
        s2.wave_phase = 30
        s2.mirror = true
        s2.bush_depth = 88
        s2.bush_opacity = 150
        s2.opacity = 200

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_1", snap)
      end
    end

    def test_sprite_2
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10
        s1.x = 150
        s1.y = 100

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")

        s2.x = 216
        s2.y = 166
        s2.ox = 50
        s2.oy = -2
        s2.zoom_x = 0.8
        s2.zoom_y = 1.2
        s2.angle = 30.0
        s2.wave_amp = 50
        s2.wave_length = 30
        s2.wave_speed = 45
        s2.wave_phase = 300
        s2.mirror = true
        s2.bush_depth = 88
        s2.bush_opacity = 150
        s2.opacity = 200

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_2", snap)
      end
    end

    def test_sprite_rect_angle
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10
        s1.x = 150
        s1.y = 100
        s1.src_rect.x = 1
        s1.angle = 1.0

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_rect_angle", snap)
      end
    end

    def test_color_1
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgba_256x256.png")

        s2.x = 50
        s2.y = -50

        s2.color = Color.new(20, 158, 240, 150)

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_color_1", snap)
      end
    end

    def test_color_2
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgba_256x256.png")

        s2.x = 50
        s2.y = -50

        s2.color = Color.new(20, 158, 240, 150)
        s2.opacity = 128

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_color_2", snap)
      end
    end

    def test_color_3
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10
        s1.x = 150
        s1.y = 100

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgba_256x256.png")

        s2.x = 216
        s2.y = 166
        s2.ox = 50
        s2.oy = -2
        s2.zoom_x = 0.8
        s2.zoom_y = 1.2
        s2.angle = 30.0
        s2.wave_amp = 50
        s2.wave_length = 30
        s2.wave_speed = 45
        s2.wave_phase = 180
        s2.color = Color.new(20, 158, 240, 150)

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_color_3", snap)
      end
    end

    def test_tone_1
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgba_256x256.png")

        s2.x = 50
        s2.y = -50

        s2.tone = Tone.new(20, 158, -133, 0)

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_tone_1", snap)
      end
    end

    def test_tone_2
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgba_256x256.png")

        s2.x = 50
        s2.y = -50

        s2.tone = Tone.new(20, 158, -133, 180)

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_tone_2", snap)
      end
    end

    def test_tone_3
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgba_256x256.png")

        s2.x = 50
        s2.y = -50

        s2.tone = Tone.new(20, 158, -133, 180)
        s2.opacity = 230

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_tone_3", snap)
      end
    end

    def test_tone_4
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgba_256x256.png")

        s2.x = 50
        s2.y = -50

        s2.color = Color.new(20, 158, 240, 150)
        s2.tone = Tone.new(20, 158, -133, 180)
        s2.opacity = 230

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_tone_4", snap)
      end
    end

    def test_flash_1
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgba_256x256.png")

        s2.x = 50
        s2.y = -50

        s2.color = Color.new(20, 158, 240, 45)

        s2.flash(Color.new(255, 0, 150, 247), 7)

        8.times do|t|
          snap = Graphics.snap_to_bitmap
          assert_bitmap_equal2("test_sprite_flash_1_#{t}", snap)
          s2.update
        end
      end
    end

    def test_wave_update
      skip_default
      cleaned do
        s1 = register(Sprite.new)

        s1.wave_amp = 120
        s1.wave_length = 28
        s1.wave_speed = 7
        s1.wave_phase = 40.0

        s1.update
        assert_equal(s1.wave_amp, 120)
        assert_equal(s1.wave_length, 28)
        assert_equal(s1.wave_speed, 7)
        assert_equal(s1.wave_phase, 40.25)

        s1.update
        assert_equal(s1.wave_phase, 40.5)

        s1.wave_length = 26
        s1.wave_speed = 13
        s1.update
        assert_equal(s1.wave_phase, 41.0)
      end
    end

    def test_blend_type_1
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgba_256x256.png")

        s2.x = 50
        s2.y = -50

        s2.blend_type = 1

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_blend_type_1", snap)
      end
    end

    def test_blend_type_2
      skip_default
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10

        s2 = register(Sprite.new)
        s2.bitmap = Bitmap.new("#@@imgdir/grad_rgba_256x256.png")

        s2.x = 50
        s2.y = -50

        s2.blend_type = 2

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_sprite_blend_type_2", snap)
      end
    end

    def test_auto_src_rect_1
      skip_default
      cleaned do
        s1 = register(Sprite.new)

        s1.bitmap = nil
        s1.src_rect = Rect.new(1, 3, 5, 7)
        s1.bitmap = nil
        assert_equal(s1.src_rect, Rect.new(1, 3, 5, 7))
      end
    end

    def test_auto_src_rect_2
      skip_default
      cleaned do
        s1 = register(Sprite.new)

        s1.bitmap = nil
        s1.src_rect = Rect.new(1, 3, 5, 7)
        s1.bitmap = Bitmap.new(33, 27)
        assert_equal(s1.src_rect, Rect.new(0, 0, 33, 27))
      end
    end

    def test_auto_src_rect_3
      skip_default
      cleaned do
        s1 = register(Sprite.new)

        s1.bitmap = Bitmap.new(51, 2)
        s1.src_rect = Rect.new(1, 3, 5, 7)
        s1.bitmap = nil
        assert_equal(s1.src_rect, Rect.new(1, 3, 5, 7))
      end
    end

    def test_auto_src_rect_4
      skip_default
      cleaned do
        s1 = register(Sprite.new)

        s1.bitmap = Bitmap.new(1, 1)
        s1.src_rect = Rect.new(1, 3, 5, 7)
        s1.bitmap = Bitmap.new(311, 12)
        assert_equal(s1.src_rect, Rect.new(0, 0, 311, 12))
      end
    end

    def test_auto_src_rect_5
      skip_default
      cleaned do
        s1 = register(Sprite.new)

        s1.bitmap = Bitmap.new(15, 24)
        s1.src_rect = Rect.new(1, 3, 5, 7)
        s1.bitmap = Bitmap.new(15, 24)
        assert_equal(s1.src_rect, Rect.new(0, 0, 15, 24))
      end
    end

    def test_auto_src_rect_6
      skip_default
      cleaned do
        s1 = register(Sprite.new)

        b = Bitmap.new(15, 24)

        s1.bitmap = b
        s1.src_rect = Rect.new(1, 3, 5, 7)
        s1.bitmap = b
        assert_equal(s1.src_rect, Rect.new(1, 3, 5, 7))
      end
    end
  end
  end # if RGSS >= 2
end
