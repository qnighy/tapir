# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestColor < Test
    @@klass = Color

    def new_unchecked(red, green, blue, alpha)
      Color._load([red, green, blue, alpha].pack("EEEE"))
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
        :==, :===, :_dump, :alpha, :alpha=, :blue, :blue=, :eql?, :green,
        :green=, :red, :red=, :set, :to_s])
    end

    def test_instance_variables
      obj = @@klass.new(0.0, 0.0, 0.0, 0.0)
      assert_symset_equal(obj.instance_variables, [])
    end

    def test_new_arg4_1
      obj = @@klass.new(0.0, 0.0, 0.0, 0.0)
      assert_equal(obj.red, 0.0)
      assert_equal(obj.green, 0.0)
      assert_equal(obj.blue, 0.0)
      assert_equal(obj.alpha, 0.0)
    end

    def test_new_arg4_2
      obj = @@klass.new(67.5, 38.25, 175.75, 237.25)
      assert_equal(obj.red, 67.5)
      assert_equal(obj.green, 38.25)
      assert_equal(obj.blue, 175.75)
      assert_equal(obj.alpha, 237.25)
    end

    def test_new_arg3
      obj = @@klass.new(1.0, 150.5, 225.0)
      assert_equal(obj.red, 1.0)
      assert_equal(obj.green, 150.5)
      assert_equal(obj.blue, 225.0)
      assert_equal(obj.alpha, 255.0)
    end

    def test_new_arg0
      if RGSS == 3
        obj = @@klass.new
        assert_equal(obj.red, 0.0)
        assert_equal(obj.green, 0.0)
        assert_equal(obj.blue, 0.0)
        assert_equal(obj.alpha, 0.0)
      else
        assert_raise(ArgumentError) { @@klass.new }
      end
    end

    def test_new_argerror
      assert_raise(ArgumentError) { @@klass.new(0.0) }
      assert_raise(ArgumentError) { @@klass.new(0.0, 0.0) }
      assert_raise(ArgumentError) {
        @@klass.new(0.0, 0.0, 0.0, 0.0, 0.0)
      }
    end

    def test_new_typeerror
      assert_raise(TypeError) { @@klass.new("hoge", 0.0, 0.0) }
      assert_raise(TypeError) { @@klass.new(0.0, "hoge", 0.0) }
      assert_raise(TypeError) { @@klass.new(0.0, 0.0, "hoge") }
      assert_raise(TypeError) { @@klass.new(0.0, 0.0, 0.0, "hoge") }
    end

    def test_new_lower_clamping
      obj = @@klass.new(-100.0, -110.0, -120.0, -130.0)
      assert_equal(obj.red, -100.0)
      assert_equal(obj.green, -110.0)
      assert_equal(obj.blue, -120.0)
      assert_equal(obj.alpha, 0.0)
      assert_equal(1.0 / obj.alpha, 1.0 / 0.0)

      obj = @@klass.new(-1000.0, -1100.0, -1200.0, -1300.0)
      assert_equal(obj.red, -255.0)
      assert_equal(obj.green, -255.0)
      assert_equal(obj.blue, -255.0)
      assert_equal(obj.alpha, 0.0)
      assert_equal(1.0 / obj.alpha, 1.0 / 0.0)

      obj = @@klass.new(-0.0, -0.0, -0.0, -0.0)
      assert_equal(1.0 / obj.red, 1.0 / -0.0)
      assert_equal(1.0 / obj.green, 1.0 / -0.0)
      assert_equal(1.0 / obj.blue, 1.0 / -0.0)
      assert_equal(1.0 / obj.alpha, 1.0 / -0.0)
    end

    def test_new_upper_clamping
      obj = @@klass.new(300.0, 310.0, 320.0, 330.0)
      assert_equal(obj.red, 255.0)
      assert_equal(obj.green, 255.0)
      assert_equal(obj.blue, 255.0)
      assert_equal(obj.alpha, 255.0)
    end

    def test_new_nan_clamping_1
      obj = @@klass.new(0.0 / 0.0, 0.0 / 0.0, 0.0 / 0.0, 0.0 / 0.0)
      assert(obj.red.nan?)
      assert(obj.green.nan?)
      assert(obj.blue.nan?)
      assert(obj.alpha.nan?)
    end

    def test_new_nan_clamping_2
      nanstr1 = "\x7f\xfe\xee\xdd\x01\x23\x45\x67"
      nanstr2 = "\xff\xfe\xee\xdd\xfa\x07\x7c\xbc"
      nanstr3 = "\x7f\xf8\x00\x00\x00\x00\x00\x01"
      nanstr4 = "\xff\xff\x00\x00\x13\x00\x00\x01"
      nanstr1.force_encoding("ASCII-8BIT") rescue nil
      nanstr2.force_encoding("ASCII-8BIT") rescue nil
      nanstr3.force_encoding("ASCII-8BIT") rescue nil
      nanstr4.force_encoding("ASCII-8BIT") rescue nil
      nan1 = nanstr1.unpack("G")[0]
      nan2 = nanstr2.unpack("G")[0]
      nan3 = nanstr3.unpack("G")[0]
      nan4 = nanstr4.unpack("G")[0]
      obj = @@klass.new(nan1, nan2, nan3, nan4)
      assert_equal([obj.red].pack("G"), nanstr1)
      assert_equal([obj.green].pack("G"), nanstr2)
      assert_equal([obj.blue].pack("G"), nanstr3)
      assert_equal([obj.alpha].pack("G"), nanstr4)
    end

    def test_set_arg4_1
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.set(0.0, 0.0, 0.0, 0.0)
      assert_equal(obj.red, 0.0)
      assert_equal(obj.green, 0.0)
      assert_equal(obj.blue, 0.0)
      assert_equal(obj.alpha, 0.0)
    end

    def test_set_arg4_2
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.set(67.5, 38.25, 175.75, 237.25)
      assert_equal(obj.red, 67.5)
      assert_equal(obj.green, 38.25)
      assert_equal(obj.blue, 175.75)
      assert_equal(obj.alpha, 237.25)
    end

    def test_set_arg3
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.set(1.0, 150.5, 225.0)
      assert_equal(obj.red, 1.0)
      assert_equal(obj.green, 150.5)
      assert_equal(obj.blue, 225.0)
      assert_equal(obj.alpha, 255.0)
    end

    def test_set_arg0
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      if RGSS == 3
        obj.set
        assert_equal(obj.red, 0.0)
        assert_equal(obj.green, 0.0)
        assert_equal(obj.blue, 0.0)
        assert_equal(obj.alpha, 0.0)
      else
        assert_raise(ArgumentError) { obj.set }
      end
    end

    def test_set_arg1
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      if RGSS == 3
        obj.set(@@klass.new(35.25, 37.25, 39.25, 41.25))
        assert_equal(obj.red, 35.25)
        assert_equal(obj.green, 37.25)
        assert_equal(obj.blue, 39.25)
        assert_equal(obj.alpha, 41.25)
      else
        assert_raise(ArgumentError) {
          obj.set(@@klass.new(35.25, 37.25, 39.25, 41.25))
        }
      end
    end

    def test_set_arg1_oob
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      if RGSS == 3
        obj.set(new_unchecked(-300.0, -310.0, -320.0, -330.0))
        assert_equal(obj.red, -300.0)
        assert_equal(obj.green, -310.0)
        assert_equal(obj.blue, -320.0)
        assert_equal(obj.alpha, -330.0)
      end
    end

    def test_set_retval
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      assert(obj.set(0.0, 0.0, 3.3, 0.0).equal?(obj))
      assert(obj.set(-3.7, 8.8, 4.5).equal?(obj))
      if RGSS == 3
        assert(obj.set(@@klass.new(3.0, 3.1, 3.2, 3.3)).equal?(obj))
        assert(obj.set.equal?(obj))
      end
    end

    def test_set_argerror
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      assert_raise(ArgumentError) { obj.set(0.0, 0.0) }
      assert_raise(ArgumentError) { obj.set(0.0, 0.0, 0.0, 0.0, 0.0) }
    end

    def test_set_typeerror
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      assert_raise(TypeError) { obj.set("hoge", 0.0, 0.0) }
      assert_raise(TypeError) { obj.set(0.0, "hoge", 0.0) }
      assert_raise(TypeError) { obj.set(0.0, 0.0, "hoge") }
      assert_raise(TypeError) { obj.set(0.0, 0.0, 0.0, "hoge") }
      # assert_raise(TypeError) { obj.set("hoge") }
      # assert_raise(TypeError) { obj.set(Tone.new(0.0, 0.0, 0.0, 0.0)) }
    end

    def test_set_lower_clamping
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.set(-100.0, -110.0, -120.0, -130.0)
      assert_equal(obj.red, -100.0)
      assert_equal(obj.green, -110.0)
      assert_equal(obj.blue, -120.0)
      assert_equal(obj.alpha, 0.0)
      assert_equal(1.0 / obj.alpha, 1.0 / 0.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.set(-1000.0, -1100.0, -1200.0, -1300.0)
      assert_equal(obj.red, -255.0)
      assert_equal(obj.green, -255.0)
      assert_equal(obj.blue, -255.0)
      assert_equal(obj.alpha, 0.0)
      assert_equal(1.0 / obj.alpha, 1.0 / 0.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.set(-0.0, -0.0, -0.0, -0.0)
      assert_equal(1.0 / obj.red, 1.0 / -0.0)
      assert_equal(1.0 / obj.green, 1.0 / -0.0)
      assert_equal(1.0 / obj.blue, 1.0 / -0.0)
      assert_equal(1.0 / obj.alpha, 1.0 / -0.0)
    end

    def test_set_upper_clamping
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.set(300.0, 310.0, 320.0, 330.0)
      assert_equal(obj.red, 255.0)
      assert_equal(obj.green, 255.0)
      assert_equal(obj.blue, 255.0)
      assert_equal(obj.alpha, 255.0)
    end

    def test_set_nan_clamping_1
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.set(0.0 / 0.0, 0.0 / 0.0, 0.0 / 0.0, 0.0 / 0.0)
      assert(obj.red.nan?)
      assert(obj.green.nan?)
      assert(obj.blue.nan?)
      assert(obj.alpha.nan?)
    end

    def test_set_nan_clamping_2
      nanstr1 = "\x7f\xfe\xee\xdd\x01\x23\x45\x67"
      nanstr2 = "\xff\xfe\xee\xdd\xfa\x07\x7c\xbc"
      nanstr3 = "\x7f\xf8\x00\x00\x00\x00\x00\x01"
      nanstr4 = "\xff\xff\x00\x00\x13\x00\x00\x01"
      nanstr1.force_encoding("ASCII-8BIT") rescue nil
      nanstr2.force_encoding("ASCII-8BIT") rescue nil
      nanstr3.force_encoding("ASCII-8BIT") rescue nil
      nanstr4.force_encoding("ASCII-8BIT") rescue nil
      nan1 = nanstr1.unpack("G")[0]
      nan2 = nanstr2.unpack("G")[0]
      nan3 = nanstr3.unpack("G")[0]
      nan4 = nanstr4.unpack("G")[0]
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.set(nan1, nan2, nan3, nan4)
      assert_equal([obj.red].pack("G"), nanstr1)
      assert_equal([obj.green].pack("G"), nanstr2)
      assert_equal([obj.blue].pack("G"), nanstr3)
      assert_equal([obj.alpha].pack("G"), nanstr4)
    end

    def test_set_rgba
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      assert_equal(obj.red, 20.0)
      obj.red = 111.75
      assert_equal(obj.red, 111.75)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      assert_equal(obj.green, 20.0)
      obj.green = 3.0
      assert_equal(obj.green, 3.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      assert_equal(obj.blue, 20.0)
      obj.blue = 17.875
      assert_equal(obj.blue, 17.875)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      assert_equal(obj.alpha, 20.0)
      obj.alpha = 254.5
      assert_equal(obj.alpha, 254.5)
    end

    def test_set_rgba_retval
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      assert_equal(obj.send(:red=, 3.25), 3.25)
      assert_equal(obj.send(:green=, 7.5), 7.5)
      assert_equal(obj.send(:blue=, 15.5), 15.5)
      assert_equal(obj.send(:alpha=, 2.75), 2.75)

      assert_equal(obj.send(:red=, -300.0), -300.0)
      assert_equal(obj.send(:green=, -310.0), -310.0)
      assert_equal(obj.send(:blue=, -320.0), -320.0)
      assert_equal(obj.send(:alpha=, -330.0), -330.0)

      assert_equal(obj.send(:red=, 300.0), 300.0)
      assert_equal(obj.send(:green=, 310.0), 310.0)
      assert_equal(obj.send(:blue=, 320.0), 320.0)
      assert_equal(obj.send(:alpha=, 330.0), 330.0)
    end

    def test_set_rgba_retval_2
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      val = Object.new
      def val.to_f
        1000.0
      end
      assert_equal(obj.send(:red=, val), val)
      assert_equal(obj.send(:green=, val), val)
      assert_equal(obj.send(:blue=, val), val)
      assert_equal(obj.send(:alpha=, val), val)
    end

    def test_rgba_argerror
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      assert_raise(ArgumentError) { obj.send(:red, 111.75) }
      assert_raise(ArgumentError) { obj.send(:red, 111.75, 111.75) }
      assert_raise(ArgumentError) { obj.send(:green, 111.75) }
      assert_raise(ArgumentError) { obj.send(:green, 111.75, 111.75) }
      assert_raise(ArgumentError) { obj.send(:blue, 111.75) }
      assert_raise(ArgumentError) { obj.send(:blue, 111.75, 111.75) }
      assert_raise(ArgumentError) { obj.send(:alpha, 111.75) }
      assert_raise(ArgumentError) { obj.send(:alpha, 111.75, 111.75) }
    end

    def test_set_rgba_argerror
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      assert_raise(ArgumentError) { obj.send(:red=) }
      assert_raise(ArgumentError) { obj.send(:red=, 111.75, 111.75) }
      assert_raise(ArgumentError) { obj.send(:green=) }
      assert_raise(ArgumentError) { obj.send(:green=, 111.75, 111.75) }
      assert_raise(ArgumentError) { obj.send(:blue=) }
      assert_raise(ArgumentError) { obj.send(:blue=, 111.75, 111.75) }
      assert_raise(ArgumentError) { obj.send(:alpha=) }
      assert_raise(ArgumentError) { obj.send(:alpha=, 111.75, 111.75) }
    end

    def test_set_rgba_typeerror
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      assert_raise(TypeError) { obj.red = "hoge" }
      assert_raise(TypeError) { obj.green = "hoge" }
      assert_raise(TypeError) { obj.blue = "hoge" }
      assert_raise(TypeError) { obj.alpha = "hoge" }
    end

    def test_set_rgba_lower_clamping
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.red = -100.0
      assert_equal(obj.red, -100.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.green = -110.0
      assert_equal(obj.green, -110.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.blue = -120.0
      assert_equal(obj.blue, -120.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.alpha = -130.0
      assert_equal(obj.alpha, 0.0)
      assert_equal(1.0 / obj.alpha, 1.0 / 0.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.red = -1000.0
      assert_equal(obj.red, -255.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.green = -1100.0
      assert_equal(obj.green, -255.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.blue = -1200.0
      assert_equal(obj.blue, -255.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.alpha = -1300.0
      assert_equal(obj.alpha, 0.0)
      assert_equal(1.0 / obj.alpha, 1.0 / 0.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.red = -0.0
      assert_equal(1.0 / obj.red, 1.0 / -0.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.green = -0.0
      assert_equal(1.0 / obj.green, 1.0 / -0.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.blue = -0.0
      assert_equal(1.0 / obj.blue, 1.0 / -0.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.alpha = -0.0
      assert_equal(1.0 / obj.alpha, 1.0 / -0.0)
    end

    def test_set_rgba_upper_clamping
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.red = 300.0
      assert_equal(obj.red, 255.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.green = 310.0
      assert_equal(obj.green, 255.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.blue = 320.0
      assert_equal(obj.blue, 255.0)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.alpha = 330.0
      assert_equal(obj.alpha, 255.0)
    end

    def test_set_rgba_nan_clamping_1
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.red = 0.0 / 0.0
      assert(obj.red.nan?)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.green = 0.0 / 0.0
      assert(obj.green.nan?)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.blue = 0.0 / 0.0
      assert(obj.blue.nan?)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.alpha = 0.0 / 0.0
      assert(obj.alpha.nan?)
    end

    def test_set_rgba_nan_clamping_2
      nanstr1 = "\x7f\xfe\xee\xdd\x01\x23\x45\x67"
      nanstr2 = "\xff\xfe\xee\xdd\xfa\x07\x7c\xbc"
      nanstr3 = "\x7f\xf8\x00\x00\x00\x00\x00\x01"
      nanstr4 = "\xff\xff\x00\x00\x13\x00\x00\x01"
      nanstr1.force_encoding("ASCII-8BIT") rescue nil
      nanstr2.force_encoding("ASCII-8BIT") rescue nil
      nanstr3.force_encoding("ASCII-8BIT") rescue nil
      nanstr4.force_encoding("ASCII-8BIT") rescue nil
      nan1 = nanstr1.unpack("G")[0]
      nan2 = nanstr2.unpack("G")[0]
      nan3 = nanstr3.unpack("G")[0]
      nan4 = nanstr4.unpack("G")[0]

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.red = nan1
      assert_equal([obj.red].pack("G"), nanstr1)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.green = nan2
      assert_equal([obj.green].pack("G"), nanstr2)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.blue = nan3
      assert_equal([obj.blue].pack("G"), nanstr3)

      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.alpha = nan4
      assert_equal([obj.alpha].pack("G"), nanstr4)
    end

    def test_initialize_copy
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.send(:initialize_copy, @@klass.new(35.25, 37.25, 39.25, 41.25))
      assert_equal(obj.red, 35.25)
      assert_equal(obj.green, 37.25)
      assert_equal(obj.blue, 39.25)
      assert_equal(obj.alpha, 41.25)
    end

    def test_initialize_copy_self
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      obj.send(:initialize_copy, obj)
      assert_equal(obj.red, 20.0)
      assert_equal(obj.green, 20.0)
      assert_equal(obj.blue, 20.0)
      assert_equal(obj.alpha, 20.0)
    end

    def test_initialize_copy_argerror
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
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
      obj = @@klass.new(20.0, 20.0, 20.0, 20.0)
      assert_raise(TypeError) { obj.send(:initialize_copy, Object.new) }
      color_sub = Class.new(Color)
      assert_raise(TypeError) {
        obj.send(:initialize_copy, color_sub.new(20.0, 20.0, 20.0, 20.0))
      }
    end

    def test_to_s_1
      obj = @@klass.new(3.75, 137.0, 254.375, 200.0)
      assert_equal(obj.to_s, "(3.750000, 137.000000, 254.375000, 200.000000)")
    end

    def test_to_s_2
      obj = @@klass.new(3.75000001, 136.9999999, 254.375, 200.0)
      assert_equal(obj.to_s, "(3.750000, 137.000000, 254.375000, 200.000000)")
    end

    def test_to_s_minus_zero
      obj = @@klass.new(-0.0, -0.0, -0.0, -0.0)
      assert_equal(obj.to_s, "(-0.000000, -0.000000, -0.000000, -0.000000)")
    end

    def test_to_s_minus_value
      obj = @@klass.new(-210.25, -210.0, -200.0, 25.0)
      assert_equal(obj.to_s,
                   "(-210.250000, -210.000000, -200.000000, 25.000000)")
    end

    def test_to_s_minus_value
      obj = @@klass.new(-210.25, -210.0, -200.0, 25.0)
      assert_equal(obj.to_s,
                   "(-210.250000, -210.000000, -200.000000, 25.000000)")
    end

    def test_load_1
      obj = new_unchecked(189.75, 33.25, 0.25, 55.25)
      assert_equal(obj.red, 189.75)
      assert_equal(obj.green, 33.25)
      assert_equal(obj.blue, 0.25)
      assert_equal(obj.alpha, 55.25)
    end

    def test_load_2
      obj = new_unchecked(1.0 / 0.0, 1.0 / 0.0, 1.0 / 0.0, 1.0 / 0.0)
      assert_equal(obj.red, 1.0 / 0.0)
      assert_equal(obj.green, 1.0 / 0.0)
      assert_equal(obj.blue, 1.0 / 0.0)
      assert_equal(obj.alpha, 1.0 / 0.0)

      obj = new_unchecked(-1.0 / 0.0, -1.0 / 0.0, -1.0 / 0.0, -1.0 / 0.0)
      assert_equal(obj.red, -1.0 / 0.0)
      assert_equal(obj.green, -1.0 / 0.0)
      assert_equal(obj.blue, -1.0 / 0.0)
      assert_equal(obj.alpha, -1.0 / 0.0)

      obj = new_unchecked(300.0, 310.0, 320.0, 330.0)
      assert_equal(obj.red, 300.0)
      assert_equal(obj.green, 310.0)
      assert_equal(obj.blue, 320.0)
      assert_equal(obj.alpha, 330.0)

      obj = new_unchecked(-300.0, -310.0, -320.0, -330.0)
      assert_equal(obj.red, -300.0)
      assert_equal(obj.green, -310.0)
      assert_equal(obj.blue, -320.0)
      assert_equal(obj.alpha, -330.0)

      nanstr1 = "\x7f\xfe\xee\xdd\x01\x23\x45\x67"
      nanstr2 = "\xff\xfe\xee\xdd\xfa\x07\x7c\xbc"
      nanstr3 = "\x7f\xf8\x00\x00\x00\x00\x00\x01"
      nanstr4 = "\xff\xff\x00\x00\x13\x00\x00\x01"
      nanstr1.force_encoding("ASCII-8BIT") rescue nil
      nanstr2.force_encoding("ASCII-8BIT") rescue nil
      nanstr3.force_encoding("ASCII-8BIT") rescue nil
      nanstr4.force_encoding("ASCII-8BIT") rescue nil
      nan1 = nanstr1.unpack("G")[0]
      nan2 = nanstr2.unpack("G")[0]
      nan3 = nanstr3.unpack("G")[0]
      nan4 = nanstr4.unpack("G")[0]

      obj = new_unchecked(nan1, nan2, nan3, nan4)
      assert_equal([obj.red].pack("G"), nanstr1)
      assert_equal([obj.green].pack("G"), nanstr2)
      assert_equal([obj.blue].pack("G"), nanstr3)
      assert_equal([obj.alpha].pack("G"), nanstr4)
    end

    def test_equal_1
      obj1 = @@klass.new(55.5, 77.75, 88.875, 111.125)
      obj2 = @@klass.new(55.5, 77.75, 88.875, 111.125)
      assert_equal(obj1 == obj2, true)
      assert_equal(obj1 === obj2, true)
      assert_equal(obj1.eql?(obj2), true)
      assert_equal(obj2 == obj1, true)
      assert_equal(obj2 === obj1, true)
      assert_equal(obj2.eql?(obj1), true)

      obj3 = @@klass.new(55.50000000000001, 77.75, 88.875, 111.125)
      assert_equal(obj1 == obj3, false)
      assert_equal(obj1 === obj3, false)
      assert_equal(obj1.eql?(obj3), false)
      assert_equal(obj3 == obj1, false)
      assert_equal(obj3 === obj1, false)
      assert_equal(obj3.eql?(obj1), false)

      obj3 = @@klass.new(55.5, 77.75000000000001, 88.875, 111.125)
      assert_equal(obj1 == obj3, false)
      assert_equal(obj1 === obj3, false)
      assert_equal(obj1.eql?(obj3), false)
      assert_equal(obj3 == obj1, false)
      assert_equal(obj3 === obj1, false)
      assert_equal(obj3.eql?(obj1), false)

      obj3 = @@klass.new(55.5, 77.75, 88.87500000000001, 111.125)
      assert_equal(obj1 == obj3, false)
      assert_equal(obj1 === obj3, false)
      assert_equal(obj1.eql?(obj3), false)
      assert_equal(obj3 == obj1, false)
      assert_equal(obj3 === obj1, false)
      assert_equal(obj3.eql?(obj1), false)

      obj3 = @@klass.new(55.5, 77.75, 88.875, 111.12500000000001)
      assert_equal(obj1 == obj3, false)
      assert_equal(obj1 === obj3, false)
      assert_equal(obj1.eql?(obj3), false)
      assert_equal(obj3 == obj1, false)
      assert_equal(obj3 === obj1, false)
      assert_equal(obj3.eql?(obj1), false)
    end

    def test_equal_minus_zero
      obj1 = @@klass.new(0.0, 0.0, 0.0, 0.0)
      obj2 = @@klass.new(-0.0, -0.0, -0.0, -0.0)
      assert_equal(obj1 == obj2, true)
      assert_equal(obj1 === obj2, true)
      assert_equal(obj1.eql?(obj2), true)
      assert_equal(obj2 == obj1, true)
      assert_equal(obj2 === obj1, true)
      assert_equal(obj2.eql?(obj1), true)
    end

    def test_equal_nan
      obj = @@klass.new(0.0 / 0.0, 0.0, 0.0, 0.0)
      assert_equal(obj == obj, false)
      assert_equal(obj === obj, false)
      assert_equal(obj.eql?(obj), false)
      assert_equal(obj == obj, false)
      assert_equal(obj === obj, false)
      assert_equal(obj.eql?(obj), false)

      obj = @@klass.new(0.0, 0.0 / 0.0, 0.0, 0.0)
      assert_equal(obj == obj, false)
      assert_equal(obj === obj, false)
      assert_equal(obj.eql?(obj), false)
      assert_equal(obj == obj, false)
      assert_equal(obj === obj, false)
      assert_equal(obj.eql?(obj), false)

      obj = @@klass.new(0.0, 0.0, 0.0 / 0.0, 0.0)
      assert_equal(obj == obj, false)
      assert_equal(obj === obj, false)
      assert_equal(obj.eql?(obj), false)
      assert_equal(obj == obj, false)
      assert_equal(obj === obj, false)
      assert_equal(obj.eql?(obj), false)

      obj = @@klass.new(0.0, 0.0, 0.0, 0.0 / 0.0)
      assert_equal(obj == obj, false)
      assert_equal(obj === obj, false)
      assert_equal(obj.eql?(obj), false)
      assert_equal(obj == obj, false)
      assert_equal(obj === obj, false)
      assert_equal(obj.eql?(obj), false)
    end

    def test_equal_typeerror
      obj = @@klass.new(0.0, 0.0, 0.0, 0.0)
      if RGSS == 3
        assert_equal(obj == "hoge", false)
        assert_equal(obj === "hoge", false)
        assert_equal(obj.eql?("hoge"), false)
        assert_equal(obj == Tone.new(0.0, 0.0, 0.0, 0.0), false)
        assert_equal(obj === Tone.new(0.0, 0.0, 0.0, 0.0), false)
        assert_equal(obj.eql?(Tone.new(0.0, 0.0, 0.0, 0.0)), false)
      else
        assert_raise(TypeError) { obj == @@klass }
        assert_raise(TypeError) { obj === @@klass }
        assert_raise(TypeError) { obj.eql?(@@klass) }
        assert_raise(TypeError) { obj == Tone.new(0.0, 0.0, 0.0, 0.0) }
        assert_raise(TypeError) { obj === Tone.new(0.0, 0.0, 0.0, 0.0) }
        assert_raise(TypeError) { obj.eql?(Tone.new(0.0, 0.0, 0.0, 0.0)) }
      end
      assert_equal(:hoge == obj, false)
      assert_equal(:hoge === obj, false)
      assert_equal(:hoge.eql?(obj), false)
    end

    def test_dump_1
      obj = @@klass.new(5.5, 6.0, 6.5, 7.0)
      assert_equal(obj._dump(0), "\x00\x00\x00\x00\x00\x00\x16\x40\x00\x00\x00\x00\x00\x00\x18\x40\x00\x00\x00\x00\x00\x00\x1A\x40\x00\x00\x00\x00\x00\x00\x1C\x40")
    end

    def test_dump_2
      obj = @@klass.new(5.5, 6.0, 6.5, 7.0)
      assert_equal(obj._dump(-1), "\x00\x00\x00\x00\x00\x00\x16\x40\x00\x00\x00\x00\x00\x00\x18\x40\x00\x00\x00\x00\x00\x00\x1A\x40\x00\x00\x00\x00\x00\x00\x1C\x40")
    end

    def test_dump_3
      obj = @@klass.new(5.5, 6.0, 6.5, 7.0)
      assert_equal(obj._dump("hoge"), "\x00\x00\x00\x00\x00\x00\x16\x40\x00\x00\x00\x00\x00\x00\x18\x40\x00\x00\x00\x00\x00\x00\x1A\x40\x00\x00\x00\x00\x00\x00\x1C\x40")
    end

    def test_dump_4
      nanstr1 = "\x7f\xfe\xee\xdd\x01\x23\x45\x67"
      nanstr2 = "\xff\xfe\xee\xdd\xfa\x07\x7c\xbc"
      nanstr3 = "\x7f\xf8\x00\x00\x00\x00\x00\x01"
      nanstr4 = "\xff\xff\x00\x00\x13\x00\x00\x01"
      nanstr1.force_encoding("ASCII-8BIT") rescue nil
      nanstr2.force_encoding("ASCII-8BIT") rescue nil
      nanstr3.force_encoding("ASCII-8BIT") rescue nil
      nanstr4.force_encoding("ASCII-8BIT") rescue nil
      nan1 = nanstr1.unpack("G")[0]
      nan2 = nanstr2.unpack("G")[0]
      nan3 = nanstr3.unpack("G")[0]
      nan4 = nanstr4.unpack("G")[0]
      obj = @@klass.new(nan1, nan2, nan3, nan4)
      compar = "\x67\x45\x23\x01\xdd\xee\xfe\x7f\xbc\x7c\x07\xfa\xdd\xee\xfe\xff\x01\x00\x00\x00\x00\x00\xf8\x7f\x01\x00\x00\x13\x00\x00\xff\xff"
      compar.force_encoding("ASCII-8BIT") rescue nil
      assert_equal(obj._dump(0), compar)
    end
  end
end
