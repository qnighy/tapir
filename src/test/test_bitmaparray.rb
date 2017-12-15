# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestBitmapArray < Test
    if RGSS >= 2
      @@klass = Tilemap::BitmapArray
      @@len = 9
    else
      @@klass = TilemapAutotiles
      @@len = 7
    end

    def generate
      tilemap = Tilemap.new
      if RGSS >= 2
        [tilemap, tilemap.bitmaps]
      else
        [tilemap, tilemap.autotiles]
      end
    end

    def test_superclass
      assert_equal(@@klass.superclass, Object)
    end

    def test_constants
      assert_symset_equal(@@klass.constants, [])
    end

    def test_class_variables
      assert_symset_equal(@@klass.class_variables, [])
    end

    def test_class_methods
      assert_symset_equal(@@klass.methods - Object.methods, [])
    end

    def test_instance_methods
      assert_symset_equal(owned_instance_methods(@@klass), [:[], :[]=])
    end

    def test_instance_variables
      tilemap, obj = generate
      assert_symset_equal(obj.instance_variables, [])
    end

    def test_new
      obj = @@klass.new
    end

    def test_new_invalid
      obj = @@klass.new
      assert_raise(TypeError) { obj[0] }
      assert_raise(TypeError) { obj[0] = nil }
    end

    def test_init
      tilemap, obj = generate
      assert_equal(obj[-1], nil)
      assert_equal(obj[0], nil)
      assert_equal(obj[1], nil)
      assert_equal(obj[@@len-2], nil)
      assert_equal(obj[@@len-1], nil)
      assert_equal(obj[@@len], nil)
    end

    def test_aset
      tilemap, obj = generate

      b = Bitmap.new(32, 32)
      obj[0] = b
      assert_equal(obj[0], b)

      b = Bitmap.new(32, 32)
      obj[@@len-1] = b
      assert_equal(obj[@@len-1], b)
    end

    def test_aset_oob
      tilemap, obj = generate

      b = Bitmap.new(32, 32)
      obj[-1] = b
      assert_equal(obj[-1], nil)

      b = Bitmap.new(32, 32)
      obj[@@len] = b
      assert_equal(obj[@@len], nil)
    end

    def test_aset_retval
      tilemap, obj = generate

      b = Bitmap.new(32, 32)
      assert_equal(obj.send(:[]=, 0, b), b)
      assert_equal(obj.send(:[]=, 0, nil), nil)

      b = Bitmap.new(32, 32)
      assert_equal(obj.send(:[]=, @@len-1, b), b)
      assert_equal(obj.send(:[]=, @@len-1, nil), nil)

      b = Bitmap.new(32, 32)
      assert_equal(obj.send(:[]=, -1, b), nil)
      assert_equal(obj.send(:[]=, -1, nil), nil)

      b = Bitmap.new(32, 32)
      assert_equal(obj.send(:[]=, @@len, b), nil)
      assert_equal(obj.send(:[]=, @@len, nil), nil)
    end

    def test_aset_retval_2
      tilemap, obj = generate
      assert_equal(obj.send(:[]=, -1, "hoge"), nil)
      assert_equal(obj.send(:[]=, @@len, "hoge"), nil)
    end

    def test_aset_nil
      tilemap, obj = generate

      b = Bitmap.new(32, 32)
      obj[0] = b
      assert_equal(obj[0], b)
      obj[0] = nil
      assert_equal(obj[0], nil)

      b = Bitmap.new(32, 32)
      obj[@@len-1] = b
      assert_equal(obj[@@len-1], b)
      obj[@@len-1] = nil
      assert_equal(obj[@@len-1], nil)

      b = Bitmap.new(32, 32)
      obj[-1] = b
      assert_equal(obj[-1], nil)
      obj[-1] = nil
      assert_equal(obj[-1], nil)

      b = Bitmap.new(32, 32)
      obj[@@len] = b
      assert_equal(obj[@@len], nil)
      obj[@@len] = nil
      assert_equal(obj[@@len], nil)
    end

    def test_aset_typeerror
      tilemap, obj = generate

      assert_raise(TypeError) { obj["0"] = nil }
      assert_raise(TypeError) { obj[0] = "hoge" }
      assert_nothing_raised(TypeError) { obj[-1] = "hoge" }
      # assert_raise(TypeError) { obj[0] = Color.new }
    end

    def test_aset_rangeerror
      tilemap, obj = generate

      assert_nothing_raised(RangeError) { obj[(1<<31)-1] }
      assert_nothing_raised(RangeError) { obj[(1<<31)-1] = nil }
      assert_nothing_raised(RangeError) { obj[-(1<<31)] }
      assert_nothing_raised(RangeError) { obj[-(1<<31)] = nil }
      assert_raise(RangeError) { obj[1<<31] }
      assert_raise(RangeError) { obj[1<<31] = nil }
      assert_raise(RangeError) { obj[-(1<<31)-1] }
      assert_raise(RangeError) { obj[-(1<<31)-1] = nil }
    end
  end
end
