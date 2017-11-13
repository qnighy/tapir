# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestBitmap < Test
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
      assert_bitmap_equal2("test_bitmap_new_1", b0)
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

    if RGSS == 3
    def test_dispose_2
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
    end # if RGSS == 3

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
      assert_bitmap_equal2("test_blt_1", b0)
    end

    def test_blt_1a
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(0.9, 0.9, b1, b1.rect)
      assert_bitmap_equal2("test_blt_1a", b0)
    end

    def test_blt_2
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(0, 0, b1, b1.rect, 128)
      assert_bitmap_equal2("test_blt_2", b0)
    end

    def test_blt_3
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgba_40x32_b.png")
      b0.blt(0, 0, b1, b1.rect, 128)
      assert_bitmap_equal2("test_blt_3", b0)
    end

    def test_blt_4
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgba_40x32_b.png")
      b0.blt(0, 0, b1, b1.rect, 128)
      assert_bitmap_equal2("test_blt_4", b0)
    end

    def test_blt_5
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(-5, -3, b1, b1.rect)
      assert_bitmap_equal2("test_blt_5", b0)
    end

    def test_blt_6
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(5, 3, b1, b1.rect)
      assert_bitmap_equal2("test_blt_6", b0)
    end

    def test_blt_7
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(10, 6, b1, Rect.new(2, 3, 4, 5))
      assert_bitmap_equal2("test_blt_7", b0)
    end

    def test_blt_8
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      r = b1.rect
      r.x = -7
      r.y = -8
      b0.blt(-8, -9, b1, r)
      assert_bitmap_equal2("test_blt_8", b0)
    end

    def test_blt_9
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      r = b1.rect
      r.x = -17
      r.y = -18
      b0.blt(-8, -9, b1, r)
      assert_bitmap_equal2("test_blt_9", b0)
    end

    def test_blt_10
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      r = b1.rect
      r.x = 7
      r.y = 8
      b0.blt(8, 9, b1, r)
      assert_bitmap_equal2("test_blt_10", b0)
    end

    def test_blt_11
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      r = b1.rect
      r.x = 17
      r.y = 18
      b0.blt(8, 9, b1, r)
      assert_bitmap_equal2("test_blt_11", b0)
    end

    def test_blt_12
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(20, 20, b1, Rect.new(20, 20, -20, 20))
      assert_bitmap_equal2("test_blt_12", b0)
    end

    def test_blt_13
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.blt(20, 20, b1, Rect.new(20, 20, 20, -20))
      assert_bitmap_equal2("test_blt_13", b0)
    end

    def test_blt_14
      b = Bitmap.new(32, 32)
      assert_raise(ArgumentError) { b.blt }
      assert_raise(ArgumentError) { b.blt(:a) }
      assert_raise(ArgumentError) { b.blt(:a, :b) }
      assert_raise(ArgumentError) { b.blt(:a, :b, :c) }
      assert_raise(ArgumentError) { b.blt(:a, :b, :c, :d, :e, :f) }
    end

    def test_stretch_blt_1
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.stretch_blt(b1.rect, b1, b1.rect, 255)
      assert_bitmap_equal2("test_stretch_blt_1", b0)
    end

    def test_stretch_blt_1a
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.stretch_blt(b1.rect, b1, b1.rect)
      assert_bitmap_equal2("test_stretch_blt_1a", b0)
    end

    def test_stretch_blt_2
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.stretch_blt(b1.rect, b1, b1.rect, 128)
      assert_bitmap_equal2("test_stretch_blt_2", b0)
    end

    def test_stretch_blt_3
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgba_40x32_b.png")
      b0.stretch_blt(b1.rect, b1, b1.rect, 128)
      assert_bitmap_equal2("test_stretch_blt_3", b0)
    end

    def test_stretch_blt_4
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgba_40x32_b.png")
      b0.stretch_blt(b1.rect, b1, b1.rect, 128)
      assert_bitmap_equal2("test_stretch_blt_4", b0)
    end

    def test_stretch_blt_5
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.stretch_blt(Rect.new(-5, -3, b1.width, b1.height), b1, b1.rect)
      assert_bitmap_equal2("test_stretch_blt_5", b0)
    end

    def test_stretch_blt_6
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.stretch_blt(Rect.new(5, 3, b1.width, b1.height), b1, b1.rect)
      assert_bitmap_equal2("test_stretch_blt_6", b0)
    end

    def test_stretch_blt_7
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.stretch_blt(Rect.new(10, 6, 4, 5), b1, Rect.new(2, 3, 4, 5))
      assert_bitmap_equal2("test_stretch_blt_7", b0)
    end

    def test_stretch_blt_8
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      r = b1.rect
      r.x = -7
      r.y = -8
      b0.stretch_blt(Rect.new(-8, -9, b1.width, b1.height), b1, r)
      assert_bitmap_equal2("test_stretch_blt_8", b0)
    end

    def test_stretch_blt_9
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      r = b1.rect
      r.x = -17
      r.y = -18
      b0.stretch_blt(Rect.new(-8, -9, b1.width, b1.height), b1, r)
      assert_bitmap_equal2("test_stretch_blt_9", b0)
    end

    def test_stretch_blt_10
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      r = b1.rect
      r.x = 7
      r.y = 8
      b0.stretch_blt(Rect.new(8, 9, b1.width, b1.height), b1, r)
      assert_bitmap_equal2("test_stretch_blt_10", b0)
    end

    def test_stretch_blt_11
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      r = b1.rect
      r.x = 17
      r.y = 18
      b0.stretch_blt(Rect.new(8, 9, b1.width, b1.height), b1, r)
      assert_bitmap_equal2("test_stretch_blt_11", b0)
    end

    def test_stretch_blt_12
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.stretch_blt(Rect.new(20, 20, 20, 20), b1, Rect.new(20, 20, -20, 20))
      assert_bitmap_equal2("test_stretch_blt_12", b0)
    end

    def test_stretch_blt_13
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.stretch_blt(Rect.new(20, 20, 20, 20), b1, Rect.new(20, 20, 20, -20))
      assert_bitmap_equal2("test_stretch_blt_13", b0)
    end

    def test_stretch_blt_14
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.stretch_blt(Rect.new(2, 3, 18, 14), b1, Rect.new(4, 5, 6, 7))
      assert_bitmap_equal2("test_stretch_blt_14", b0)
    end

    def test_stretch_blt_15
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.stretch_blt(Rect.new(2, 3, 6, 7), b1, Rect.new(4, 5, 12, 21))
      assert_bitmap_equal2("test_stretch_blt_15", b0)
    end

    def test_stretch_blt_16
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.stretch_blt(Rect.new(3, 3, 37, 29), b1, Rect.new(1, 1, 8, 10))
      assert_bitmap_equal2("test_stretch_blt_16", b0)
    end

    def test_stretch_blt_17
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.stretch_blt(Rect.new(10, 10, 15, 15), b1, Rect.new(1, 1, 39, 31))
      assert_bitmap_equal2("test_stretch_blt_17", b0)
    end

    def test_stretch_blt_18
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.stretch_blt(Rect.new(35, 5, 13, 17), b1, Rect.new(5, -13, 22, 22))
      assert_bitmap_equal2("test_stretch_blt_18", b0)
    end

    def test_stretch_blt_19
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b1 = Bitmap.new("#@@imgdir/random_rgb_40x32_b.png")
      b0.stretch_blt(Rect.new(-1, -1, 42, 34), b1, Rect.new(-10, 5, 80, 80))
      assert_bitmap_equal2("test_stretch_blt_19", b0)
    end

    def test_stretch_blt_20
      b = Bitmap.new(32, 32)
      assert_raise(ArgumentError) { b.stretch_blt }
      assert_raise(ArgumentError) { b.stretch_blt(:a) }
      assert_raise(ArgumentError) { b.stretch_blt(:a, :b) }
      assert_raise(ArgumentError) { b.stretch_blt(:a, :b, :c, :d, :e) }
    end

    def test_fill_rect_1
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b0.fill_rect(0, 0, 40, 32, Color.new(100, 50, 150, 255))
      assert_bitmap_equal2("test_fill_rect_1", b0)
    end

    def test_fill_rect_1a
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b0.fill_rect(0.9, 0.9, 40, 32, Color.new(100, 50, 150, 255))
      assert_bitmap_equal2("test_fill_rect_1a", b0)
    end

    def test_fill_rect_1b
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b0.fill_rect(Rect.new(0, 0, 40, 32), Color.new(100, 50, 150, 255))
      assert_bitmap_equal2("test_fill_rect_1b", b0)
    end

    def test_fill_rect_2
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.fill_rect(0, 0, 40, 32, Color.new(100, 50, 150, 100))
      assert_bitmap_equal2("test_fill_rect_2", b0)
    end

    def test_fill_rect_3
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.fill_rect(5, 7, 10, 13, Color.new(45, 255, 0, 126))
      assert_bitmap_equal2("test_fill_rect_3", b0)
    end

    def test_fill_rect_4
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.fill_rect(-3, -5, 100, 100, Color.new(45, 255, 0, 126))
      assert_bitmap_equal2("test_fill_rect_4", b0)
    end

    def test_fill_rect_5
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.fill_rect(11, 11, -13, 13, Color.new(0, 255, 0, 50))
      assert_bitmap_equal2("test_fill_rect_5", b0)
    end

    def test_fill_rect_6
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.fill_rect(11, 11, 13, -13, Color.new(0, 255, 0, 50))
      assert_bitmap_equal2("test_fill_rect_6", b0)
    end

    def test_fill_rect_7
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.fill_rect(11, 11, -13, -13, Color.new(0, 255, 0, 50))
      assert_bitmap_equal2("test_fill_rect_7", b0)
    end

    if RGSS >= 2
    def test_gradient_fill_rect_1
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b0.gradient_fill_rect(
        0, 0, 40, 32,
        Color.new(100, 50, 150, 255), Color.new(100, 50, 150, 255))
      assert_bitmap_equal2("test_gradient_fill_rect_1", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_gradient_fill_rect_1a
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b0.gradient_fill_rect(
        0.9, 0.9, 40, 32,
        Color.new(100, 50, 150, 255), Color.new(100, 50, 150, 255))
      assert_bitmap_equal2("test_gradient_fill_rect_1a", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_gradient_fill_rect_1b
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b0.gradient_fill_rect(
        Rect.new(0, 0, 40, 32),
        Color.new(100, 50, 150, 255), Color.new(100, 50, 150, 255))
      assert_bitmap_equal2("test_gradient_fill_rect_1b", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_gradient_fill_rect_2
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.gradient_fill_rect(
        0, 0, 40, 32,
        Color.new(100, 50, 150, 100), Color.new(100, 50, 150, 100))
      assert_bitmap_equal2("test_gradient_fill_rect_2", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_gradient_fill_rect_3
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.gradient_fill_rect(
        5, 7, 10, 13,
        Color.new(45, 255, 0, 126), Color.new(45, 255, 0, 126))
      assert_bitmap_equal2("test_gradient_fill_rect_3", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_gradient_fill_rect_4
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.gradient_fill_rect(
        -3, -5, 100, 100,
        Color.new(45, 255, 0, 126), Color.new(45, 255, 0, 126))
      assert_bitmap_equal2("test_gradient_fill_rect_4", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_gradient_fill_rect_5
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.gradient_fill_rect(
        11, 11, -13, 13,
        Color.new(0, 255, 0, 50), Color.new(0, 255, 0, 50))
      assert_bitmap_equal2("test_gradient_fill_rect_5", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_gradient_fill_rect_6
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.gradient_fill_rect(
        11, 11, 13, -13,
        Color.new(0, 255, 0, 50), Color.new(0, 255, 0, 50))
      assert_bitmap_equal2("test_gradient_fill_rect_6", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_gradient_fill_rect_7
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.gradient_fill_rect(
        11, 11, -13, -13,
        Color.new(0, 255, 0, 50), Color.new(0, 255, 0, 50))
      assert_bitmap_equal2("test_gradient_fill_rect_7", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_gradient_fill_rect_8
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.gradient_fill_rect(
        11, 11, 50, 50,
        Color.new(0, 255, 0, 50), Color.new(55, 200, 255, 255), false)
      assert_bitmap_equal2("test_gradient_fill_rect_8", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_gradient_fill_rect_9
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.gradient_fill_rect(
        11, 11, 50, 50,
        Color.new(0, 255, 0, 50), Color.new(55, 200, 255, 255), true)
      assert_bitmap_equal2("test_gradient_fill_rect_9", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_gradient_fill_rect_10
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.gradient_fill_rect(
        -5, -8, 20, 23,
        Color.new(255, 255, 255, 255), Color.new(0, 0, 0, 0))
      assert_bitmap_equal2("test_gradient_fill_rect_10", b0)
    end
    end # if RGSS >= 2

    def test_hue_change_1
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.hue_change(100)
      assert_bitmap_equal2("test_hue_change_1", b0)
    end

    def test_hue_change_2
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.hue_change(411)
      assert_bitmap_equal2("test_hue_change_2", b0)
    end

    if RGSS >= 2
    def test_blur_1
      b0 = Bitmap.new("#@@imgdir/random_rgb_40x32_a.png")
      b0.blur
      assert_bitmap_equal2("test_blur_1", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_blur_2
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.blur
      assert_bitmap_equal2("test_blur_2", b0)
    end
    end # if RGSS >= 2

    # def test_generate_checkered
    #   b0 = Bitmap.new(41, 33)
    #   9.times do|xx|
    #     7.times do|yy|
    #       b0.fill_rect(xx*5, yy*5, 5, 5, Color.new(rand(256), rand(256), rand(256), 255))
    #     end
    #   end
    #   save_bitmap(b0, "#@@imgdir/checkered_41x33.png")
    # end

    if RGSS >= 2
    def test_radial_blur_1
      b0 = Bitmap.new("#@@imgdir/checkered_41x33.png")
      b0.radial_blur(90, 2)
      assert_bitmap_equal2("test_radial_blur_1", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_radial_blur_2
      b0 = Bitmap.new("#@@imgdir/checkered_41x33.png")
      b0.radial_blur(60, 3)
      assert_bitmap_equal2("test_radial_blur_2", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_radial_blur_3
      b0 = Bitmap.new("#@@imgdir/checkered_41x33.png")
      b0.radial_blur(60, 4)
      assert_bitmap_equal2("test_radial_blur_3", b0)
    end
    end # if RGSS >= 2

    if RGSS >= 2
    def test_radial_blur_4
      b0 = Bitmap.new("#@@imgdir/random_rgba_40x32_a.png")
      b0.radial_blur(59, 5)
      assert_bitmap_equal2("test_radial_blur_4", b0)
    end
    end # if RGSS >= 2
  end
end
