# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestRPGTroop < Test
    @@klass = RPG::Troop

    def test_superclass
      assert_equal(@@klass.superclass, Object)
    end

    def test_constants
      assert_symset_equal(@@klass.constants, [:Member, :Page])
    end

    def test_class_variables
      assert_symset_equal(@@klass.class_variables, [])
    end

    def test_class_methods
      assert_symset_equal(@@klass.methods - Object.methods, [])
    end

    def test_instance_methods
      assert_symset_equal(owned_instance_methods(@@klass), [
        :id, :id=, :members, :members=, :name, :name=, :pages, :pages=])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [
        :@id, :@members, :@name, :@pages])
    end


    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      assert_equal(obj.id, 0)
      assert_equal(obj.members, [])
      assert_equal(obj.name, "")
      assert_equal(obj.pages.size, 1)
      assert_equal(obj.pages[0].class, RPG::Troop::Page)
      assert_equal(obj.pages[0].condition.class, RPG::Troop::Page::Condition)
      assert_equal(obj.pages[0].condition.actor_hp, 50)
      assert_equal(obj.pages[0].condition.actor_id, 1)
      assert_equal(obj.pages[0].condition.actor_valid, false)
      assert_equal(obj.pages[0].condition.enemy_hp, 50)
      assert_equal(obj.pages[0].condition.enemy_index, 0)
      assert_equal(obj.pages[0].condition.enemy_valid, false)
      assert_equal(obj.pages[0].condition.switch_id, 1)
      assert_equal(obj.pages[0].condition.switch_valid, false)
      assert_equal(obj.pages[0].condition.turn_a, 0)
      assert_equal(obj.pages[0].condition.turn_b, 0)
      assert_equal(obj.pages[0].condition.turn_ending, false) if RGSS >= 2
      assert_equal(obj.pages[0].condition.turn_valid, false)
      assert_equal(obj.pages[0].list.size, 1)
      assert_equal(obj.pages[0].list[0].class, RPG::EventCommand)
      assert_equal(obj.pages[0].list[0].code, 0)
      assert_equal(obj.pages[0].list[0].indent, 0)
      assert_equal(obj.pages[0].list[0].parameters, [])
      assert_equal(obj.pages[0].span, 0)
    end
  end

  class TestRPGTroopMember < Test
    @@klass = RPG::Troop::Member

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
      if RGSS == 3
        assert_symset_equal(owned_instance_methods(@@klass), [
          :enemy_id, :enemy_id=, :hidden, :hidden=, :x, :x=, :y, :y=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :enemy_id, :enemy_id=, :hidden, :hidden=, :immortal, :immortal=, :x,
          :x=, :y, :y=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@enemy_id, :@hidden, :@x, :@y])
      else
        assert_symset_equal(obj.instance_variables, [
          :@enemy_id, :@hidden, :@immortal, :@x, :@y])
      end
    end


    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      assert_equal(obj.enemy_id, 1)
      assert_equal(obj.hidden, false)
      assert_equal(obj.immortal, false) if RGSS <= 2
      assert_equal(obj.x, 0)
      assert_equal(obj.y, 0)
    end
  end

  class TestRPGTroopPage < Test
    @@klass = RPG::Troop::Page

    def test_superclass
      assert_equal(@@klass.superclass, Object)
    end

    def test_constants
      assert_symset_equal(@@klass.constants, [:Condition])
    end

    def test_class_variables
      assert_symset_equal(@@klass.class_variables, [])
    end

    def test_class_methods
      assert_symset_equal(@@klass.methods - Object.methods, [])
    end

    def test_instance_methods
      assert_symset_equal(owned_instance_methods(@@klass), [
        :condition, :condition=, :list, :list=, :span, :span=])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [
        :@condition, :@list, :@span])
    end


    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      assert_equal(obj.condition.class, RPG::Troop::Page::Condition)
      assert_equal(obj.condition.actor_hp, 50)
      assert_equal(obj.condition.actor_id, 1)
      assert_equal(obj.condition.actor_valid, false)
      assert_equal(obj.condition.enemy_hp, 50)
      assert_equal(obj.condition.enemy_index, 0)
      assert_equal(obj.condition.enemy_valid, false)
      assert_equal(obj.condition.switch_id, 1)
      assert_equal(obj.condition.switch_valid, false)
      assert_equal(obj.condition.turn_a, 0)
      assert_equal(obj.condition.turn_b, 0)
      assert_equal(obj.condition.turn_ending, false) if RGSS >= 2
      assert_equal(obj.condition.turn_valid, false)
      assert_equal(obj.list.size, 1)
      assert_equal(obj.list[0].class, RPG::EventCommand)
      assert_equal(obj.list[0].code, 0)
      assert_equal(obj.list[0].indent, 0)
      assert_equal(obj.list[0].parameters, [])
      assert_equal(obj.span, 0)
    end
  end

  class TestRPGTroopPageCondition < Test
    @@klass = RPG::Troop::Page::Condition

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
          :actor_hp, :actor_hp=, :actor_id, :actor_id=, :actor_valid,
          :actor_valid=, :enemy_hp, :enemy_hp=, :enemy_index, :enemy_index=,
          :enemy_valid, :enemy_valid=, :switch_id, :switch_id=, :switch_valid,
          :switch_valid=, :turn_a, :turn_a=, :turn_b, :turn_b=, :turn_ending,
          :turn_ending=, :turn_valid, :turn_valid=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :actor_hp, :actor_hp=, :actor_id, :actor_id=, :actor_valid,
          :actor_valid=, :enemy_hp, :enemy_hp=, :enemy_index, :enemy_index=,
          :enemy_valid, :enemy_valid=, :switch_id, :switch_id=, :switch_valid,
          :switch_valid=, :turn_a, :turn_a=, :turn_b, :turn_b=, :turn_valid,
          :turn_valid=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS >= 2
        assert_symset_equal(obj.instance_variables, [
          :@actor_hp, :@actor_id, :@actor_valid, :@enemy_hp, :@enemy_index,
          :@enemy_valid, :@switch_id, :@switch_valid, :@turn_a, :@turn_b,
          :@turn_ending, :@turn_valid])
      else
        assert_symset_equal(obj.instance_variables, [
          :@actor_hp, :@actor_id, :@actor_valid, :@enemy_hp, :@enemy_index,
          :@enemy_valid, :@switch_id, :@switch_valid, :@turn_a, :@turn_b,
          :@turn_valid])
      end
    end


    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      assert_equal(obj.actor_hp, 50)
      assert_equal(obj.actor_id, 1)
      assert_equal(obj.actor_valid, false)
      assert_equal(obj.enemy_hp, 50)
      assert_equal(obj.enemy_index, 0)
      assert_equal(obj.enemy_valid, false)
      assert_equal(obj.switch_id, 1)
      assert_equal(obj.switch_valid, false)
      assert_equal(obj.turn_a, 0)
      assert_equal(obj.turn_b, 0)
      assert_equal(obj.turn_ending, false) if RGSS >= 2
      assert_equal(obj.turn_valid, false)
    end
  end
end
