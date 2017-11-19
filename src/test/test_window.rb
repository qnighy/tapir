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
  class TestWindow < Test
    @@imgdir = "../../src/test/Graphics"

    include WithClean

    # def test_generate_windowskin
    #   b = Bitmap.new(128, 128)
    #   64.times do|y|
    #     64.times do|x|
    #       b.set_pixel(x, y, Color.new(128, x*4, y*4, 255))
    #     end
    #   end
    #   64.times do|y|
    #     64.times do|x|
    #       b.set_pixel(x, y+64, Color.new(
    #         (31.5-x).abs*8, 255-(31.5-x).abs*8, (31.5-y).abs*8, 255))
    #     end
    #   end
    #   64.times do|y|
    #     64.times do|x|
    #       b.set_pixel(x+64, y, Color.new(255-y*4, 255-x*4, 128, 255))
    #     end
    #   end
    #   32.times do|y|
    #     32.times do|x|
    #       b.set_pixel(x+64+16, y+16, Color.new(y*8, x*8, 128, 255))
    #     end
    #   end
    #   32.times do|y|
    #     32.times do|x|
    #       if 2 <= x && x < 30 && 2 <= y && y < 30
    #         b.set_pixel(x+64, y+64, Color.new(255, x*8, y*8, 255))
    #       else
    #         b.set_pixel(x+64, y+64, Color.new(0, x*8, y*8, 255))
    #       end
    #     end
    #   end
    #   32.times do|y|
    #     32.times do|x|
    #       b.set_pixel(x+64+32, y+64, Color.new(255, y*8, 255-x*8, 255))
    #     end
    #   end
    #   save_bitmap(b, "#@@imgdir/windowskin1.png")
    # end

    def test_window_1
      skip_default
      cleaned do
        w1 = register(Window.new)
        w1.back_opacity = 255
        w1.windowskin = Bitmap.new("#@@imgdir/windowskin1.png")
        w1.x = 120
        w1.y = 100
        w1.width = 314
        w1.height = 250

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_window_1", snap)
      end
    end

    def test_window_2
      skip_default
      cleaned do
        w1 = register(Window.new)
        w1.back_opacity = 255
        w1.windowskin = Bitmap.new("#@@imgdir/windowskin1.png")
        w1.x = 120
        w1.y = 100
        w1.width = 314
        w1.height = 250

        w1.opacity = 128
        w1.back_opacity = 128

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_window_2", snap)
      end
    end

    def test_window_3
      skip_default
      cleaned do
        w1 = register(Window.new)
        w1.back_opacity = 255
        w1.windowskin = Bitmap.new("#@@imgdir/windowskin1.png")
        w1.windowskin.fill_rect(0, 64, 64, 64, Color.new(0, 0, 0, 0))
        w1.windowskin.fill_rect(64, 0, 64, 64, Color.new(0, 0, 0, 0))
        w1.x = 120
        w1.y = 100
        w1.width = 314
        w1.height = 250

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_window_3", snap)
      end
    end

    def test_window_arrows_1
      skip_default
      cleaned do
        w1 = register(Window.new)
        w1.back_opacity = 255
        w1.windowskin = Bitmap.new("#@@imgdir/windowskin1.png")
        w1.x = 120
        w1.y = 100
        w1.width = 314
        w1.height = 250

        w1.contents = Bitmap.new(500, 500)

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_window_arrows_1", snap)
      end
    end

    def test_window_arrows_2
      skip_default
      cleaned do
        w1 = register(Window.new)
        w1.back_opacity = 255
        w1.windowskin = Bitmap.new("#@@imgdir/windowskin1.png")
        w1.x = 120
        w1.y = 100
        w1.width = 314
        w1.height = 250

        w1.contents = Bitmap.new(500, 500)
        w1.ox = 500
        w1.oy = 500

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_window_arrows_2", snap)
      end
    end

    def test_window_pause_1
      skip_default
      cleaned do
        w1 = register(Window.new)
        w1.back_opacity = 255
        w1.windowskin = Bitmap.new("#@@imgdir/windowskin1.png")
        w1.x = 120
        w1.y = 100
        w1.width = 314
        w1.height = 250

        w1.pause = true

        (w1.padding = 16) rescue nil
        w1.contents = Bitmap.new(w1.width - 32, w1.height - 32)

        60.times do|i|
          if i < 16 || i % 16 == 15 || i % 16 == 0
            snap = Graphics.snap_to_bitmap
            assert_bitmap_equal2("test_window_pause_1_a_#{i}", snap)
          end
          w1.update
        end

        w1.pause = false
        w1.pause = true

        20.times do|i|
          if i < 16 || i % 16 == 15 || i % 16 == 0
            snap = Graphics.snap_to_bitmap
            assert_bitmap_equal2("test_window_pause_1_b_#{i}", snap)
          end
          w1.update
        end
      end
    end

    def test_window_cursor_1
      skip_default
      cleaned do
        w1 = register(Window.new)
        w1.back_opacity = 255
        w1.windowskin = Bitmap.new("#@@imgdir/windowskin1.png")
        w1.x = 120
        w1.y = 100
        w1.width = 314
        w1.height = 250

        (w1.padding = 16) rescue nil
        w1.cursor_rect = Rect.new(20, 20, 100, 100)

        40.times do|i|
          if i <= 5 || i % 5 == 0
            snap = Graphics.snap_to_bitmap
            assert_bitmap_equal2("test_window_cursor_1_t#{i}", snap)
          end
          w1.update
        end
      end
    end

    def test_window_cursor_2
      skip_default
      cleaned do
        w1 = register(Window.new)
        w1.back_opacity = 255
        w1.windowskin = Bitmap.new("#@@imgdir/windowskin1.png")
        w1.x = 120
        w1.y = 100
        w1.width = 314
        w1.height = 250

        (w1.padding = 16) rescue nil
        w1.cursor_rect = Rect.new(20, 20, 100, 100)
        w1.active = false

        snap = Graphics.snap_to_bitmap
        assert_bitmap_equal2("test_window_cursor_2", snap)
      end
    end
  end
  end # if RGSS >= 2
end
