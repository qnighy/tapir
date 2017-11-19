# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestRPGEvent < Test
    @@klass = RPG::Event

    def test_superclass
      assert_equal(@@klass.superclass, Object)
    end

    def test_constants
      assert_symset_equal(@@klass.constants, [:Page])
    end

    def test_class_variables
      assert_symset_equal(@@klass.class_variables, [])
    end

    def test_class_methods
      assert_symset_equal(@@klass.methods - Object.methods, [])
    end

    def test_instance_methods
      assert_symset_equal(owned_instance_methods(@@klass), [
        :id, :id=, :name, :name=, :pages, :pages=, :x, :x=, :y, :y=])
    end

    def test_instance_variables
      obj = @@klass.new(7, 6)
      assert_symset_equal(obj.instance_variables, [
        :@id, :@name, :@pages, :@x, :@y])
    end


    def test_new
      obj = @@klass.new(7, 6)

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      assert_raise(ArgumentError) { @@klass.new(:hoge, :fuga, :piyo) }
      assert_equal(obj.id, 0)
      assert_equal(obj.name, "")
      assert_equal(obj.pages.size, 1)
      assert_equal(obj.pages[0].class, RPG::Event::Page)
      assert_equal(obj.x, 7)
      assert_equal(obj.y, 6)
    end
  end

  class TestRPGEventPage < Test
    @@klass = RPG::Event::Page

    def test_superclass
      assert_equal(@@klass.superclass, Object)
    end

    def test_constants
      assert_symset_equal(@@klass.constants, [:Condition, :Graphic])
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
          :condition, :condition=, :direction_fix, :direction_fix=, :graphic,
          :graphic=, :list, :list=, :move_frequency, :move_frequency=,
          :move_route, :move_route=, :move_speed, :move_speed=, :move_type,
          :move_type=, :priority_type, :priority_type=, :step_anime,
          :step_anime=, :through, :through=, :trigger, :trigger=, :walk_anime,
          :walk_anime=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :always_on_top, :always_on_top=, :condition, :condition=,
          :direction_fix, :direction_fix=, :graphic, :graphic=, :list, :list=,
          :move_frequency, :move_frequency=, :move_route, :move_route=,
          :move_speed, :move_speed=, :move_type, :move_type=, :step_anime,
          :step_anime=, :through, :through=, :trigger, :trigger=, :walk_anime,
          :walk_anime=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS >= 2
        assert_symset_equal(obj.instance_variables, [
          :@condition, :@direction_fix, :@graphic, :@list, :@move_frequency,
          :@move_route, :@move_speed, :@move_type, :@priority_type,
          :@step_anime, :@through, :@trigger, :@walk_anime])
      else
        assert_symset_equal(obj.instance_variables, [
          :@always_on_top, :@condition, :@direction_fix, :@graphic, :@list,
          :@move_frequency, :@move_route, :@move_speed, :@move_type,
          :@step_anime, :@through, :@trigger, :@walk_anime])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      if RGSS >= 2
        assert_equal(obj.condition.class, RPG::Event::Page::Condition)
        assert_equal(obj.direction_fix, false)
        assert_equal(obj.graphic.class, RPG::Event::Page::Graphic)
        assert_equal(obj.list.size, 1)
        assert_equal(obj.list[0].class, RPG::EventCommand)
        assert_equal(obj.move_frequency, 3)
        assert_equal(obj.move_route.class, RPG::MoveRoute)
        assert_equal(obj.move_speed, 3)
        assert_equal(obj.move_type, 0)
        assert_equal(obj.priority_type, 0)
        assert_equal(obj.step_anime, false)
        assert_equal(obj.through, false)
        assert_equal(obj.trigger, 0)
        assert_equal(obj.walk_anime, true)
      else
        assert_equal(obj.always_on_top, false)
        assert_equal(obj.condition.class, RPG::Event::Page::Condition)
        assert_equal(obj.direction_fix, false)
        assert_equal(obj.graphic.class, RPG::Event::Page::Graphic)
        assert_equal(obj.list.size, 1)
        assert_equal(obj.list[0].class, RPG::EventCommand)
        assert_equal(obj.move_frequency, 3)
        assert_equal(obj.move_speed, 3)
        assert_equal(obj.move_type, 0)
        assert_equal(obj.step_anime, false)
        assert_equal(obj.through, false)
        assert_equal(obj.trigger, 0)
        assert_equal(obj.walk_anime, true)
      end
    end
  end

  class TestRPGEventPageCondition < Test
    @@klass = RPG::Event::Page::Condition

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
          :actor_id, :actor_id=, :actor_valid, :actor_valid=, :item_id,
          :item_id=, :item_valid, :item_valid=, :self_switch_ch,
          :self_switch_ch=, :self_switch_valid, :self_switch_valid=,
          :switch1_id, :switch1_id=, :switch1_valid, :switch1_valid=,
          :switch2_id, :switch2_id=, :switch2_valid, :switch2_valid=,
          :variable_id, :variable_id=, :variable_valid, :variable_valid=,
          :variable_value, :variable_value=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :self_switch_ch, :self_switch_ch=, :self_switch_valid,
          :self_switch_valid=, :switch1_id, :switch1_id=, :switch1_valid,
          :switch1_valid=, :switch2_id, :switch2_id=, :switch2_valid,
          :switch2_valid=, :variable_id, :variable_id=, :variable_valid,
          :variable_valid=, :variable_value, :variable_value=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS >= 2
        assert_symset_equal(obj.instance_variables, [
          :@actor_id, :@actor_valid, :@item_id, :@item_valid, :@self_switch_ch,
          :@self_switch_valid, :@switch1_id, :@switch1_valid, :@switch2_id,
          :@switch2_valid, :@variable_id, :@variable_valid, :@variable_value])
      else
        assert_symset_equal(obj.instance_variables, [
          :@self_switch_ch, :@self_switch_valid, :@switch1_id, :@switch1_valid,
          :@switch2_id, :@switch2_valid, :@variable_id, :@variable_valid,
          :@variable_value])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      if RGSS >= 2
        assert_equal(obj.actor_id, 1)
        assert_equal(obj.actor_valid, false)
        assert_equal(obj.item_id, 1)
        assert_equal(obj.item_valid, false)
        assert_equal(obj.self_switch_ch, "A")
        assert_equal(obj.self_switch_valid, false)
        assert_equal(obj.switch1_id, 1)
        assert_equal(obj.switch1_valid, false)
        assert_equal(obj.switch2_id, 1)
        assert_equal(obj.switch2_valid, false)
        assert_equal(obj.variable_id, 1)
        assert_equal(obj.variable_valid, false)
        assert_equal(obj.variable_value, 0)
      else
        assert_equal(obj.self_switch_ch, "A")
        assert_equal(obj.self_switch_valid, false)
        assert_equal(obj.switch1_id, 1)
        assert_equal(obj.switch1_valid, false)
        assert_equal(obj.switch2_id, 1)
        assert_equal(obj.switch2_valid, false)
        assert_equal(obj.variable_id, 1)
        assert_equal(obj.variable_valid, false)
        assert_equal(obj.variable_value, 0)
      end
    end
  end

  class TestRPGEventPageGraphic < Test
    @@klass = RPG::Event::Page::Graphic

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
          :character_index, :character_index=, :character_name,
          :character_name=, :direction, :direction=, :pattern, :pattern=,
          :tile_id, :tile_id=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :blend_type, :blend_type=, :character_hue, :character_hue=,
          :character_name, :character_name=, :direction, :direction=, :opacity,
          :opacity=, :pattern, :pattern=, :tile_id, :tile_id=])
      end
    end

    def test_instance_variables
      obj = @@klass.new

      if RGSS >= 2
        assert_symset_equal(obj.instance_variables, [
          :@character_index, :@character_name, :@direction, :@pattern,
          :@tile_id])
      else
        assert_symset_equal(obj.instance_variables, [
          :@blend_type, :@character_hue, :@character_name, :@direction,
          :@opacity, :@pattern, :@tile_id])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      if RGSS >= 2
        assert_equal(obj.character_index, 0)
        assert_equal(obj.character_name, "")
        assert_equal(obj.direction, 2)
        assert_equal(obj.pattern, 0)
        assert_equal(obj.tile_id, 0)
      else
        assert_equal(obj.blend_type, 0)
        assert_equal(obj.character_hue, 0)
        assert_equal(obj.character_name, "")
        assert_equal(obj.direction, 2)
        assert_equal(obj.opacity, 255)
        assert_equal(obj.pattern, 0)
        assert_equal(obj.tile_id, 0)
      end
    end
  end

  class TestRPGEventCommand < Test
    @@klass = RPG::EventCommand

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
        :code, :code=, :indent, :indent=, :parameters, :parameters=])
    end

    def test_instance_variables
      obj = @@klass.new

      assert_symset_equal(obj.instance_variables, [
        :@code, :@indent, :@parameters])
    end

    def test_new
      obj = @@klass.new
      assert_equal(obj.code, 0)
      assert_equal(obj.indent, 0)
      assert_equal(obj.parameters, [])

      obj = @@klass.new(:hoge)
      assert_equal(obj.code, :hoge)
      assert_equal(obj.indent, 0)
      assert_equal(obj.parameters, [])

      obj = @@klass.new(:hoge, :fuga)
      assert_equal(obj.code, :hoge)
      assert_equal(obj.indent, :fuga)
      assert_equal(obj.parameters, [])

      obj = @@klass.new(:hoge, :fuga, :piyo)
      assert_equal(obj.code, :hoge)
      assert_equal(obj.indent, :fuga)
      assert_equal(obj.parameters, :piyo)

      assert_raise(ArgumentError) { @@klass.new(:hoge, :fuga, :piyo, :quux) }
    end
  end

  class TestRPGMoveRoute < Test
    @@klass = RPG::MoveRoute

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
          :list, :list=, :repeat, :repeat=, :skippable, :skippable=, :wait,
          :wait=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :list, :list=, :repeat, :repeat=, :skippable, :skippable=])
      end
    end

    def test_instance_variables
      obj = @@klass.new

      if RGSS >= 2
        assert_symset_equal(obj.instance_variables, [
          :@list, :@repeat, :@skippable, :@wait])
      else
        assert_symset_equal(obj.instance_variables, [
          :@list, :@repeat, :@skippable])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }

      assert_equal(obj.list.size, 1)
      assert_equal(obj.list[0].class, RPG::MoveCommand)
      assert_equal(obj.repeat, true)
      assert_equal(obj.skippable, false)
      assert_equal(obj.wait, false) if RGSS >= 2
    end
  end

  class TestRPGMoveCommand < Test
    @@klass = RPG::MoveCommand

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
        :code, :code=, :parameters, :parameters=])
    end

    def test_instance_variables
      obj = @@klass.new

      assert_symset_equal(obj.instance_variables, [:@code, :@parameters])
    end

    def test_new
      obj = @@klass.new
      assert_equal(obj.code, 0)
      assert_equal(obj.parameters, [])

      obj = @@klass.new(:hoge)
      assert_equal(obj.code, :hoge)
      assert_equal(obj.parameters, [])

      obj = @@klass.new(:hoge, :fuga)
      assert_equal(obj.code, :hoge)
      assert_equal(obj.parameters, :fuga)

      assert_raise(ArgumentError) { @@klass.new(:hoge, :fuga, :piyo) }
    end
  end
end
