# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestFont < Test
    @@klass = Font

    def restore_defaults
      begin
        default_name = Font.default_name
        default_size = Font.default_size
        default_bold = Font.default_bold
        default_italic = Font.default_italic
        default_color = Font.default_color
        default_shadow = Font.default_shadow if RGSS >= 2
        default_outline = Font.default_outline if RGSS == 3
        default_out_color = Font.default_out_color if RGSS == 3
        yield
      ensure
        Font.default_name = default_name
        Font.default_size = default_size
        Font.default_bold = default_bold
        Font.default_italic = default_italic
        Font.default_color = default_color
        Font.default_shadow = default_shadow if RGSS >= 2
        Font.default_outline = default_outline if RGSS == 3
        Font.default_out_color = default_out_color if RGSS == 3
      end
    end

    def set_default1
      Font.default_name = "DejaVu Sans"
      Font.default_size = 87
      Font.default_bold = false
      Font.default_italic = false
      Font.default_color = Color.new(135.0, 175.5, 13.0, 254.0)
      Font.default_shadow = false if RGSS >= 2
      Font.default_outline = false if RGSS == 3
      Font.default_out_color = Color.new(33.0, 158.75, 0.75, 3.0) if RGSS == 3
    end

    def set_default2
      Font.default_name = "DejaVu Serif"
      Font.default_size = 95
      Font.default_bold = true
      Font.default_italic = true
      Font.default_color = Color.new(22.0, 33.0, 44.0, 55.0)
      Font.default_shadow = true if RGSS >= 2
      Font.default_outline = true if RGSS == 3
      Font.default_out_color = Color.new(122.0, 133.0, 144.0, 155.0) if RGSS == 3
    end

    def test_superclass
      assert_equal(@@klass.superclass, Object)
    end

    def test_constants
      assert_symset_equal(@@klass.constants, [])
    end

    def test_class_variables
      if RGSS == 3
        assert_symset_equal(@@klass.class_variables, [
          :@@default_bold, :@@default_color, :@@default_italic,
          :@@default_name, :@@default_out_color, :@@default_outline,
          :@@default_shadow, :@@default_size])
      elsif RGSS == 2
        assert_symset_equal(@@klass.class_variables, [
          :@@default_bold, :@@default_color, :@@default_italic,
          :@@default_name, :@@default_shadow, :@@default_size])
      else
        assert_symset_equal(@@klass.class_variables, [
          :@@default_bold, :@@default_color, :@@default_italic,
          :@@default_name, :@@default_size])
      end
    end

    def test_class_methods
      if RGSS == 3
        assert_symset_equal(@@klass.methods - Object.methods, [
          :default_bold, :default_bold=, :default_color, :default_color=,
          :default_italic, :default_italic=, :default_name, :default_name=,
          :default_out_color, :default_out_color=, :default_outline,
          :default_outline=, :default_shadow, :default_shadow=, :default_size,
          :default_size=, :exist?])
      elsif RGSS == 2
        assert_symset_equal(@@klass.methods - Object.methods, [
          :default_bold, :default_bold=, :default_color, :default_color=,
          :default_italic, :default_italic=, :default_name, :default_name=,
          :default_shadow, :default_shadow=, :default_size, :default_size=,
          :exist?])
      else
        assert_symset_equal(@@klass.methods - Object.methods, [
          :default_bold, :default_bold=, :default_color, :default_color=,
          :default_italic, :default_italic=, :default_name, :default_name=,
          :default_size, :default_size=, :exist?])
      end
    end

    def test_instance_methods
      if RGSS == 3
        assert_symset_equal(owned_instance_methods(@@klass), [
          :bold, :bold=, :color, :color=, :italic, :italic=, :name, :name=,
          :out_color, :out_color=, :outline, :outline=, :shadow, :shadow=,
          :size, :size=])
      elsif RGSS == 2
        assert_symset_equal(owned_instance_methods(@@klass), [
          :bold, :bold=, :color, :color=, :italic, :italic=, :name, :name=,
          :shadow, :shadow=, :size, :size=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :bold, :bold=, :color, :color=, :italic, :italic=, :name, :name=,
          :size, :size=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [])
    end

    def test_new_1
      @@klass.new
    end

    def test_new_2
      restore_defaults do
        set_default1
        obj = @@klass.new
        set_default2
        assert_equal(obj.name, "DejaVu Sans")
        assert_equal(obj.size, 87)
        assert_equal(obj.bold, false)
        assert_equal(obj.italic, false)
        assert_equal(obj.color, Color.new(135.0, 175.5, 13.0, 254.0))
        assert_equal(obj.shadow, false) if RGSS >= 2
        assert_equal(obj.outline, false) if RGSS == 3
        assert_equal(obj.out_color, Color.new(33.0, 158.75, 0.75, 3.0)) if RGSS == 3

        set_default1
        obj = @@klass.new("DejaVu Mono")
        set_default2
        assert_equal(obj.name, "DejaVu Mono")
        assert_equal(obj.size, 87)
        assert_equal(obj.bold, false)
        assert_equal(obj.italic, false)
        assert_equal(obj.color, Color.new(135.0, 175.5, 13.0, 254.0))
        assert_equal(obj.shadow, false) if RGSS >= 2
        assert_equal(obj.outline, false) if RGSS == 3
        assert_equal(obj.out_color, Color.new(33.0, 158.75, 0.75, 3.0)) if RGSS == 3

        set_default1
        obj = @@klass.new("DejaVu Mono", 55)
        set_default2
        assert_equal(obj.name, "DejaVu Mono")
        assert_equal(obj.size, 55)
        assert_equal(obj.bold, false)
        assert_equal(obj.italic, false)
        assert_equal(obj.color, Color.new(135.0, 175.5, 13.0, 254.0))
        assert_equal(obj.shadow, false) if RGSS >= 2
        assert_equal(obj.outline, false) if RGSS == 3
        assert_equal(obj.out_color, Color.new(33.0, 158.75, 0.75, 3.0)) if RGSS == 3
      end
    end

    def test_new_3
      restore_defaults do
        set_default2
        obj = @@klass.new
        assert_equal(obj.name, "DejaVu Serif")
        assert_equal(obj.size, 95)
        assert_equal(obj.bold, true)
        assert_equal(obj.italic, true)
        assert_equal(obj.color, Color.new(22.0, 33.0, 44.0, 55.0))
        assert_equal(obj.shadow, true) if RGSS >= 2
        assert_equal(obj.outline, true) if RGSS == 3
        assert_equal(obj.out_color, Color.new(122.0, 133.0, 144.0, 155.0)) if RGSS == 3

        set_default2
        obj = @@klass.new("DejaVu Mono")
        assert_equal(obj.name, "DejaVu Mono")
        assert_equal(obj.size, 95)
        assert_equal(obj.bold, true)
        assert_equal(obj.italic, true)
        assert_equal(obj.color, Color.new(22.0, 33.0, 44.0, 55.0))
        assert_equal(obj.shadow, true) if RGSS >= 2
        assert_equal(obj.outline, true) if RGSS == 3
        assert_equal(obj.out_color, Color.new(122.0, 133.0, 144.0, 155.0)) if RGSS == 3

        set_default2
        obj = @@klass.new("DejaVu Mono", 55)
        assert_equal(obj.name, "DejaVu Mono")
        assert_equal(obj.size, 55)
        assert_equal(obj.bold, true)
        assert_equal(obj.italic, true)
        assert_equal(obj.color, Color.new(22.0, 33.0, 44.0, 55.0))
        assert_equal(obj.shadow, true) if RGSS >= 2
        assert_equal(obj.outline, true) if RGSS == 3
        assert_equal(obj.out_color, Color.new(122.0, 133.0, 144.0, 155.0)) if RGSS == 3
      end
    end

    def test_new_argerror
      assert_raise(ArgumentError) { @@klass.new("DejaVu Mono", 55, true) }
      assert_raise(ArgumentError) { @@klass.new("DejaVu Mono", 55, true, true) }
    end

    def test_new_int_range
      assert_nothing_raised(ArgumentError) { @@klass.new("DejaVu Mono", 95) }
      assert_nothing_raised(ArgumentError) { @@klass.new("DejaVu Mono", 96) }
      assert_raise(ArgumentError) { @@klass.new("DejaVu Mono", 97) }
      assert_raise(ArgumentError) { @@klass.new("DejaVu Mono", 98) }
      assert_nothing_raised(ArgumentError) { @@klass.new("DejaVu Mono", 7) }
      assert_nothing_raised(ArgumentError) { @@klass.new("DejaVu Mono", 6) }
      assert_raise(ArgumentError) { @@klass.new("DejaVu Mono", 5) }
      assert_raise(ArgumentError) { @@klass.new("DejaVu Mono", 4) }
    end

    def test_new_float_range
      assert_nothing_raised(ArgumentError) { @@klass.new("DejaVu Mono", 96.8) }
      assert_nothing_raised(ArgumentError) { @@klass.new("DejaVu Mono", 96.9) }
      assert_raise(ArgumentError) { @@klass.new("DejaVu Mono", 97.0) }
      assert_raise(ArgumentError) { @@klass.new("DejaVu Mono", 97.1) }
      assert_nothing_raised(ArgumentError) { @@klass.new("DejaVu Mono", 6.1) }
      assert_nothing_raised(ArgumentError) { @@klass.new("DejaVu Mono", 6.0) }
      assert_raise(ArgumentError) { @@klass.new("DejaVu Mono", 5.9) }
      assert_raise(ArgumentError) { @@klass.new("DejaVu Mono", 5.8) }
    end

    def test_new_nan
      assert_nothing_raised(ArgumentError) { @@klass.new("DejaVu Mono", 0.0 / 0.0) }
    end

    def test_new_typeerror
      assert_raise(TypeError) { @@klass.new("DejaVu Mono", "55") }
      assert_nothing_raised(TypeError) { @@klass.new("\x80\xE0\x00", 55) }
      assert_nothing_raised(TypeError) { @@klass.new(:hoge, 55) }
      assert_nothing_raised(TypeError) { @@klass.new(nil, 55) }
    end

    def test_new_float
      restore_defaults do
        set_default1
        obj = @@klass.new("DejaVu Mono", 21.75)
        assert_equal(obj.size, 21.75)

        obj = @@klass.new("DejaVu Mono", 21.0)
        assert_equal(obj.size.class, Float)

        obj = @@klass.new("DejaVu Mono", 21)
        assert_equal(obj.size.class, Fixnum)
      end
    end

    def test_new_int_proxy
      x = Object.new
      def x.to_int
        10
      end
      y = Object.new
      restore_defaults do
        set_default1
        obj = @@klass.new("DejaVu Mono", x)
        assert_equal(obj.size, x)

        assert_raise(TypeError) { @@klass.new("DejaVu Mono", y) }
      end
    end

    def test_new_float_proxy
      x = Object.new
      def x.to_f
        10.0
      end
      y = Object.new
      def y.class
        Float
      end
      restore_defaults do
        set_default1
        assert_raise(TypeError) { @@klass.new("DejaVu Mono", x) }
        assert_raise(TypeError) { @@klass.new("DejaVu Mono", y) }
      end
    end

    def test_new_setter_override
      font_sub = Class.new(@@klass)
      font_sub.class_eval do
        attr_writer :name, :size, :bold, :italic, :color
        attr_writer :shadow if RGSS >= 2
        attr_writer :outline, :out_color if RGSS == 3
      end
      restore_defaults do
        set_default1
        obj = font_sub.new
        assert_equal(obj.name, nil)
        assert_equal(obj.size, nil)
        assert_equal(obj.bold, nil)
        assert_equal(obj.italic, nil)
        assert_equal(obj.color, Color.new(135.0, 175.5, 13.0, 254.0))
        assert_equal(obj.shadow, nil) if RGSS >= 2
        assert_equal(obj.outline, nil) if RGSS == 3
        assert_equal(obj.out_color, Color.new(33.0, 158.75, 0.75, 3.0)) if RGSS == 3
        assert_equal(obj.instance_variable_get(:@name), "DejaVu Sans")
        assert_equal(obj.instance_variable_get(:@size), 87)
        assert_equal(obj.instance_variable_get(:@bold), false)
        assert_equal(obj.instance_variable_get(:@italic), false)
        assert_equal(obj.instance_variable_get(:@color), nil)
        assert_equal(obj.instance_variable_get(:@shadow), false) if RGSS >= 2
        assert_equal(obj.instance_variable_get(:@outline), false) if RGSS == 3
        assert_equal(obj.instance_variable_get(:@out_color), nil) if RGSS == 3

        set_default2
        obj = font_sub.new
        assert_equal(obj.name, nil)
        assert_equal(obj.size, nil)
        assert_equal(obj.bold, nil)
        assert_equal(obj.italic, nil)
        assert_equal(obj.color, Color.new(22.0, 33.0, 44.0, 55.0))
        assert_equal(obj.shadow, nil) if RGSS >= 2
        assert_equal(obj.outline, nil) if RGSS == 3
        assert_equal(obj.out_color, Color.new(122.0, 133.0, 144.0, 155.0)) if RGSS == 3
        assert_equal(obj.instance_variable_get(:@name), "DejaVu Serif")
        assert_equal(obj.instance_variable_get(:@size), 95)
        assert_equal(obj.instance_variable_get(:@bold), true)
        assert_equal(obj.instance_variable_get(:@italic), true)
        assert_equal(obj.instance_variable_get(:@color), nil)
        assert_equal(obj.instance_variable_get(:@shadow), true) if RGSS >= 2
        assert_equal(obj.instance_variable_get(:@outline), true) if RGSS == 3
        assert_equal(obj.instance_variable_get(:@out_color), nil) if RGSS == 3
      end
    end

    def test_set_name
      obj = @@klass.new
      obj.name = name = "DejaVu Mono"
      assert(obj.name.equal?(name))
      obj.name = name = "\x80\xE0\x00"
      assert(obj.name.equal?(name))
      obj.name = name = :hoge
      assert(obj.name.equal?(name))
      obj.name = name = nil
      assert(obj.name.equal?(name))
    end

    def test_set_size
      obj = @@klass.new
      obj.size = 31
      assert_equal(obj.size, 31)
      assert_equal(obj.size.class, Fixnum)
      obj.size = 90
      assert_equal(obj.size, 90)
      assert_equal(obj.size.class, Fixnum)
      obj.size = 28.0
      assert_equal(obj.size, 28.0)
      assert_equal(obj.size.class, Float)
      obj.size = 50.5
      assert_equal(obj.size, 50.5)
      assert_equal(obj.size.class, Float)
    end

    def test_set_size_int_range
      obj = @@klass.new
      assert_nothing_raised(ArgumentError) { obj.size = 95 }
      assert_nothing_raised(ArgumentError) { obj.size = 96 }
      assert_raise(ArgumentError) { obj.size = 97 }
      assert_raise(ArgumentError) { obj.size = 98 }
      assert_nothing_raised(ArgumentError) { obj.size = 7 }
      assert_nothing_raised(ArgumentError) { obj.size = 6 }
      assert_raise(ArgumentError) { obj.size = 5 }
      assert_raise(ArgumentError) { obj.size = 4 }
    end

    def test_set_size_float_range
      obj = @@klass.new
      assert_nothing_raised(ArgumentError) { obj.size = 96.8 }
      assert_nothing_raised(ArgumentError) { obj.size = 96.9 }
      assert_raise(ArgumentError) { obj.size = 97.0 }
      assert_raise(ArgumentError) { obj.size = 97.1 }
      assert_nothing_raised(ArgumentError) { obj.size = 6.1 }
      assert_nothing_raised(ArgumentError) { obj.size = 6.0 }
      assert_raise(ArgumentError) { obj.size = 5.9 }
      assert_raise(ArgumentError) { obj.size = 5.8 }
    end

    def test_set_size_nan
      obj = @@klass.new
      assert_nothing_raised(ArgumentError) { obj.size = 0.0 / 0.0 }
    end

    def test_set_size_typeerror
      obj = @@klass.new
      assert_raise(TypeError) { obj.size = "55" }
    end

    def test_set_size_float
      obj = @@klass.new
      obj.size = 21.75
      assert_equal(obj.size, 21.75)

      obj.size = 21.0
      assert_equal(obj.size.class, Float)

      obj.size = 21
      assert_equal(obj.size.class, Fixnum)
    end

    def test_set_size_int_proxy
      x = Object.new
      def x.to_int
        10
      end
      y = Object.new
      obj = @@klass.new
      obj.size = x
      assert_equal(obj.size, x)
      assert_raise(TypeError) { obj.size = y }
    end

    def test_set_size_float_proxy
      x = Object.new
      def x.to_f
        10.0
      end
      y = Object.new
      def y.class
        Float
      end
      obj = @@klass.new
      assert_raise(TypeError) { obj.size = x }
      assert_raise(TypeError) { obj.size = y }
    end

    def test_set_bold
      obj = @@klass.new
      obj.bold = true
      assert_equal(obj.bold, true)
      obj.bold = false
      assert_equal(obj.bold, false)
      obj.bold = nil
      assert_equal(obj.bold, false)
      obj.bold = 0
      assert_equal(obj.bold, true)
    end

    def test_set_italic
      obj = @@klass.new
      obj.italic = true
      assert_equal(obj.italic, true)
      obj.italic = false
      assert_equal(obj.italic, false)
      obj.italic = nil
      assert_equal(obj.italic, false)
      obj.italic = 0
      assert_equal(obj.italic, true)
    end

    def test_set_color
      obj = @@klass.new
      c = obj.color
      obj.color = Color.new(77.5, 88.5, 99.5, 110.5)
      assert_equal(obj.color, Color.new(77.5, 88.5, 99.5, 110.5))
      assert(obj.color.equal?(c))
      obj.color = Color.new(77.0, 88.0, 99.0, 110.0)
      assert_equal(obj.color, Color.new(77.0, 88.0, 99.0, 110.0))
      assert(obj.color.equal?(c))
    end

    def test_set_color_typeerror
      obj = @@klass.new
      assert_raise(TypeError) { obj.color = "hoge" }
      assert_raise(TypeError) { obj.color = nil }
      assert_raise(TypeError) { obj.color = Tone.new(0.0, 0.0, 0.0, 0.0) }
    end

    def test_color_hook
      myFont = Class.new(Font) do
        def color=(c)
          @color = c
          super
        end
      end
      f = myFont.new
      c = f.color
      if RGSS == 3
        f.instance_variable_set(:@color, nil)
        c.set(Color.new(10, 20, 10, 30))
        assert_equal(f.instance_variable_get(:@color), c)
        assert(f.instance_variable_get(:@color).equal?(c))
      end
      f.instance_variable_set(:@color, nil)
      c.red = 50
      assert(f.instance_variable_get(:@color).equal?(c))
    end

    if RGSS >= 2
    def test_set_shadow
      obj = @@klass.new
      obj.shadow = true
      assert_equal(obj.shadow, true)
      obj.shadow = false
      assert_equal(obj.shadow, false)
      obj.shadow = nil
      assert_equal(obj.shadow, false)
      obj.shadow = 0
      assert_equal(obj.shadow, true)
    end
    end # if RGSS >= 2

    if RGSS == 3
    def test_set_outline
      obj = @@klass.new
      obj.outline = true
      assert_equal(obj.outline, true)
      obj.outline = false
      assert_equal(obj.outline, false)
      obj.outline = nil
      assert_equal(obj.outline, false)
      obj.outline = 0
      assert_equal(obj.outline, true)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_set_out_color
      obj = @@klass.new
      c = obj.out_color
      obj.out_color = Color.new(77.5, 88.5, 99.5, 110.5)
      assert_equal(obj.out_color, Color.new(77.5, 88.5, 99.5, 110.5))
      assert(obj.out_color.equal?(c))
      obj.out_color = Color.new(77.0, 88.0, 99.0, 110.0)
      assert_equal(obj.out_color, Color.new(77.0, 88.0, 99.0, 110.0))
      assert(obj.out_color.equal?(c))
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_out_color_hook
      myFont = Class.new(Font) do
        def out_color=(c)
          @out_color = c
          super
        end
      end
      f = myFont.new
      c = f.out_color
      f.instance_variable_set(:@out_color, nil)
      c.set(Color.new(10, 20, 10, 30))
      assert_equal(f.instance_variable_get(:@out_color), c)
      assert(f.instance_variable_get(:@out_color).equal?(c))
      f.instance_variable_set(:@out_color, nil)
      c.red = 50
      assert(f.instance_variable_get(:@out_color).equal?(c))
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_set_out_color_typeerror
      obj = @@klass.new
      assert_raise(TypeError) { obj.out_color = "hoge" }
      assert_raise(TypeError) { obj.out_color = nil }
      assert_raise(TypeError) { obj.out_color = Tone.new(0.0, 0.0, 0.0, 0.0) }
    end
    end # if RGSS == 3

    def test_set_retval
      obj = @@klass.new
      name = "DejaVu Mono"
      assert(obj.send(:name=, name).equal?(name))
      assert_equal(obj.send(:name=, :hoge), :hoge)
      assert_equal(obj.send(:name=, nil), nil)
      assert_equal(obj.send(:size=, 40), 40)
      assert_equal(obj.send(:size=, 40.5), 40.5)
      x = Object.new
      def x.to_int
        10
      end
      assert_equal(obj.send(:size=, x), x)
      assert_equal(obj.send(:bold=, 100), true)
      assert_equal(obj.send(:bold=, nil), false)
      assert_equal(obj.send(:italic=, 100), true)
      assert_equal(obj.send(:italic=, nil), false)
      newval = Color.new(1.0, 2.0, 3.0, 4.0)
      assert(obj.send(:color=, newval).equal?(newval))
      assert_equal(obj.send(:shadow=, 100), true) if RGSS >= 2
      assert_equal(obj.send(:shadow=, nil), false) if RGSS >= 2
      if RGSS == 3
        assert_equal(obj.send(:outline=, 100), true)
        assert_equal(obj.send(:outline=, nil), false)
        newval = Color.new(1.0, 2.0, 3.0, 4.0)
        assert(obj.send(:out_color=, newval).equal?(newval))
      end
    end

    def test_set_default_name
      restore_defaults do
        @@klass.default_name = name = "DejaVu Mono"
        assert(@@klass.default_name.equal?(name))
        @@klass.default_name = name = "\x80\xE0\x00"
        assert(@@klass.default_name.equal?(name))
        @@klass.default_name = name = :hoge
        assert(@@klass.default_name.equal?(name))
        @@klass.default_name = name = nil
        assert(@@klass.default_name.equal?(name))
      end
    end

    def test_set_default_size
      restore_defaults do
        @@klass.default_size = 31
        assert_equal(@@klass.default_size, 31)
        assert_equal(@@klass.default_size.class, Fixnum)
        @@klass.default_size = 90
        assert_equal(@@klass.default_size, 90)
        assert_equal(@@klass.default_size.class, Fixnum)
        @@klass.default_size = 28.0
        assert_equal(@@klass.default_size, 28.0)
        assert_equal(@@klass.default_size.class, Float)
        @@klass.default_size = 50.5
        assert_equal(@@klass.default_size, 50.5)
        assert_equal(@@klass.default_size.class, Float)
      end
    end

    def test_set_default_size_int_range
      restore_defaults do
        assert_nothing_raised(ArgumentError) { @@klass.default_size = 95 }
        assert_nothing_raised(ArgumentError) { @@klass.default_size = 96 }
        assert_raise(ArgumentError) { @@klass.default_size = 97 }
        assert_raise(ArgumentError) { @@klass.default_size = 98 }
        assert_nothing_raised(ArgumentError) { @@klass.default_size = 7 }
        assert_nothing_raised(ArgumentError) { @@klass.default_size = 6 }
        assert_raise(ArgumentError) { @@klass.default_size = 5 }
        assert_raise(ArgumentError) { @@klass.default_size = 4 }
      end
    end

    def test_set_default_size_float_range
      restore_defaults do
        assert_nothing_raised(ArgumentError) { @@klass.default_size = 96.8 }
        assert_nothing_raised(ArgumentError) { @@klass.default_size = 96.9 }
        assert_raise(ArgumentError) { @@klass.default_size = 97.0 }
        assert_raise(ArgumentError) { @@klass.default_size = 97.1 }
        assert_nothing_raised(ArgumentError) { @@klass.default_size = 6.1 }
        assert_nothing_raised(ArgumentError) { @@klass.default_size = 6.0 }
        assert_raise(ArgumentError) { @@klass.default_size = 5.9 }
        assert_raise(ArgumentError) { @@klass.default_size = 5.8 }
      end
    end

    def test_set_default_size_nan
      restore_defaults do
        assert_nothing_raised(ArgumentError) {
          @@klass.default_size = 0.0 / 0.0
        }
      end
    end

    def test_set_default_size_typeerror
      restore_defaults do
        assert_raise(TypeError) { @@klass.default_size = "55" }
      end
    end

    def test_set_default_size_float
      restore_defaults do
        @@klass.default_size = 21.75
        assert_equal(@@klass.default_size, 21.75)

        @@klass.default_size = 21.0
        assert_equal(@@klass.default_size.class, Float)

        @@klass.default_size = 21
        assert_equal(@@klass.default_size.class, Fixnum)
      end
    end

    def test_set_default_size_int_proxy
      restore_defaults do
        x = Object.new
        def x.to_int
          10
        end
        y = Object.new
        @@klass.default_size = x
        assert_equal(@@klass.default_size, x)
        assert_raise(TypeError) { @@klass.default_size = y }
      end
    end

    def test_set_default_size_float_proxy
      restore_defaults do
        x = Object.new
        def x.to_f
          10.0
        end
        y = Object.new
        def y.class
          Float
        end
        assert_raise(TypeError) { @@klass.default_size = x }
        assert_raise(TypeError) { @@klass.default_size = y }
      end
    end

    # TODO: add more tests
  end
end
