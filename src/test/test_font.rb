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

    GROUND_DEFAULTS = Hash.new
    @@klass.class_variables.each do|class_variable|
      GROUND_DEFAULTS[class_variable] = @@klass.class_eval("#{class_variable}")
    end

    def restore_defaults
      begin
        yield
      ensure
        GROUND_DEFAULTS.each do|class_variable,value|
          @@klass.class_eval(
            "#{class_variable} = GROUND_DEFAULTS[#{class_variable.inspect}]")
        end
      end
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

    # TODO: add more tests
  end
end
