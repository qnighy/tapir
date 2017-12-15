# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestRect < Test
    @@klass = Rect

    def new_unchecked(x, y, width, height)
      Rect._load([x, y, width, height].pack("l<l<l<l<"))
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
      assert_symset_equal(@@klass.methods - Object.methods, [:_load])
    end

    def test_instance_methods
      assert_symset_equal(owned_instance_methods(@@klass), [
        :==, :===, :_dump, :empty, :eql?, :height, :height=, :set, :to_s,
        :width, :width=, :x, :x=, :y, :y=])
    end

    def test_instance_variables
      obj = @@klass.new(0, 0, 0, 0)
      assert_symset_equal(obj.instance_variables, [])
    end

    def test_new_arg4_1
      obj = @@klass.new(0, 0, 0, 0)
      assert_equal(obj.x, 0)
      assert_equal(obj.y, 0)
      assert_equal(obj.width, 0)
      assert_equal(obj.height, 0)
    end

    def test_new_arg4_2
      obj = @@klass.new(67.5, 38.25, 175.75, 237.25)
      assert_equal(obj.x, 67)
      assert_equal(obj.y, 38)
      assert_equal(obj.width, 175)
      assert_equal(obj.height, 237)
    end

    def test_new_arg4_3
      obj = @@klass.new(-3, 0, -70, -1024)
      assert_equal(obj.x, -3)
      assert_equal(obj.y, 0)
      assert_equal(obj.width, -70)
      assert_equal(obj.height, -1024)
    end

    def test_new_arg0
      if RGSS == 3
        obj = @@klass.new
        assert_equal(obj.x, 0)
        assert_equal(obj.y, 0)
        assert_equal(obj.width, 0)
        assert_equal(obj.height, 0)
      else
        assert_raise(ArgumentError) { @@klass.new }
      end
    end

    def test_new_argerror
      assert_raise(ArgumentError) { @@klass.new(0) }
      assert_raise(ArgumentError) { @@klass.new(0, 0) }
      assert_raise(ArgumentError) { @@klass.new(0, 0, 0) }
      assert_raise(ArgumentError) { @@klass.new(0, 0, 0, 0, 0) }
    end

    def test_new_typeerror
      assert_raise(TypeError) { @@klass.new("hoge", 0, 0, 0) }
      assert_raise(TypeError) { @@klass.new(0, "hoge", 0, 0) }
      assert_raise(TypeError) { @@klass.new(0, 0, "hoge", 0) }
      assert_raise(TypeError) { @@klass.new(0, 0, 0, "hoge") }
    end

    def test_new_large
      obj = @@klass.new((1 << 30) - 1, (1 << 30) - 1, (1 << 30) - 1, (1 << 30) - 1)
      assert_equal(obj.x, (1 << 30) - 1)
      assert_equal(obj.y, (1 << 30) - 1)
      assert_equal(obj.width, (1 << 30) - 1)
      assert_equal(obj.height, (1 << 30) - 1)

      obj = @@klass.new(-(1 << 30), -(1 << 30), -(1 << 30), -(1 << 30))
      assert_equal(obj.x, -(1 << 30))
      assert_equal(obj.y, -(1 << 30))
      assert_equal(obj.width, -(1 << 30))
      assert_equal(obj.height, -(1 << 30))

      obj = @@klass.new((1 << 31) - 1, (1 << 31) - 1, (1 << 31) - 1, (1 << 31) - 1)
      # This is because the accessors are buggy.
      expected = "\xFF\xFF\xFF\x7F\xFF\xFF\xFF\x7F\xFF\xFF\xFF\x7F\xFF\xFF\xFF\x7F"
      expected.force_encoding("ASCII-8BIT") rescue nil
      assert_equal(obj._dump(0), expected)

      obj = @@klass.new(-(1 << 31), -(1 << 31), -(1 << 31), -(1 << 31))
      # This is because the accessors are buggy.
      expected = "\x00\x00\x00\x80\x00\x00\x00\x80\x00\x00\x00\x80\x00\x00\x00\x80"
      expected.force_encoding("ASCII-8BIT") rescue nil
      assert_equal(obj._dump(0), expected)
    end

    def test_new_rangeerror
      assert_raise(RangeError) { @@klass.new(1 << 31, 0, 0, 0) }
      assert_raise(RangeError) { @@klass.new(0, 1 << 31, 0, 0) }
      assert_raise(RangeError) { @@klass.new(0, 0, 1 << 31, 0) }
      assert_raise(RangeError) { @@klass.new(0, 0, 0, 1 << 31) }
      assert_raise(RangeError) { @@klass.new(-(1 << 31) - 1, 0, 0, 0) }
      assert_raise(RangeError) { @@klass.new(0, -(1 << 31) - 1, 0, 0) }
      assert_raise(RangeError) { @@klass.new(0, 0, -(1 << 31) - 1, 0) }
      assert_raise(RangeError) { @@klass.new(0, 0, 0, -(1 << 31) - 1) }
    end

    def test_set_arg4_1
      obj = @@klass.new(20, 20, 20, 20)
      obj.set(0, 0, 0, 0)
      assert_equal(obj.x, 0)
      assert_equal(obj.y, 0)
      assert_equal(obj.width, 0)
      assert_equal(obj.height, 0)
    end

    def test_set_arg4_2
      obj = @@klass.new(20, 20, 20, 20)
      obj.set(67.5, 38.25, 175.75, 237.25)
      assert_equal(obj.x, 67)
      assert_equal(obj.y, 38)
      assert_equal(obj.width, 175)
      assert_equal(obj.height, 237)
    end

    def test_set_arg1
      obj = @@klass.new(20, 20, 20, 20)
      if RGSS == 3
        obj.set(@@klass.new(35, 37, 39, 41))
        assert_equal(obj.x, 35)
        assert_equal(obj.y, 37)
        assert_equal(obj.width, 39)
        assert_equal(obj.height, 41)
      else
        assert_raise(ArgumentError) {
          obj.set(@@klass.new(35, 37, 39, 41))
        }
      end
    end

    def test_set_retval
      obj = @@klass.new(20, 20, 20, 20)
      assert(obj.set(1, 2, 3, 4).equal?(obj))
      if RGSS == 3
        assert(obj.set(@@klass.new(1, 2, 3, 4)).equal?(obj))
      end
    end

    def test_set_argerror
      obj = @@klass.new(20, 20, 20, 20)
      assert_raise(ArgumentError) { obj.set }
      assert_raise(ArgumentError) { obj.set(0, 0) }
      assert_raise(ArgumentError) { obj.set(0, 0, 0) }
      assert_raise(ArgumentError) { obj.set(0, 0, 0, 0, 0) }
    end

    def test_set_typeerror
      obj = @@klass.new(20, 20, 20, 20)
      assert_raise(TypeError) { obj.set("hoge", 0, 0, 0) }
      assert_raise(TypeError) { obj.set(0, "hoge", 0, 0) }
      assert_raise(TypeError) { obj.set(0, 0, "hoge", 0) }
      assert_raise(TypeError) { obj.set(0, 0, 0, "hoge") }
      # assert_raise(TypeError) { obj.set("hoge") }
      # assert_raise(TypeError) { obj.set(Color.new(0.0, 0.0, 0.0, 0.0)) }
    end

    def test_set_large
      obj = @@klass.new(20, 20, 20, 20)
      obj.set((1 << 30) - 1, (1 << 30) - 1, (1 << 30) - 1, (1 << 30) - 1)
      assert_equal(obj.x, (1 << 30) - 1)
      assert_equal(obj.y, (1 << 30) - 1)
      assert_equal(obj.width, (1 << 30) - 1)
      assert_equal(obj.height, (1 << 30) - 1)

      obj = @@klass.new(20, 20, 20, 20)
      obj.set(-(1 << 30), -(1 << 30), -(1 << 30), -(1 << 30))
      assert_equal(obj.x, -(1 << 30))
      assert_equal(obj.y, -(1 << 30))
      assert_equal(obj.width, -(1 << 30))
      assert_equal(obj.height, -(1 << 30))

      obj = @@klass.new(20, 20, 20, 20)
      obj.set((1 << 31) - 1, (1 << 31) - 1, (1 << 31) - 1, (1 << 31) - 1)
      # This is because the accessors are buggy.
      expected = "\xFF\xFF\xFF\x7F\xFF\xFF\xFF\x7F\xFF\xFF\xFF\x7F\xFF\xFF\xFF\x7F"
      expected.force_encoding("ASCII-8BIT") rescue nil
      assert_equal(obj._dump(0), expected)

      obj = @@klass.new(20, 20, 20, 20)
      obj.set(-(1 << 31), -(1 << 31), -(1 << 31), -(1 << 31))
      # This is because the accessors are buggy.
      expected = "\x00\x00\x00\x80\x00\x00\x00\x80\x00\x00\x00\x80\x00\x00\x00\x80"
      expected.force_encoding("ASCII-8BIT") rescue nil
      assert_equal(obj._dump(0), expected)
    end

    def test_set_rangeerror
      obj = @@klass.new(20, 20, 20, 20)
      assert_raise(RangeError) { obj.set(1 << 31, 0, 0, 0) }
      assert_raise(RangeError) { obj.set(0, 1 << 31, 0, 0) }
      assert_raise(RangeError) { obj.set(0, 0, 1 << 31, 0) }
      assert_raise(RangeError) { obj.set(0, 0, 0, 1 << 31) }
      assert_raise(RangeError) { obj.set(-(1 << 31) - 1, 0, 0, 0) }
      assert_raise(RangeError) { obj.set(0, -(1 << 31) - 1, 0, 0) }
      assert_raise(RangeError) { obj.set(0, 0, -(1 << 31) - 1, 0) }
      assert_raise(RangeError) { obj.set(0, 0, 0, -(1 << 31) - 1) }
    end

    def test_empty
      obj = @@klass.new(20, 20, 20, 20)
      obj.empty
      assert_equal(obj.x, 0)
      assert_equal(obj.y, 0)
      assert_equal(obj.width, 0)
      assert_equal(obj.height, 0)
    end

    def test_empty_retval
      obj = @@klass.new(20, 20, 20, 20)
      assert(obj.empty.equal?(obj))
    end

    def test_empty_argerror
      obj = @@klass.new(20, 20, 20, 20)
      assert_raise(ArgumentError) { obj.empty(30) }
      assert_raise(ArgumentError) { obj.empty(30, 40) }
      assert_raise(ArgumentError) { obj.empty(30, 40, 50) }
      assert_raise(ArgumentError) { obj.empty(30, 40, 50, 60) }
    end

    def test_xywh_large
      obj = @@klass.new((1 << 30) - 1, (1 << 30) - 1, (1 << 30) - 1, (1 << 30) - 1)
      assert_equal(obj.x, (1 << 30) - 1)
      assert_equal(obj.y, (1 << 30) - 1)
      assert_equal(obj.width, (1 << 30) - 1)
      assert_equal(obj.height, (1 << 30) - 1)

      obj = @@klass.new(-(1 << 30), -(1 << 30), -(1 << 30), -(1 << 30))
      assert_equal(obj.x, -(1 << 30))
      assert_equal(obj.y, -(1 << 30))
      assert_equal(obj.width, -(1 << 30))
      assert_equal(obj.height, -(1 << 30))
    end

    def test_xywh_large_buggy
      # Buggy behavior
      obj = @@klass.new(-(1 << 30), -(1 << 30), -(1 << 30), -(1 << 30))
      assert_equal(obj.x, -(1 << 30))
      assert_equal(obj.y, -(1 << 30))
      assert_equal(obj.width, -(1 << 30))
      assert_equal(obj.height, -(1 << 30))

      # Buggy behavior
      obj = @@klass.new((1 << 31) - 1, (1 << 31) - 1, (1 << 31) - 1, (1 << 31) - 1)
      assert_equal(obj.x, -1)
      assert_equal(obj.y, -1)
      assert_equal(obj.width, -1)
      assert_equal(obj.height, -1)

      # Buggy behavior
      obj = @@klass.new(-(1 << 30) - 1, -(1 << 30) - 1, -(1 << 30) - 1, -(1 << 30) - 1)
      assert_equal(obj.x, (1 << 30) - 1)
      assert_equal(obj.y, (1 << 30) - 1)
      assert_equal(obj.width, (1 << 30) - 1)
      assert_equal(obj.height, (1 << 30) - 1)

      # Buggy behavior
      obj = @@klass.new(-(1 << 31), -(1 << 31), -(1 << 31), -(1 << 31))
      assert_equal(obj.x, 0)
      assert_equal(obj.y, 0)
      assert_equal(obj.width, 0)
      assert_equal(obj.height, 0)
    end

    def test_set_xywh
      obj = @@klass.new(20, 20, 20, 20)
      assert_equal(obj.x, 20)
      obj.x = 111.75
      assert_equal(obj.x, 111)

      obj = @@klass.new(20, 20, 20, 20)
      assert_equal(obj.y, 20)
      obj.y = 3.1
      assert_equal(obj.y, 3)

      obj = @@klass.new(20, 20, 20, 20)
      assert_equal(obj.width, 20)
      obj.width = 17.875
      assert_equal(obj.width, 17)

      obj = @@klass.new(20, 20, 20, 20)
      assert_equal(obj.height, 20.0)
      obj.height = 254.5
      assert_equal(obj.height, 254)
    end

    def test_set_xywh_retval
      obj = @@klass.new(20, 20, 20, 20)
      assert_equal(obj.send(:x=, 1.5), 1.5)
      assert_equal(obj.send(:y=, 7.5), 7.5)
      assert_equal(obj.send(:width=, 15.5), 15.5)
      assert_equal(obj.send(:height=, 2.75), 2.75)
    end

    def test_set_xywh_retval_2
      obj = @@klass.new(20, 20, 20, 20)
      val = Object.new
      def val.to_int
        1000
      end
      assert_equal(obj.send(:x=, val), val)
      assert_equal(obj.send(:y=, val), val)
      assert_equal(obj.send(:width=, val), val)
      assert_equal(obj.send(:height=, val), val)
    end

    def test_set_xywh_typeerror
      obj = @@klass.new(20, 20, 20, 20)
      assert_raise(TypeError) { obj.x = "hoge" }
      assert_raise(TypeError) { obj.y = "hoge" }
      assert_raise(TypeError) { obj.width = "hoge" }
      assert_raise(TypeError) { obj.height = "hoge" }
    end

    def test_initialize_copy
      obj = @@klass.new(20, 20, 20, 20)
      obj.send(:initialize_copy, @@klass.new(35, 37, 39, 41))
      assert_equal(obj.x, 35)
      assert_equal(obj.y, 37)
      assert_equal(obj.width, 39)
      assert_equal(obj.height, 41)
    end

    def test_initialize_copy_self
      obj = @@klass.new(20, 20, 20, 20)
      obj.send(:initialize_copy, obj)
      assert_equal(obj.x, 20)
      assert_equal(obj.y, 20)
      assert_equal(obj.width, 20)
      assert_equal(obj.height, 20)
    end

    def test_initialize_copy_argerror
      obj = @@klass.new(20, 20, 20, 20)
      assert_raise(ArgumentError) {
        obj.send(:initialize_copy, obj, obj, obj, obj)
      }
      assert_raise(ArgumentError) {
        obj.send(:initialize_copy, obj, obj, obj)
      }
      assert_raise(ArgumentError) { obj.send(:initialize_copy, obj, obj) }
      assert_raise(ArgumentError) { obj.send(:initialize_copy) }
    end

    def test_initialize_copy_typeerror
      obj = @@klass.new(20, 20, 20, 20)
      assert_raise(TypeError) { obj.send(:initialize_copy, Object.new) }
      rect_sub = Class.new(Rect)
      assert_raise(TypeError) {
        obj.send(:initialize_copy, rect_sub.new(20, 20, 20, 20))
      }
    end

    def test_to_s_1
      obj = @@klass.new(3, 137, 254, 200)
      assert_equal(obj.to_s, "(3, 137, 254, 200)")
    end

    def test_to_s_2
      obj = @@klass.new(0, 0, 0, 0)
      assert_equal(obj.to_s, "(0, 0, 0, 0)")
    end

    def test_to_s_3
      obj = @@klass.new(-3, -137, -254, -200)
      assert_equal(obj.to_s, "(-3, -137, -254, -200)")
    end

    def test_to_s_large
      obj = @@klass.new((1 << 31) - 1, (1 << 31) - 1, (1 << 31) - 1, (1 << 31) - 1)
      assert_equal(obj.to_s, "(2147483647, 2147483647, 2147483647, 2147483647)")

      obj = @@klass.new(-(1 << 31), -(1 << 31), -(1 << 31), -(1 << 31))
      assert_equal(obj.to_s, "(-2147483648, -2147483648, -2147483648, -2147483648)")
    end

    def test_load_1
      obj = new_unchecked(189, 33, -1, 55)
      assert_equal(obj.x, 189)
      assert_equal(obj.y, 33)
      assert_equal(obj.width, -1)
      assert_equal(obj.height, 55)
    end

    def test_load_large
      obj = Rect._load("\xFF\xFF\xFF\x3F\xFF\xFF\xFF\x3F\xFF\xFF\xFF\x3F\xFF\xFF\xFF\x3F")
      assert_equal(obj.x, (1 << 30) - 1)
      assert_equal(obj.y, (1 << 30) - 1)
      assert_equal(obj.width, (1 << 30) - 1)
      assert_equal(obj.height, (1 << 30) - 1)

      obj = Rect._load("\x00\x00\x00\xC0\x00\x00\x00\xC0\x00\x00\x00\xC0\x00\x00\x00\xC0")
      assert_equal(obj.x, -(1 << 30))
      assert_equal(obj.y, -(1 << 30))
      assert_equal(obj.width, -(1 << 30))
      assert_equal(obj.height, -(1 << 30))

      obj = Rect._load("\xFF\xFF\xFF\x7F\xFF\xFF\xFF\x7F\xFF\xFF\xFF\x7F\xFF\xFF\xFF\x7F")
      obj = new_unchecked((1 << 31) - 1, (1 << 31) - 1, (1 << 31) - 1, (1 << 31) - 1)
      # This is because the accessors are buggy.
      expected = "\xFF\xFF\xFF\x7F\xFF\xFF\xFF\x7F\xFF\xFF\xFF\x7F\xFF\xFF\xFF\x7F"
      expected.force_encoding("ASCII-8BIT") rescue nil
      assert_equal(obj._dump(0), expected)

      obj = Rect._load("\x00\x00\x00\x80\x00\x00\x00\x80\x00\x00\x00\x80\x00\x00\x00\x80")
      # This is because the accessors are buggy.
      expected = "\x00\x00\x00\x80\x00\x00\x00\x80\x00\x00\x00\x80\x00\x00\x00\x80"
      expected.force_encoding("ASCII-8BIT") rescue nil
      assert_equal(obj._dump(0), expected)
    end

    def test_equal_1
      obj1 = @@klass.new(55, 77, 88, 111)
      obj2 = @@klass.new(55, 77, 88, 111)
      assert_equal(obj1 == obj2, true)
      assert_equal(obj1 === obj2, true)
      assert_equal(obj1.eql?(obj2), true)
      assert_equal(obj2 == obj1, true)
      assert_equal(obj2 === obj1, true)
      assert_equal(obj2.eql?(obj1), true)
    end

    def test_equal_large
      obj1 = @@klass.new((1 << 31) - 1, 0, 0, 0)
      obj2 = @@klass.new(-1, 0, 0, 0)
      assert_equal(obj1 == obj2, false)
      assert_equal(obj1 === obj2, false)
      assert_equal(obj1.eql?(obj2), false)

      obj1 = @@klass.new(0, (1 << 31) - 1, 0, 0)
      obj2 = @@klass.new(0, -1, 0, 0)
      assert_equal(obj1 == obj2, false)
      assert_equal(obj1 === obj2, false)
      assert_equal(obj1.eql?(obj2), false)

      obj1 = @@klass.new(0, 0, (1 << 31) - 1, 0)
      obj2 = @@klass.new(0, 0, -1, 0)
      assert_equal(obj1 == obj2, false)
      assert_equal(obj1 === obj2, false)
      assert_equal(obj1.eql?(obj2), false)

      obj1 = @@klass.new(0, 0, 0, (1 << 31) - 1)
      obj2 = @@klass.new(0, 0, 0, -1)
      assert_equal(obj1 == obj2, false)
      assert_equal(obj1 === obj2, false)
      assert_equal(obj1.eql?(obj2), false)
    end

    def test_equal_typeerror
      obj = @@klass.new(0, 0, 0, 0)
      if RGSS == 3
        assert_equal(obj == "hoge", false)
        assert_equal(obj === "hoge", false)
        assert_equal(obj.eql?("hoge"), false)
        assert_equal(obj == Color.new(0.0, 0.0, 0.0, 0.0), false)
        assert_equal(obj === Color.new(0.0, 0.0, 0.0, 0.0), false)
        assert_equal(obj.eql?(Color.new(0.0, 0.0, 0.0, 0.0)), false)
      else
        assert_raise(TypeError) { obj == @@klass }
        assert_raise(TypeError) { obj === @@klass }
        assert_raise(TypeError) { obj.eql?(@@klass) }
        assert_raise(TypeError) { obj == Color.new(0.0, 0.0, 0.0, 0.0) }
        assert_raise(TypeError) { obj === Color.new(0.0, 0.0, 0.0, 0.0) }
        assert_raise(TypeError) { obj.eql?(Color.new(0.0, 0.0, 0.0, 0.0)) }
      end
      assert_equal(:hoge == obj, false)
      assert_equal(:hoge === obj, false)
      assert_equal(:hoge.eql?(obj), false)
    end

    def test_dump_1
      obj = @@klass.new(55, 60, 65, 70)
      assert_equal(obj._dump(0), "\x37\x00\x00\x00\x3C\x00\x00\x00\x41\x00\x00\x00\x46\x00\x00\x00")

      obj = @@klass.new(-55, -60, -65, -70)
      expected = "\xC9\xFF\xFF\xFF\xC4\xFF\xFF\xFF\xBF\xFF\xFF\xFF\xBA\xFF\xFF\xFF"
      expected.force_encoding("ASCII-8BIT") rescue nil
      assert_equal(obj._dump(0), expected)
    end

    def test_dump_2
      obj = @@klass.new(55, 60, 65, 70)
      assert_equal(obj._dump(-1), "\x37\x00\x00\x00\x3C\x00\x00\x00\x41\x00\x00\x00\x46\x00\x00\x00")
    end

    def test_dump_3
      obj = @@klass.new(55, 60, 65, 70)
      assert_equal(obj._dump("hoge"), "\x37\x00\x00\x00\x3C\x00\x00\x00\x41\x00\x00\x00\x46\x00\x00\x00")
    end
  end
end
