module RGSSTest
  class TestBitmap
    include RGSSTest

    @@imgdir = "../../src/test/Graphics"

    def test_superclass
      assert_equal(Bitmap.superclass, Object)
    end

    def test_constants
      assert_symset_equal(Bitmap.constants, [])
    end

    def test_class_variables
      assert_symset_equal(Bitmap.class_variables, [])
    end

    def test_class_methods
      assert_symset_equal(Bitmap.methods - Object.methods, [])
    end

    def test_instance_methods
      if RGSS >= 2
        assert_symset_equal(owned_instance_methods(Bitmap), [
          :blt, :blur, :clear, :clear_rect, :dispose, :disposed?, :draw_text,
          :fill_rect, :font, :font=, :get_pixel, :gradient_fill_rect, :height,
          :hue_change, :radial_blur, :rect, :set_pixel, :stretch_blt,
          :text_size, :width])
      else
        assert_symset_equal(owned_instance_methods(Bitmap), [
          :blt, :clear, :dispose, :disposed?, :draw_text, :fill_rect, :font,
          :font=, :get_pixel, :height, :hue_change, :rect, :set_pixel,
          :stretch_blt, :text_size, :width])
      end
    end

    def test_new_1
      b0 = Bitmap.new(43, 30)
      b1 = Bitmap.new("#@@imgdir/empty_43x30.png")
      assert_bitmap_equal(b0, b1)
    end

    def test_new_2
      assert_raise(ArgumentError) { Bitmap.new }
      assert_raise(ArgumentError) { Bitmap.new(12, 34, 56) }
    end

    def test_dispose_1
      b = Bitmap.new(13, 15)
      assert_equal(b.disposed?, false)

      b.dispose
      assert_equal(b.disposed?, true)
    end

    def test_dispose_2
      RGSS == 3 or return
      b = Bitmap.new(33, 10)
      assert_equal(b.disposed?, false)

      r = false
      rgss_main do
        unless r
          r = true
          raise RGSSReset
        end
      end
      assert_equal(b.disposed?, true)
    end

    def test_width_1
      b = Bitmap.new(45, 60)
      assert_equal(b.width, 45)
    end

    def test_width_2
      b = Bitmap.new(45, 60)
      b.dispose
      assert_raise(RGSSError) { b.width }
    end

    def test_height_1
      b = Bitmap.new(45, 60)
      assert_equal(b.height, 60)
    end

    def test_height_2
      b = Bitmap.new(45, 60)
      b.dispose
      assert_raise(RGSSError) { b.height }
    end

    def test_rect_1
      b = Bitmap.new(77, 30)
      assert_equal(b.rect, Rect.new(0, 0, 77, 30))
    end

    def test_rect_2
      b = Bitmap.new(77, 30)
      assert_not_same(b.rect, b.rect)
    end

    def test_rect_3
      b = Bitmap.new(77, 30)
      b.dispose
      assert_raise(RGSSError) { b.rect }
    end

    def test_blt_1
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(0, 0, b1, b1.rect, 255)
      assert_bitmap_equal(b0, b1)
    end

    def test_blt_1a
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(0.9, 0.9, b1, b1.rect)
      assert_bitmap_equal(b0, b1)
    end

    def test_blt_2
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(0, 0, b1, b1.rect, 128)
      assert_bitmap_equal(b0, Bitmap.new("#@@imgdir/test_blt_2.png"))
    end

    def test_blt_3
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgba_40x32_b.png")
      b0.blt(0, 0, b1, b1.rect, 128)
      assert_bitmap_equal(b0, Bitmap.new("#@@imgdir/test_blt_3.png"))
    end

    def test_blt_4
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgba_40x32_b.png")
      b0.blt(0, 0, b1, b1.rect, 128)
      assert_bitmap_equal(b0, Bitmap.new("#@@imgdir/test_blt_4.png"))
    end

    def test_blt_5
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(-5, -3, b1, b1.rect)
      assert_bitmap_equal(b0, Bitmap.new("#@@imgdir/test_blt_5.png"))
    end

    def test_blt_6
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(5, 3, b1, b1.rect)
      assert_bitmap_equal(b0, Bitmap.new("#@@imgdir/test_blt_6.png"))
    end

    def test_blt_7
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(10, 6, b1, Rect.new(2, 3, 4, 5))
      assert_bitmap_equal(b0, Bitmap.new("#@@imgdir/test_blt_7.png"))
    end

    def test_blt_8
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      r = b1.rect
      r.x = -7
      r.y = -8
      b0.blt(-8, -9, b1, r)
      assert_bitmap_equal(b0, Bitmap.new("#@@imgdir/test_blt_8.png"))
    end

    def test_blt_9
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      r = b1.rect
      r.x = -17
      r.y = -18
      b0.blt(-8, -9, b1, r)
      assert_bitmap_equal(b0, Bitmap.new("#@@imgdir/test_blt_9.png"))
    end

    def test_blt_10
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      r = b1.rect
      r.x = 7
      r.y = 8
      b0.blt(8, 9, b1, r)
      assert_bitmap_equal(b0, Bitmap.new("#@@imgdir/test_blt_10.png"))
    end

    def test_blt_11
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      r = b1.rect
      r.x = 17
      r.y = 18
      b0.blt(8, 9, b1, r)
      assert_bitmap_equal(b0, Bitmap.new("#@@imgdir/test_blt_11.png"))
    end

    def test_blt_12
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(20, 20, b1, Rect.new(20, 20, -20, 20))
      assert_bitmap_equal(b0, Bitmap.new("#@@imgdir/test_blt_12.png"))
    end

    def test_blt_13
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(20, 20, b1, Rect.new(20, 20, 20, -20))
      assert_bitmap_equal(b0, Bitmap.new("#@@imgdir/test_blt_13.png"))
    end

    def test_blt_14
      b = Bitmap.new(32, 32)
      assert_raise(ArgumentError) { b.blt }
      assert_raise(ArgumentError) { b.blt(:a) }
      assert_raise(ArgumentError) { b.blt(:a, :b) }
      assert_raise(ArgumentError) { b.blt(:a, :b, :c) }
      assert_raise(ArgumentError) { b.blt(:a, :b, :c, :d, :e, :f) }
    end
  end

  run_test(TestBitmap)
end
