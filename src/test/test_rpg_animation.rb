# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestRPGAnimation < Test
    @@klass = RPG::Animation

    def test_superclass
      assert_equal(@@klass.superclass, Object)
    end

    def test_constants
      assert_symset_equal(@@klass.constants, [:Frame, :Timing])
    end

    def test_class_variables
      assert_symset_equal(@@klass.class_variables, [])
    end

    def test_class_methods
      assert_symset_equal(@@klass.methods - Object.methods, [])
    end

    def test_instance_methods
      if RGSS == 3
        assert_symset_equal(owned_instance_methods(@@klass), [
          :animation1_hue, :animation1_hue=, :animation1_name,
          :animation1_name=, :animation2_hue, :animation2_hue=,
          :animation2_name, :animation2_name=, :frame_max, :frame_max=,
          :frames, :frames=, :id, :id=, :name, :name=, :position, :position=,
          :timings, :timings=, :to_screen?])
      elsif RGSS == 2
        assert_symset_equal(owned_instance_methods(@@klass), [
          :animation1_hue, :animation1_hue=, :animation1_name,
          :animation1_name=, :animation2_hue, :animation2_hue=,
          :animation2_name, :animation2_name=, :frame_max, :frame_max=,
          :frames, :frames=, :id, :id=, :name, :name=, :position, :position=,
          :timings, :timings=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :animation_hue, :animation_hue=, :animation_name, :animation_name=,
          :frame_max, :frame_max=, :frames, :frames=, :id, :id=, :name, :name=,
          :position, :position=, :timings, :timings=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS >= 2
        assert_symset_equal(obj.instance_variables, [
          :@animation1_hue, :@animation1_name, :@animation2_hue,
          :@animation2_name, :@frame_max, :@frames, :@id, :@name, :@position,
          :@timings])
      else
        assert_symset_equal(obj.instance_variables, [
          :@animation_hue, :@animation_name, :@frame_max, :@frames, :@id,
          :@name, :@position, :@timings])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      if RGSS >= 2
        assert_equal(obj.animation1_hue, 0)
        assert_equal(obj.animation1_name, "")
        assert_equal(obj.animation2_hue, 0)
        assert_equal(obj.animation2_name, "")
      else
        assert_equal(obj.animation_hue, 0)
        assert_equal(obj.animation_name, "")
      end
      assert_equal(obj.frame_max, 1)
      assert_equal(obj.frames.size, 1)
      assert_equal(obj.frames[0].class, RPG::Animation::Frame)
      assert_equal(obj.frames[0].cell_data.class, Table)
      assert_equal(obj.frames[0].cell_data._dump(0), Table.new(0, 0)._dump(0))
      assert_equal(obj.frames[0].cell_max, 0)
      assert_equal(obj.id, 0)
      assert_equal(obj.name, "")
      assert_equal(obj.position, 1)
      assert_equal(obj.timings, [])
    end

    if RGSS == 3
    def test_to_screen_p
      obj = @@klass.new
      obj.position = 0
      assert_equal(obj.to_screen?, false)
      obj.position = 1
      assert_equal(obj.to_screen?, false)
      obj.position = 2
      assert_equal(obj.to_screen?, false)
      obj.position = 3
      assert_equal(obj.to_screen?, true)
    end
    end # if RGSS == 3
  end

  class TestRPGAnimationFrame < Test
    @@klass = RPG::Animation::Frame

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
        :cell_data, :cell_data=, :cell_max, :cell_max=])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [:@cell_data, :@cell_max])
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      assert_equal(obj.cell_data.class, Table)
      assert_equal(obj.cell_data._dump(0), Table.new(0, 0)._dump(0))
      assert_equal(obj.cell_max, 0)
    end
  end

  class TestRPGAnimationTiming < Test
    @@klass = RPG::Animation::Timing

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
      if RGSS >= 2
        assert_symset_equal(owned_instance_methods(@@klass), [
          :flash_color, :flash_color=, :flash_duration, :flash_duration=,
          :flash_scope, :flash_scope=, :frame, :frame=, :se, :se=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :condition, :condition=, :flash_color, :flash_color=,
          :flash_duration, :flash_duration=, :flash_scope, :flash_scope=,
          :frame, :frame=, :se, :se=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS >= 2
        assert_symset_equal(obj.instance_variables, [
          :@flash_color, :@flash_duration, :@flash_scope, :@frame, :@se])
      else
        assert_symset_equal(obj.instance_variables, [
          :@condition, :@flash_color, :@flash_duration, :@flash_scope, :@frame,
          :@se])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      assert_equal(obj.condition, 0) if RGSS == 1
      assert_equal(obj.flash_color, Color.new(255, 255, 255, 255))
      assert_equal(obj.flash_duration, 5)
      assert_equal(obj.flash_scope, 0)
      assert_equal(obj.frame, 0)
      if RGSS >= 2
        assert_equal(obj.se.class, RPG::SE)
        assert_equal(obj.se.name, "")
        assert_equal(obj.se.pitch, 100)
        assert_equal(obj.se.volume, 80)
      else
        assert_equal(obj.se.class, RPG::AudioFile)
        assert_equal(obj.se.name, "")
        assert_equal(obj.se.pitch, 100)
        assert_equal(obj.se.volume, 80)
      end
    end
  end
end
