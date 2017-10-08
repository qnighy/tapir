module RGSSTest
  class TestSprite
    include RGSSTest

    @@imgdir = "../../src/test/Graphics"

    def register(obj)
      @objects << obj
      obj
    end

    def cleaned(&b)
      begin
        @objects = []
        b.call
      ensure
        @objects.each do|obj|
          obj.dispose
        end
      end
    end

    def test_positioning_1
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
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_positioning_1.png"))
      end
    end

    def test_zoom_1
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
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_zoom_1.png"))
      end
    end

    def test_angle_1
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
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_angle_1.png"))
      end
    end

    def test_bush_1
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
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_bush_1.png"))
      end
    end

    def test_wave_1
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
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_wave_1.png"))
      end
    end

    def test_sprite_1
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
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_1.png"))
      end
    end

    def test_sprite_2
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
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_2.png"))
      end
    end

    def test_sprite_rect_angle
      cleaned do
        s1 = register(Sprite.new)
        s1.bitmap = Bitmap.new("#@@imgdir/grad_rgb_256x256.png")
        s1.z = -10
        s1.x = 150
        s1.y = 100
        s1.src_rect.x = 1
        s1.angle = 1.0

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_rect_angle.png"))
      end
    end

    def test_color_1
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
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_color_1.png"))
      end
    end

    def test_color_2
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
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_color_2.png"))
      end
    end

    def test_color_3
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
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_color_3.png"))
      end
    end

    def test_tone_1
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
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_tone_1.png"))
      end
    end

    def test_tone_2
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
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_tone_2.png"))
      end
    end

    def test_tone_3
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
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_tone_3.png"))
      end
    end

    def test_tone_4
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
        assert_bitmap_equal(
          snap, Bitmap.new("#@@imgdir/test_sprite_tone_4.png"))
      end
    end

    def test_flash_1
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
          assert_bitmap_equal(
            snap, Bitmap.new("#@@imgdir/test_sprite_flash_1_#{t}.png"))
          s2.update
        end
      end
    end

    def test_wave_update
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
  end

  if RGSS >= 2
    run_test(TestSprite)
  end
end
