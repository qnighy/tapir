# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  if RGSS == 1
  class TestRPGWeather < Test
    @@klass = RPG::Weather

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
      assert_symset_equal(owned_instance_methods(@@klass), [
        :dispose, :max, :max=, :ox, :ox=, :oy, :oy=, :type, :type=, :update])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [
        :@max, :@ox, :@oy, :@rain_bitmap, :@snow_bitmap, :@sprites,
        :@storm_bitmap, :@type])
    end

    def test_new
      obj = @@klass.new
      obj = @@klass.new(Viewport.new(0, 0, 0, 0))
      assert_raise(ArgumentError) { @@klass.new(:hoge, :fuga) }
      assert_raise(TypeError) { @@klass.new(:hoge) }

      rain_expected = Bitmap.new("../../src/test/Graphics/rain_bitmap.png")
      snow_expected = Bitmap.new("../../src/test/Graphics/snow_bitmap.png")
      storm_expected = Bitmap.new("../../src/test/Graphics/storm_bitmap.png")

      obj = @@klass.new
      assert_equal(obj.instance_eval("@max"), 0)
      assert_equal(obj.instance_eval("@ox"), 0)
      assert_equal(obj.instance_eval("@oy"), 0)
      assert_bitmap_equal2("rain_bitmap", obj.instance_eval("@rain_bitmap"))
      assert_bitmap_equal2("snow_bitmap", obj.instance_eval("@snow_bitmap"))
      # assert_equal(obj.instance_eval("@sprites"), nil)
      assert_bitmap_equal2("storm_bitmap", obj.instance_eval("@storm_bitmap"))
      assert_equal(obj.instance_eval("@type"), 0)
    end
  end
  end # if RGSS == 1
end
