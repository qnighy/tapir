# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestRPG < Test
    @@klass = RPG

    def test_is_module
      assert_equal(@@klass.class, Module)
    end

    def test_constants
      if RGSS == 3
        assert_symset_equal(@@klass.constants, [
          :Actor, :Animation, :Armor, :AudioFile, :BGM, :BGS, :BaseItem,
          :Class, :CommonEvent, :Enemy, :EquipItem, :Event, :EventCommand,
          :Item, :ME, :Map, :MapInfo, :MoveCommand, :MoveRoute, :SE, :Skill,
          :State, :System, :Tileset, :Troop, :UsableItem, :Weapon])
      elsif RGSS == 2
        assert_symset_equal(@@klass.constants, [
          :Actor, :Animation, :Area, :Armor, :AudioFile, :BGM, :BGS,
          :BaseItem, :Class, :CommonEvent, :Enemy, :Event, :EventCommand,
          :Item, :ME, :Map, :MapInfo, :MoveCommand, :MoveRoute, :SE, :Skill,
          :State, :System, :Troop, :UsableItem, :Weapon])
      else
        assert_symset_equal(@@klass.constants, [
          :Actor, :Animation, :Armor, :AudioFile, :Cache, :Class, :CommonEvent,
          :Enemy, :Event, :EventCommand, :Item, :Map, :MapInfo, :MoveCommand,
          :MoveRoute, :Skill, :Sprite, :State, :System, :Tileset, :Troop,
          :Weapon, :Weather])
      end
    end

    def test_class_variables
      assert_symset_equal(@@klass.class_variables, [])
    end

    def test_class_methods
      assert_symset_equal(@@klass.methods - Object.methods, [])
    end
  end
end
