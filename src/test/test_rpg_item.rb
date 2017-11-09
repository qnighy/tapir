# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  if RGSS >= 2
  class TestRPGBaseItem < Test
    @@klass = RPG::BaseItem

    def test_superclass
      assert_equal(@@klass.superclass, Object)
    end

    def test_constants
      if RGSS == 3
        assert_symset_equal(@@klass.constants, [:Feature])
      else
        assert_symset_equal(@@klass.constants, [])
      end
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
          :description, :description=, :features, :features=, :icon_index,
          :icon_index=, :id, :id=, :name, :name=, :note, :note=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :description, :description=, :icon_index, :icon_index=, :id, :id=,
          :name, :name=, :note, :note=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@description, :@features, :@icon_index, :@id, :@name, :@note])
      else
        assert_symset_equal(obj.instance_variables, [
          :@description, :@icon_index, :@id, :@name, :@note])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }

      assert_equal(obj.description, "")
      assert_equal(obj.features, []) if RGSS == 3
      assert_equal(obj.icon_index, 0)
      assert_equal(obj.id, 0)
      assert_equal(obj.name, "")
      assert_equal(obj.note, "")
    end
  end
  end # if RGSS >= 2

  if RGSS == 3
  class TestRPGBaseItemFeature < Test
    @@klass = RPG::BaseItem::Feature

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
        :code, :code=, :data_id, :data_id=, :value, :value=])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [:@code, :@data_id, :@value])
    end

    def test_new
      obj = @@klass.new
      assert_equal(obj.code, 0)
      assert_equal(obj.data_id, 0)
      assert_equal(obj.value, 0)

      obj = @@klass.new(:hoge)
      assert_equal(obj.code, :hoge)
      assert_equal(obj.data_id, 0)
      assert_equal(obj.value, 0)

      obj = @@klass.new(:hoge, :fuga)
      assert_equal(obj.code, :hoge)
      assert_equal(obj.data_id, :fuga)
      assert_equal(obj.value, 0)

      obj = @@klass.new(:hoge, :fuga, :piyo)
      assert_equal(obj.code, :hoge)
      assert_equal(obj.data_id, :fuga)
      assert_equal(obj.value, :piyo)

      assert_raise(ArgumentError) { @@klass.new(:hoge, :fuga, :piyo, :quux) }
    end
  end
  end # if RGSS == 3

  class TestRPGActor < Test
    @@klass = RPG::Actor

    def test_superclass
      if RGSS == 3
        assert_equal(@@klass.superclass, RPG::BaseItem)
      else
        assert_equal(@@klass.superclass, Object)
      end
    end

    def test_constants
      if RGSS == 3
        assert_symset_equal(@@klass.constants, [:Feature])
        assert_equal(@@klass::Feature, RPG::BaseItem::Feature)
      else
        assert_symset_equal(@@klass.constants, [])
      end
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
          :character_index, :character_index=, :character_name,
          :character_name=, :class_id, :class_id=, :equips, :equips=,
          :face_index, :face_index=, :face_name, :face_name=, :initial_level,
          :initial_level=, :max_level, :max_level=, :nickname, :nickname=])
      elsif RGSS == 2
        assert_symset_equal(owned_instance_methods(@@klass), [
          :armor1_id, :armor1_id=, :armor2_id, :armor2_id=, :armor3_id,
          :armor3_id=, :armor4_id, :armor4_id=, :auto_battle, :auto_battle=,
          :character_index, :character_index=, :character_name,
          :character_name=, :class_id, :class_id=, :critical_bonus,
          :critical_bonus=, :exp_basis, :exp_basis=, :exp_inflation,
          :exp_inflation=, :face_index, :face_index=, :face_name, :face_name=,
          :fix_equipment, :fix_equipment=, :id, :id=, :initial_level,
          :initial_level=, :name, :name=, :parameters, :parameters=,
          :pharmacology, :pharmacology=, :super_guard, :super_guard=,
          :two_swords_style, :two_swords_style=, :weapon_id, :weapon_id=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :armor1_fix, :armor1_fix=, :armor1_id, :armor1_id=, :armor2_fix,
          :armor2_fix=, :armor2_id, :armor2_id=, :armor3_fix, :armor3_fix=,
          :armor3_id, :armor3_id=, :armor4_fix, :armor4_fix=, :armor4_id,
          :armor4_id=, :battler_hue, :battler_hue=, :battler_name,
          :battler_name=, :character_hue, :character_hue=, :character_name,
          :character_name=, :class_id, :class_id=, :exp_basis, :exp_basis=,
          :exp_inflation, :exp_inflation=, :final_level, :final_level=, :id,
          :id=, :initial_level, :initial_level=, :name, :name=, :parameters,
          :parameters=, :weapon_fix, :weapon_fix=, :weapon_id, :weapon_id=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@character_index, :@character_name, :@class_id, :@description,
          :@equips, :@face_index, :@face_name, :@features, :@icon_index, :@id,
          :@initial_level, :@max_level, :@name, :@nickname, :@note])
      elsif RGSS == 2
        assert_symset_equal(obj.instance_variables, [
          :@armor1_id, :@armor2_id, :@armor3_id, :@armor4_id, :@auto_battle,
          :@character_index, :@character_name, :@class_id, :@critical_bonus,
          :@exp_basis, :@exp_inflation, :@face_index, :@face_name,
          :@fix_equipment, :@id, :@initial_level, :@name, :@parameters,
          :@pharmacology, :@super_guard, :@two_swords_style, :@weapon_id])
      else
        assert_symset_equal(obj.instance_variables, [
          :@armor1_fix, :@armor1_id, :@armor2_fix, :@armor2_id, :@armor3_fix,
          :@armor3_id, :@armor4_fix, :@armor4_id, :@battler_hue,
          :@battler_name, :@character_hue, :@character_name, :@class_id,
          :@exp_basis, :@exp_inflation, :@final_level, :@id, :@initial_level,
          :@name, :@parameters, :@weapon_fix, :@weapon_id])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      if RGSS == 3
        assert_equal(obj.character_index, 0)
        assert_equal(obj.character_name, "")
        assert_equal(obj.class_id, 1)
        assert_equal(obj.description, "")
        assert_equal(obj.equips, [0, 0, 0, 0, 0])
        assert_equal(obj.face_index, 0)
        assert_equal(obj.face_name, "")
        assert_equal(obj.features, [])
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.initial_level, 1)
        assert_equal(obj.max_level, 99)
        assert_equal(obj.name, "")
        assert_equal(obj.nickname, "")
        assert_equal(obj.note, "")
      elsif RGSS == 2
        expected_parameters = Table.new(6, 100)
        (1...100).each do|level|
          expected_parameters[0, level] = level * 50 + 400
          expected_parameters[1, level] = level * 10 + 80
          expected_parameters[2, level] = (level * 5 + 60) / 4
          expected_parameters[3, level] = (level * 5 + 60) / 4
          expected_parameters[4, level] = (level * 5 + 40) / 2
          expected_parameters[5, level] = (level * 5 + 40) / 2
        end
        assert_equal(obj.armor1_id, 0)
        assert_equal(obj.armor2_id, 0)
        assert_equal(obj.armor3_id, 0)
        assert_equal(obj.armor4_id, 0)
        assert_equal(obj.auto_battle, false)
        assert_equal(obj.character_index, 0)
        assert_equal(obj.character_name, "")
        assert_equal(obj.class_id, 1)
        assert_equal(obj.critical_bonus, false)
        assert_equal(obj.exp_basis, 25)
        assert_equal(obj.exp_inflation, 35)
        assert_equal(obj.face_index, 0)
        assert_equal(obj.face_name, "")
        assert_equal(obj.fix_equipment, false)
        assert_equal(obj.id, 0)
        assert_equal(obj.initial_level, 1)
        assert_equal(obj.name, "")
        assert_equal(obj.parameters.class, Table)
        assert_equal(obj.parameters._dump(0), expected_parameters._dump(0))
        assert_equal(obj.pharmacology, false)
        assert_equal(obj.super_guard, false)
        assert_equal(obj.two_swords_style, false)
        assert_equal(obj.weapon_id, 0)
      else
        expected_parameters = Table.new(6, 100)
        (1...100).each do|level|
          expected_parameters[0, level] = level * 50 + 500
          expected_parameters[1, level] = level * 50 + 500
          expected_parameters[2, level] = level * 5 + 50
          expected_parameters[3, level] = level * 5 + 50
          expected_parameters[4, level] = level * 5 + 50
          expected_parameters[5, level] = level * 5 + 50
        end
        assert_equal(obj.armor1_fix, false)
        assert_equal(obj.armor1_id, 0)
        assert_equal(obj.armor2_fix, false)
        assert_equal(obj.armor2_id, 0)
        assert_equal(obj.armor3_fix, false)
        assert_equal(obj.armor3_id, 0)
        assert_equal(obj.armor4_fix, false)
        assert_equal(obj.armor4_id, 0)
        assert_equal(obj.battler_hue, 0)
        assert_equal(obj.battler_name, "")
        assert_equal(obj.character_hue, 0)
        assert_equal(obj.character_name, "")
        assert_equal(obj.class_id, 1)
        assert_equal(obj.exp_basis, 30)
        assert_equal(obj.exp_inflation, 30)
        assert_equal(obj.final_level, 99)
        assert_equal(obj.id, 0)
        assert_equal(obj.initial_level, 1)
        assert_equal(obj.name, "")
        assert_equal(obj.parameters.class, Table)
        assert_equal(obj.parameters._dump(0), expected_parameters._dump(0))
        assert_equal(obj.weapon_fix, false)
        assert_equal(obj.weapon_id, 0)
      end
    end
  end

  class TestRPGClass < Test
    @@klass = RPG::Class

    def test_superclass
      if RGSS == 3
        assert_equal(@@klass.superclass, RPG::BaseItem)
      else
        assert_equal(@@klass.superclass, Object)
      end
    end

    def test_constants
      if RGSS == 3
        assert_symset_equal(@@klass.constants, [:Feature, :Learning])
        assert_equal(@@klass::Feature, RPG::BaseItem::Feature)
      else
        assert_symset_equal(@@klass.constants, [:Learning])
      end
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
          :exp_for_level, :exp_params, :exp_params=, :learnings, :learnings=,
          :params, :params=])
      elsif RGSS == 2
        assert_symset_equal(owned_instance_methods(@@klass), [
          :armor_set, :armor_set=, :element_ranks, :element_ranks=, :id, :id=,
          :learnings, :learnings=, :name, :name=, :position, :position=,
          :skill_name, :skill_name=, :skill_name_valid, :skill_name_valid=,
          :state_ranks, :state_ranks=, :weapon_set, :weapon_set=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :armor_set, :armor_set=, :element_ranks, :element_ranks=, :id, :id=,
          :learnings, :learnings=, :name, :name=, :position, :position=,
          :state_ranks, :state_ranks=, :weapon_set, :weapon_set=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@description, :@exp_params, :@features, :@icon_index, :@id,
          :@learnings, :@name, :@note, :@params])
      elsif RGSS == 2
        assert_symset_equal(obj.instance_variables, [
          :@armor_set, :@element_ranks, :@id, :@learnings, :@name,
          :@position, :@skill_name, :@skill_name_valid, :@state_ranks,
          :@weapon_set])
      else
        assert_symset_equal(obj.instance_variables, [
          :@armor_set, :@element_ranks, :@id, :@learnings, :@name,
          :@position, :@state_ranks, :@weapon_set])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      if RGSS == 3
        expected_parameters = Table.new(8, 100)
        (1...100).each do|level|
          expected_parameters[0, level] = level * 50 + 400
          expected_parameters[1, level] = level * 10 + 80
          expected_parameters[2, level] = (level * 5 + 60) / 4
          expected_parameters[3, level] = (level * 5 + 60) / 4
          expected_parameters[4, level] = (level * 5 + 60) / 4
          expected_parameters[5, level] = (level * 5 + 60) / 4
          expected_parameters[6, level] = (level * 5 + 60) / 2
          expected_parameters[7, level] = (level * 5 + 60) / 2
        end
        assert_equal(obj.description, "")
        assert_equal(obj.exp_params, [30, 20, 30, 30])
        assert_equal(obj.features.size, 7)
        assert_equal(obj.features[0].code, 23)
        assert_equal(obj.features[0].data_id, 0)
        assert_equal(obj.features[0].value, 1)
        assert_equal(obj.features[0].value.class, Fixnum)
        assert_equal(obj.features[1].code, 22)
        assert_equal(obj.features[1].data_id, 0)
        assert_equal(obj.features[1].value, 0.95)
        assert_equal(obj.features[2].code, 22)
        assert_equal(obj.features[2].data_id, 1)
        assert_equal(obj.features[2].value, 0.05)
        assert_equal(obj.features[3].code, 22)
        assert_equal(obj.features[3].data_id, 2)
        assert_equal(obj.features[3].value, 0.04)
        assert_equal(obj.features[4].code, 41)
        assert_equal(obj.features[4].data_id, 1)
        assert_equal(obj.features[4].value, 0)
        assert_equal(obj.features[0].value.class, Fixnum)
        assert_equal(obj.features[5].code, 51)
        assert_equal(obj.features[5].data_id, 1)
        assert_equal(obj.features[5].value, 0)
        assert_equal(obj.features[0].value.class, Fixnum)
        assert_equal(obj.features[6].code, 52)
        assert_equal(obj.features[6].data_id, 1)
        assert_equal(obj.features[6].value, 0)
        assert_equal(obj.features[0].value.class, Fixnum)
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.learnings, [])
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.params.class, Table)
        assert_equal(obj.params._dump(0), expected_parameters._dump(0))
      elsif RGSS == 2
        assert_equal(obj.armor_set, [])
        assert_equal(obj.element_ranks.class, Table)
        assert_equal(obj.element_ranks._dump(0), Table.new(1)._dump(0))
        assert_equal(obj.id, 0)
        assert_equal(obj.learnings, [])
        assert_equal(obj.name, "")
        assert_equal(obj.position, 0)
        assert_equal(obj.skill_name, "")
        assert_equal(obj.skill_name_valid, false)
        assert_equal(obj.state_ranks.class, Table)
        assert_equal(obj.state_ranks._dump(0), Table.new(1)._dump(0))
        assert_equal(obj.weapon_set, [])
      else
        assert_equal(obj.armor_set, [])
        assert_equal(obj.element_ranks.class, Table)
        assert_equal(obj.element_ranks._dump(0), Table.new(1)._dump(0))
        assert_equal(obj.id, 0)
        assert_equal(obj.learnings, [])
        assert_equal(obj.name, "")
        assert_equal(obj.position, 0)
        assert_equal(obj.state_ranks.class, Table)
        assert_equal(obj.state_ranks._dump(0), Table.new(1)._dump(0))
        assert_equal(obj.weapon_set, [])
      end
    end

    if RGSS == 3
    def test_exp_for_level_1
      obj = @@klass.new
      obj.exp_params = [0, 0, 25, 1.0/0.0]
      assert_equal(obj.exp_for_level(2), 0)
      assert_equal(obj.exp_for_level(50), 0)
      assert_equal(obj.exp_for_level(99), 0)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_exp_for_level_2
      obj = @@klass.new
      obj.exp_params = [0, 1, 25, 1.0/0.0]
      assert_equal(obj.exp_for_level(2), 1)
      assert_equal(obj.exp_for_level(50), 49)
      assert_equal(obj.exp_for_level(99), 98)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_exp_for_level_3
      obj = @@klass.new
      obj.exp_params = [0, 10, 25, 1.0/0.0]
      assert_equal(obj.exp_for_level(2), 10)
      assert_equal(obj.exp_for_level(50), 490)
      assert_equal(obj.exp_for_level(99), 980)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_exp_for_level_4
      obj = @@klass.new
      obj.exp_params = [0, 0.999, 25, 1.0/0.0]
      assert_equal(obj.exp_for_level(2), 1)
      assert_equal(obj.exp_for_level(50), 49)
      assert_equal(obj.exp_for_level(99), 98)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_exp_for_level_5
      obj = @@klass.new
      obj.exp_params = [1, 0, 25, 1.0/0.0]
      assert_equal(obj.exp_for_level(2), 1)
      assert_equal(obj.exp_for_level(3), 4)
      assert_equal(obj.exp_for_level(4), 10)
      assert_equal(obj.exp_for_level(5), 20)
      assert_equal(obj.exp_for_level(6), 35)
      assert_equal(obj.exp_for_level(7), 56)
      assert_equal(obj.exp_for_level(8), 84)
      assert_equal(obj.exp_for_level(9), 120)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_exp_for_level_6
      obj = @@klass.new
      obj.exp_params = [6, 0, 25, 1.0/0.0]
      assert_equal(obj.exp_for_level(2), 6)
      assert_equal(obj.exp_for_level(3), 24)
      assert_equal(obj.exp_for_level(4), 60)
      assert_equal(obj.exp_for_level(5), 120)
      assert_equal(obj.exp_for_level(6), 210)
      assert_equal(obj.exp_for_level(7), 336)
      assert_equal(obj.exp_for_level(8), 504)
      assert_equal(obj.exp_for_level(9), 720)
      assert_equal(obj.exp_for_level(10), 990)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_exp_for_level_7
      obj = @@klass.new
      obj.exp_params = [6, 0, -225, 1.0/0.0]
      assert_equal(obj.exp_for_level(2), 6)
      assert_equal(obj.exp_for_level(3), 12)
      assert_equal(obj.exp_for_level(4), 20)
      assert_equal(obj.exp_for_level(5), 30)
      assert_equal(obj.exp_for_level(6), 42)
      assert_equal(obj.exp_for_level(7), 56)
      assert_equal(obj.exp_for_level(8), 72)
      assert_equal(obj.exp_for_level(9), 90)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_exp_for_level_8
      obj = @@klass.new
      obj.exp_params = [6, 0, 275, 1.0/0.0]
      assert_equal(obj.exp_for_level(2), 6)
      assert_equal(obj.exp_for_level(3), 48)
      assert_equal(obj.exp_for_level(4), 180)
      assert_equal(obj.exp_for_level(5), 480)
      assert_equal(obj.exp_for_level(6), 1050)
      assert_equal(obj.exp_for_level(7), 2016)
      assert_equal(obj.exp_for_level(8), 3528)
      assert_equal(obj.exp_for_level(9), 5760)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_exp_for_level_9
      obj = @@klass.new
      obj.exp_params = [30, 0, 30, 1.0/0.0]
      assert_equal(obj.exp_for_level(2), 30)
      assert_equal(obj.exp_for_level(3), 122)
      assert_equal(obj.exp_for_level(4), 307)
      assert_equal(obj.exp_for_level(5), 617)
      assert_equal(obj.exp_for_level(10), 5172)
      assert_equal(obj.exp_for_level(20), 42320)
      assert_equal(obj.exp_for_level(33), 192405)
      assert_equal(obj.exp_for_level(64), 1423609)
      assert_equal(obj.exp_for_level(99), 5316867)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_exp_for_level_10
      obj = @@klass.new
      obj.exp_params = [10000, 0, 25, 1.0/0.0]
      assert_equal(obj.exp_for_level(2), 10000)
      assert_equal(obj.exp_for_level(3), 40000)
      assert_equal(obj.exp_for_level(4), 100000)
      assert_equal(obj.exp_for_level(5), 200000)
      assert_equal(obj.exp_for_level(6), 350000)
      assert_equal(obj.exp_for_level(7), 560000)
      assert_equal(obj.exp_for_level(8), 840000)
      assert_equal(obj.exp_for_level(9), 1200000)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_exp_for_level_11
      obj = @@klass.new
      obj.exp_params = [10000, 0, 25, 0.02]
      assert_equal(obj.exp_for_level(2), 6000)
      assert_equal(obj.exp_for_level(3), 16000)
      assert_equal(obj.exp_for_level(4), 27273)
      assert_equal(obj.exp_for_level(5), 38710)
      assert_equal(obj.exp_for_level(6), 50000)
      assert_equal(obj.exp_for_level(7), 61091)
      assert_equal(obj.exp_for_level(8), 72000)
      assert_equal(obj.exp_for_level(9), 82759)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_exp_for_level_12
      obj = @@klass.new
      obj.exp_params = [10000, 0, 25, 0.01]
      assert_equal(obj.exp_for_level(2), 4286)
      assert_equal(obj.exp_for_level(3), 10000)
      assert_equal(obj.exp_for_level(4), 15789)
      assert_equal(obj.exp_for_level(5), 21429)
      assert_equal(obj.exp_for_level(6), 26923)
      assert_equal(obj.exp_for_level(7), 32308)
      assert_equal(obj.exp_for_level(8), 37612)
      assert_equal(obj.exp_for_level(9), 42857)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_exp_for_level_13
      obj = @@klass.new
      obj.exp_params = [30, 0, 30, 30]
      assert_equal(obj.exp_for_level(2), 30)
      assert_equal(obj.exp_for_level(3), 122)
      assert_equal(obj.exp_for_level(4), 306)
      assert_equal(obj.exp_for_level(5), 615)
      assert_equal(obj.exp_for_level(10), 5116)
      assert_equal(obj.exp_for_level(20), 40519)
      assert_equal(obj.exp_for_level(44), 377709)
      assert_equal(obj.exp_for_level(78), 1543968)
      assert_equal(obj.exp_for_level(99), 2545173)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_exp_for_level_14
      obj = @@klass.new
      obj.exp_params = [0, 20, 30, 30]
      assert_equal(obj.exp_for_level(2), 20)
      assert_equal(obj.exp_for_level(3), 40)
      assert_equal(obj.exp_for_level(4), 60)
      assert_equal(obj.exp_for_level(5), 80)
      assert_equal(obj.exp_for_level(10), 180)
      assert_equal(obj.exp_for_level(20), 380)
      assert_equal(obj.exp_for_level(36), 700)
      assert_equal(obj.exp_for_level(56), 1100)
      assert_equal(obj.exp_for_level(99), 1960)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_exp_for_level_15
      obj = @@klass.new
      obj.exp_params = [30, 20, 30, 30]
      assert_equal(obj.exp_for_level(2), 50)
      assert_equal(obj.exp_for_level(3), 162)
      assert_equal(obj.exp_for_level(4), 366)
      assert_equal(obj.exp_for_level(5), 695)
      assert_equal(obj.exp_for_level(10), 5296)
      assert_equal(obj.exp_for_level(20), 40899)
      assert_equal(obj.exp_for_level(30), 131711)
      assert_equal(obj.exp_for_level(80), 1634055)
      assert_equal(obj.exp_for_level(99), 2547133)
    end
    end # if RGSS == 3
  end

  class TestRPGClassLearning < Test
    @@klass = RPG::Class::Learning

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
          :level, :level=, :note, :note=, :skill_id, :skill_id=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :level, :level=, :skill_id, :skill_id=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@level, :@note, :@skill_id])
      else
        assert_symset_equal(obj.instance_variables, [:@level, :@skill_id])
      end
    end

    def test_new
      obj = @@klass.new
      assert_equal(obj.level, 1)
      assert_equal(obj.note, "") if RGSS == 3
      assert_equal(obj.skill_id, 1)

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
    end
  end

  if RGSS >= 2
  class TestRPGUsableItem < Test
    @@klass = RPG::UsableItem

    def test_superclass
      assert_equal(@@klass.superclass, RPG::BaseItem)
    end

    def test_constants
      if RGSS == 3
        assert_symset_equal(@@klass.constants, [:Damage, :Effect, :Feature])
        assert_equal(@@klass::Feature, RPG::BaseItem::Feature)
      else
        assert_symset_equal(@@klass.constants, [])
      end
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
          :animation_id, :animation_id=, :battle_ok?, :certain?, :damage,
          :damage=, :effects, :effects=, :for_all?, :for_dead_friend?,
          :for_friend?, :for_one?, :for_opponent?, :for_random?, :for_user?,
          :hit_type, :hit_type=, :magical?, :menu_ok?, :need_selection?,
          :number_of_targets, :occasion, :occasion=, :physical?, :repeats,
          :repeats=, :scope, :scope=, :speed, :speed=, :success_rate,
          :success_rate=, :tp_gain, :tp_gain=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :absorb_damage, :absorb_damage=, :animation_id, :animation_id=,
          :atk_f, :atk_f=, :base_damage, :base_damage=, :battle_ok?,
          :common_event_id, :common_event_id=, :damage_to_mp, :damage_to_mp=,
          :dual?, :element_set, :element_set=, :for_all?, :for_dead_friend?,
          :for_friend?, :for_one?, :for_opponent?, :for_random?, :for_three?,
          :for_two?, :for_user?, :ignore_defense, :ignore_defense=, :menu_ok?,
          :minus_state_set, :minus_state_set=, :need_selection?, :occasion,
          :occasion=, :physical_attack, :physical_attack=, :plus_state_set,
          :plus_state_set=, :scope, :scope=, :speed, :speed=, :spi_f, :spi_f=,
          :variance, :variance=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@animation_id, :@damage, :@description, :@effects, :@features,
          :@hit_type, :@icon_index, :@id, :@name, :@note, :@occasion,
          :@repeats, :@scope, :@speed, :@success_rate, :@tp_gain])
      else
        assert_symset_equal(obj.instance_variables, [
          :@absorb_damage, :@animation_id, :@atk_f, :@base_damage,
          :@common_event_id, :@damage_to_mp, :@description, :@element_set,
          :@icon_index, :@id, :@ignore_defense, :@minus_state_set, :@name,
          :@note, :@occasion, :@physical_attack, :@plus_state_set, :@scope,
          :@speed, :@spi_f, :@variance])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }

      if RGSS == 3
        assert_equal(obj.animation_id, 0)
        assert_equal(obj.damage.class, RPG::UsableItem::Damage)
        assert_equal(obj.damage.type, 0)
        assert_equal(obj.damage.element_id, 0)
        assert_equal(obj.damage.formula, "0")
        assert_equal(obj.damage.variance, 20)
        assert_equal(obj.damage.critical, false)
        assert_equal(obj.description, "")
        assert_equal(obj.effects, [])
        assert_equal(obj.features, [])
        assert_equal(obj.hit_type, 0)
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.occasion, 0)
        assert_equal(obj.repeats, 1)
        assert_equal(obj.scope, 0)
        assert_equal(obj.speed, 0)
        assert_equal(obj.success_rate, 100)
        assert_equal(obj.tp_gain, 0)
      else
        assert_equal(obj.absorb_damage, false)
        assert_equal(obj.animation_id, 0)
        assert_equal(obj.atk_f, 0)
        assert_equal(obj.base_damage, 0)
        assert_equal(obj.common_event_id, 0)
        assert_equal(obj.damage_to_mp, false)
        assert_equal(obj.description, "")
        assert_equal(obj.element_set, [])
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.ignore_defense, false)
        assert_equal(obj.minus_state_set, [])
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.occasion, 0)
        assert_equal(obj.physical_attack, false)
        assert_equal(obj.plus_state_set, [])
        assert_equal(obj.scope, 0)
        assert_equal(obj.speed, 0)
        assert_equal(obj.spi_f, 0)
        assert_equal(obj.variance, 20)
      end
    end

    def test_battle_ok_p
      obj = @@klass.new
      assert_equal(
        (0..3).select {|x| obj.occasion = x; obj.battle_ok? },
        [0, 1])
    end

    if RGSS == 3
    def test_certain_p
      obj = @@klass.new
      assert_equal((0..2).select {|x| obj.hit_type = x; obj.certain? }, [0])
    end
    end # if RGSS == 3

    if RGSS == 2
    def test_dual_p
      obj = @@klass.new
      assert_equal((0..11).select {|x| obj.scope = x; obj.dual? }, [3])
    end
    end # if RGSS == 2

    def test_for_all_p
      obj = @@klass.new
      assert_equal(
        (0..11).select {|x| obj.scope = x; obj.for_all? },
        [2, 8, 10])
    end

    def test_for_dead_friend_p
      obj = @@klass.new
      assert_equal(
        (0..11).select {|x| obj.scope = x; obj.for_dead_friend? },
        [9, 10])
    end

    def test_for_friend_p
      obj = @@klass.new
      assert_equal(
        (0..11).select {|x| obj.scope = x; obj.for_friend? },
        [7, 8, 9, 10, 11])
    end

    def test_for_one_p
      obj = @@klass.new
      if RGSS == 3
        assert_equal(
          (0..11).select {|x| obj.scope = x; obj.for_one? },
          [1, 3, 7, 9, 11])
      else
        assert_equal(
          (0..11).select {|x| obj.scope = x; obj.for_one? },
          [1, 3, 4, 7, 9, 11])
      end
    end

    def test_for_opponent_p
      obj = @@klass.new
      assert_equal(
        (0..11).select {|x| obj.scope = x; obj.for_opponent? },
        [1, 2, 3, 4, 5, 6])
    end

    def test_for_random_p
      obj = @@klass.new
      if RGSS == 3
        assert_equal(
          (0..11).select {|x| obj.scope = x; obj.for_random? },
          [3, 4, 5, 6])
      else
        assert_equal(
          (0..11).select {|x| obj.scope = x; obj.for_random? },
          [4, 5, 6])
      end
    end

    if RGSS == 2
    def test_for_three_p
      obj = @@klass.new
      assert_equal((0..11).select {|x| obj.scope = x; obj.for_three? }, [6])
    end
    end # if RGSS == 2

    if RGSS == 2
    def test_for_two_p
      obj = @@klass.new
      assert_equal((0..11).select {|x| obj.scope = x; obj.for_two? }, [5])
    end
    end # if RGSS == 2

    def test_for_user_p
      obj = @@klass.new
      assert_equal((0..11).select {|x| obj.scope = x; obj.for_user? }, [11])
    end

    if RGSS == 3
    def test_magical_p
      obj = @@klass.new
      assert_equal((0..2).select {|x| obj.hit_type = x; obj.magical? }, [2])
    end
    end # if RGSS == 3

    def test_menu_ok_p
      obj = @@klass.new
      assert_equal((0..3).select {|x| obj.occasion = x; obj.menu_ok? }, [0, 2])
    end

    def test_need_selection_p
      obj = @@klass.new
      if RGSS == 3
        assert_equal(
          (0..11).select {|x| obj.scope = x; obj.need_selection? },
          [1, 7, 9])
      else
        assert_equal(
          (0..11).select {|x| obj.scope = x; obj.need_selection? },
          [1, 3, 7, 9])
      end
    end

    if RGSS == 3
    def test_number_of_targets
      obj = @@klass.new
      assert_equal(
        (0..11).map {|x| obj.scope = x; obj.number_of_targets },
        [0, 0, 0, 1, 2, 3, 4, 0, 0, 0, 0, 0])
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_physical_p
      obj = @@klass.new
      assert_equal((0..2).select {|x| obj.hit_type = x; obj.physical? }, [1])
    end
    end # if RGSS == 3
  end
  end # if RGSS >= 2

  if RGSS == 3
  class TestRPGUsableItemDamage < Test
    @@klass = RPG::UsableItem::Damage

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
        :critical, :critical=, :drain?, :element_id, :element_id=, :eval,
        :formula, :formula=, :none?, :recover?, :sign, :to_hp?, :to_mp?, :type,
        :type=, :variance, :variance=])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [
        :@critical, :@element_id, :@formula, :@type, :@variance])
    end

    def test_new
      obj = @@klass.new
      assert_equal(obj.critical, false)
      assert_equal(obj.element_id, 0)
      assert_equal(obj.formula, "0")
      assert_equal(obj.type, 0)
      assert_equal(obj.variance, 20)

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
    end

    def test_drain_p
      obj = @@klass.new
      assert_equal((0..6).select {|x| obj.type = x; obj.drain? }, [5, 6])
    end

    def test_none_p
      obj = @@klass.new
      assert_equal((0..6).select {|x| obj.type = x; obj.none? }, [0])
    end

    def test_recover_p
      obj = @@klass.new
      assert_equal((0..6).select {|x| obj.type = x; obj.recover? }, [3, 4])
    end

    def test_sign
      obj = @@klass.new
      assert_equal(
        (0..6).map {|x| obj.type = x; obj.sign },
        [1, 1, 1, -1, -1, 1, 1])
    end

    def test_to_hp_p
      obj = @@klass.new
      assert_equal((0..6).select {|x| obj.type = x; obj.to_hp? }, [1, 3, 5])
    end

    def test_to_mp_p
      obj = @@klass.new
      assert_equal((0..6).select {|x| obj.type = x; obj.to_mp? }, [2, 4, 6])
    end

    def test_eval_const_1
      obj = @@klass.new
      obj.formula = "135 + 256 * 3"
      obj.type = 0
      assert_equal(obj.eval(nil, nil, nil), 903)
    end

    def test_eval_const_2
      obj = @@klass.new
      obj.formula = "3 + 3"
      obj.type = 3
      assert_equal(obj.eval(nil, nil, nil), -6)
    end

    def test_eval_const_3
      obj = @@klass.new
      obj.formula = "2 - 4"
      obj.type = 5
      assert_equal(obj.eval(nil, nil, nil), 0)
    end

    def test_eval_const_4
      obj = @@klass.new
      obj.formula = "-6"
      obj.type = 4
      assert_equal(obj.eval(nil, nil, nil), 0)
    end

    def test_eval_a_1
      obj = @@klass.new
      obj.formula = "a + 2"
      obj.type = 4
      assert_equal(obj.eval(100, 200, 300), -102)
    end

    def test_eval_a_2
      obj = @@klass.new
      obj.formula = "a * 5 + 2"
      obj.type = 2
      assert_equal(obj.eval(100, 200, 300), 502)
    end

    def test_eval_b_1
      obj = @@klass.new
      obj.formula = "b - 30"
      obj.type = 1
      assert_equal(obj.eval(100, 200, 300), 170)
    end

    def test_eval_b_2
      obj = @@klass.new
      obj.formula = "b - 230"
      obj.type = 6
      assert_equal(obj.eval(100, 200, 300), 0)
    end

    def test_eval_v_1
      obj = @@klass.new
      obj.formula = "v"
      obj.type = 4
      assert_equal(obj.eval(100, 200, 300), -300)
    end

    def test_eval_rescue_1
      obj = @@klass.new
      obj.formula = "0 / 0"
      obj.type = 1
      assert_equal(obj.eval(100, 200, 300), 0)
    end

    def test_eval_rescue_2
      obj = @@klass.new
      obj.formula = "150"
      obj.type = t = Object.new
      def t.==(x)
        raise "foo"
      end
      assert_equal(obj.eval(100, 200, 300), 0)
    end

    def test_eval_self_1
      obj = @@klass.new
      obj.formula = "self == Kernel ? 277 : 0"
      obj.type = 0
      assert_equal(obj.eval(100, 200, 300), 277)
    end
  end
  end # if RGSS == 3

  if RGSS == 3
  class TestRPGUsableItemEffect < Test
    @@klass = RPG::UsableItem::Effect

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
        :code, :code=, :data_id, :data_id=, :value1, :value1=, :value2,
        :value2=])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [
        :@code, :@data_id, :@value1, :@value2])
    end

    def test_new
      obj = @@klass.new
      assert_equal(obj.code, 0)
      assert_equal(obj.data_id, 0)
      assert_equal(obj.value1, 0)
      assert_equal(obj.value2, 0)

      obj = @@klass.new(:hoge)
      assert_equal(obj.code, :hoge)
      assert_equal(obj.data_id, 0)
      assert_equal(obj.value1, 0)
      assert_equal(obj.value2, 0)

      obj = @@klass.new(:hoge, :fuga)
      assert_equal(obj.code, :hoge)
      assert_equal(obj.data_id, :fuga)
      assert_equal(obj.value1, 0)
      assert_equal(obj.value2, 0)

      obj = @@klass.new(:hoge, :fuga, :piyo)
      assert_equal(obj.code, :hoge)
      assert_equal(obj.data_id, :fuga)
      assert_equal(obj.value1, :piyo)
      assert_equal(obj.value2, 0)

      obj = @@klass.new(:hoge, :fuga, :piyo, :quux)
      assert_equal(obj.code, :hoge)
      assert_equal(obj.data_id, :fuga)
      assert_equal(obj.value1, :piyo)
      assert_equal(obj.value2, :quux)

      assert_raise(ArgumentError) {
        @@klass.new(:hoge, :fuga, :piyo, :quux, :quuux)
      }
    end
  end
  end # if RGSS == 3

  class TestRPGSkill < Test
    @@klass = RPG::Skill

    def test_superclass
      if RGSS >= 2
        assert_equal(@@klass.superclass, RPG::UsableItem)
      else
        assert_equal(@@klass.superclass, Object)
      end
    end

    def test_constants
      if RGSS == 3
        assert_symset_equal(@@klass.constants, [:Damage, :Effect, :Feature])
        assert_equal(@@klass::Damage, RPG::UsableItem::Damage)
        assert_equal(@@klass::Effect, RPG::UsableItem::Effect)
        assert_equal(@@klass::Feature, RPG::BaseItem::Feature)
      else
        assert_symset_equal(@@klass.constants, [])
      end
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
          :message1, :message1=, :message2, :message2=, :mp_cost, :mp_cost=,
          :required_wtype_id1, :required_wtype_id1=, :required_wtype_id2,
          :required_wtype_id2=, :stype_id, :stype_id=, :tp_cost, :tp_cost=])
      elsif RGSS == 2
        assert_symset_equal(owned_instance_methods(@@klass), [
          :hit, :hit=, :message1, :message1=, :message2, :message2=, :mp_cost,
          :mp_cost=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :agi_f, :agi_f=, :animation1_id, :animation1_id=, :animation2_id,
          :animation2_id=, :atk_f, :atk_f=, :common_event_id,
          :common_event_id=, :description, :description=, :dex_f, :dex_f=,
          :element_set, :element_set=, :eva_f, :eva_f=, :hit, :hit=,
          :icon_name, :icon_name=, :id, :id=, :int_f, :int_f=, :mdef_f,
          :mdef_f=, :menu_se, :menu_se=, :minus_state_set, :minus_state_set=,
          :name, :name=, :occasion, :occasion=, :pdef_f, :pdef_f=,
          :plus_state_set, :plus_state_set=, :power, :power=, :scope, :scope=,
          :sp_cost, :sp_cost=, :str_f, :str_f=, :variance, :variance=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@animation_id, :@damage, :@description, :@effects, :@features,
          :@hit_type, :@icon_index, :@id, :@message1, :@message2, :@mp_cost,
          :@name, :@note, :@occasion, :@repeats, :@required_wtype_id1,
          :@required_wtype_id2, :@scope, :@speed, :@stype_id, :@success_rate,
          :@tp_cost, :@tp_gain])
      elsif RGSS == 2
        assert_symset_equal(obj.instance_variables, [
          :@absorb_damage, :@animation_id, :@atk_f, :@base_damage,
          :@common_event_id, :@damage_to_mp, :@description, :@element_set,
          :@hit, :@icon_index, :@id, :@ignore_defense, :@message1, :@message2,
          :@minus_state_set, :@mp_cost, :@name, :@note, :@occasion,
          :@physical_attack, :@plus_state_set, :@scope, :@speed, :@spi_f,
          :@variance])
      else
        assert_symset_equal(obj.instance_variables, [
          :@agi_f, :@animation1_id, :@animation2_id, :@atk_f,
          :@common_event_id, :@description, :@dex_f, :@element_set, :@eva_f,
          :@hit, :@icon_name, :@id, :@int_f, :@mdef_f, :@menu_se,
          :@minus_state_set, :@name, :@occasion, :@pdef_f, :@plus_state_set,
          :@power, :@scope, :@sp_cost, :@str_f, :@variance])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }

      if RGSS == 3
        assert_equal(obj.animation_id, 0)
        assert_equal(obj.damage.class, RPG::UsableItem::Damage)
        assert_equal(obj.damage.critical, false)
        assert_equal(obj.damage.element_id, 0)
        assert_equal(obj.damage.formula, "0")
        assert_equal(obj.damage.type, 0)
        assert_equal(obj.damage.variance, 20)
        assert_equal(obj.description, "")
        assert_equal(obj.effects, [])
        assert_equal(obj.features, [])
        assert_equal(obj.hit_type, 0)
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.message1, "")
        assert_equal(obj.message2, "")
        assert_equal(obj.mp_cost, 0)
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.occasion, 0)
        assert_equal(obj.repeats, 1)
        assert_equal(obj.required_wtype_id1, 0)
        assert_equal(obj.required_wtype_id2, 0)
        assert_equal(obj.scope, 1)
        assert_equal(obj.speed, 0)
        assert_equal(obj.stype_id, 1)
        assert_equal(obj.success_rate, 100)
        assert_equal(obj.tp_cost, 0)
        assert_equal(obj.tp_gain, 0)
      elsif RGSS == 2
        assert_equal(obj.absorb_damage, false)
        assert_equal(obj.animation_id, 0)
        assert_equal(obj.atk_f, 0)
        assert_equal(obj.base_damage, 0)
        assert_equal(obj.common_event_id, 0)
        assert_equal(obj.damage_to_mp, false)
        assert_equal(obj.description, "")
        assert_equal(obj.element_set, [])
        assert_equal(obj.hit, 100)
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.ignore_defense, false)
        assert_equal(obj.message1, "")
        assert_equal(obj.message2, "")
        assert_equal(obj.minus_state_set, [])
        assert_equal(obj.mp_cost, 0)
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.occasion, 0)
        assert_equal(obj.physical_attack, false)
        assert_equal(obj.plus_state_set, [])
        assert_equal(obj.scope, 1)
        assert_equal(obj.speed, 0)
        assert_equal(obj.spi_f, 0)
        assert_equal(obj.variance, 20)
      else
        assert_equal(obj.agi_f, 0)
        assert_equal(obj.animation1_id, 0)
        assert_equal(obj.animation2_id, 0)
        assert_equal(obj.atk_f, 0)
        assert_equal(obj.common_event_id, 0)
        assert_equal(obj.description, "")
        assert_equal(obj.dex_f, 0)
        assert_equal(obj.element_set, [])
        assert_equal(obj.eva_f, 0)
        assert_equal(obj.hit, 100)
        assert_equal(obj.icon_name, "")
        assert_equal(obj.id, 0)
        assert_equal(obj.int_f, 100)
        assert_equal(obj.mdef_f, 100)
        assert_equal(obj.menu_se.class, RPG::AudioFile)
        assert_equal(obj.menu_se.name, "")
        assert_equal(obj.menu_se.pitch, 100)
        assert_equal(obj.menu_se.volume, 80)
        assert_equal(obj.minus_state_set, [])
        assert_equal(obj.name, "")
        assert_equal(obj.occasion, 1)
        assert_equal(obj.pdef_f, 0)
        assert_equal(obj.plus_state_set, [])
        assert_equal(obj.power, 0)
        assert_equal(obj.scope, 0)
        assert_equal(obj.sp_cost, 0)
        assert_equal(obj.str_f, 0)
        assert_equal(obj.variance, 15)
      end
    end
  end

  class TestRPGItem < Test
    @@klass = RPG::Item

    def test_superclass
      if RGSS >= 2
        assert_equal(@@klass.superclass, RPG::UsableItem)
      else
        assert_equal(@@klass.superclass, Object)
      end
    end

    def test_constants
      if RGSS == 3
        assert_symset_equal(@@klass.constants, [:Damage, :Effect, :Feature])
        assert_equal(@@klass::Damage, RPG::UsableItem::Damage)
        assert_equal(@@klass::Effect, RPG::UsableItem::Effect)
        assert_equal(@@klass::Feature, RPG::BaseItem::Feature)
      else
        assert_symset_equal(@@klass.constants, [])
      end
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
          :consumable, :consumable=, :itype_id, :itype_id=, :key_item?, :price,
          :price=])
      elsif RGSS == 2
        assert_symset_equal(owned_instance_methods(@@klass), [
          :consumable, :consumable=, :hp_recovery, :hp_recovery=,
          :hp_recovery_rate, :hp_recovery_rate=, :mp_recovery, :mp_recovery=,
          :mp_recovery_rate, :mp_recovery_rate=, :parameter_points,
          :parameter_points=, :parameter_type, :parameter_type=, :price,
          :price=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :animation1_id, :animation1_id=, :animation2_id, :animation2_id=,
          :common_event_id, :common_event_id=, :consumable, :consumable=,
          :description, :description=, :element_set, :element_set=, :hit,
          :hit=, :icon_name, :icon_name=, :id, :id=, :mdef_f, :mdef_f=,
          :menu_se, :menu_se=, :minus_state_set, :minus_state_set=, :name,
          :name=, :occasion, :occasion=, :parameter_points, :parameter_points=,
          :parameter_type, :parameter_type=, :pdef_f, :pdef_f=,
          :plus_state_set, :plus_state_set=, :price, :price=, :recover_hp,
          :recover_hp=, :recover_hp_rate, :recover_hp_rate=, :recover_sp,
          :recover_sp=, :recover_sp_rate, :recover_sp_rate=, :scope, :scope=,
          :variance, :variance=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@animation_id, :@consumable, :@damage, :@description, :@effects,
          :@features, :@hit_type, :@icon_index, :@id, :@itype_id, :@name,
          :@note, :@occasion, :@price, :@repeats, :@scope, :@speed,
          :@success_rate, :@tp_gain])
      elsif RGSS == 2
        assert_symset_equal(obj.instance_variables, [
          :@absorb_damage, :@animation_id, :@atk_f, :@base_damage,
          :@common_event_id, :@consumable, :@damage_to_mp, :@description,
          :@element_set, :@hp_recovery, :@hp_recovery_rate, :@icon_index, :@id,
          :@ignore_defense, :@minus_state_set, :@mp_recovery,
          :@mp_recovery_rate, :@name, :@note, :@occasion, :@parameter_points,
          :@parameter_type, :@physical_attack, :@plus_state_set, :@price,
          :@scope, :@speed, :@spi_f, :@variance])
      else
        assert_symset_equal(obj.instance_variables, [
          :@animation1_id, :@animation2_id, :@common_event_id, :@consumable,
          :@description, :@element_set, :@hit, :@icon_name, :@id, :@mdef_f,
          :@menu_se, :@minus_state_set, :@name, :@occasion, :@parameter_points,
          :@parameter_type, :@pdef_f, :@plus_state_set, :@price, :@recover_hp,
          :@recover_hp_rate, :@recover_sp, :@recover_sp_rate, :@scope,
          :@variance])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }

      if RGSS == 3
        assert_equal(obj.animation_id, 0)
        assert_equal(obj.consumable, true)
        assert_equal(obj.damage.class, RPG::UsableItem::Damage)
        assert_equal(obj.damage.critical, false)
        assert_equal(obj.damage.element_id, 0)
        assert_equal(obj.damage.formula, "0")
        assert_equal(obj.damage.type, 0)
        assert_equal(obj.damage.variance, 20)
        assert_equal(obj.description, "")
        assert_equal(obj.effects, [])
        assert_equal(obj.features, [])
        assert_equal(obj.hit_type, 0)
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.itype_id, 1)
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.occasion, 0)
        assert_equal(obj.price, 0)
        assert_equal(obj.repeats, 1)
        assert_equal(obj.scope, 7)
        assert_equal(obj.speed, 0)
        assert_equal(obj.success_rate, 100)
        assert_equal(obj.tp_gain, 0)
      elsif RGSS == 2
        assert_equal(obj.absorb_damage, false)
        assert_equal(obj.animation_id, 0)
        assert_equal(obj.atk_f, 0)
        assert_equal(obj.base_damage, 0)
        assert_equal(obj.common_event_id, 0)
        assert_equal(obj.consumable, true)
        assert_equal(obj.damage_to_mp, false)
        assert_equal(obj.description, "")
        assert_equal(obj.element_set, [])
        assert_equal(obj.hp_recovery, 0)
        assert_equal(obj.hp_recovery_rate, 0)
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.ignore_defense, false)
        assert_equal(obj.minus_state_set, [])
        assert_equal(obj.mp_recovery, 0)
        assert_equal(obj.mp_recovery_rate, 0)
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.occasion, 0)
        assert_equal(obj.parameter_points, 0)
        assert_equal(obj.parameter_type, 0)
        assert_equal(obj.physical_attack, false)
        assert_equal(obj.plus_state_set, [])
        assert_equal(obj.price, 0)
        assert_equal(obj.scope, 7)
        assert_equal(obj.speed, 0)
        assert_equal(obj.spi_f, 0)
        assert_equal(obj.variance, 20)
      else
        assert_equal(obj.animation1_id, 0)
        assert_equal(obj.animation2_id, 0)
        assert_equal(obj.common_event_id, 0)
        assert_equal(obj.consumable, true)
        assert_equal(obj.description, "")
        assert_equal(obj.element_set, [])
        assert_equal(obj.hit, 100)
        assert_equal(obj.icon_name, "")
        assert_equal(obj.id, 0)
        assert_equal(obj.mdef_f, 0)
        assert_equal(obj.menu_se.class, RPG::AudioFile)
        assert_equal(obj.menu_se.name, "")
        assert_equal(obj.menu_se.pitch, 100)
        assert_equal(obj.menu_se.volume, 80)
        assert_equal(obj.minus_state_set, [])
        assert_equal(obj.name, "")
        assert_equal(obj.occasion, 0)
        assert_equal(obj.parameter_points, 0)
        assert_equal(obj.parameter_type, 0)
        assert_equal(obj.pdef_f, 0)
        assert_equal(obj.plus_state_set, [])
        assert_equal(obj.price, 0)
        assert_equal(obj.recover_hp, 0)
        assert_equal(obj.recover_hp_rate, 0)
        assert_equal(obj.recover_sp, 0)
        assert_equal(obj.recover_sp_rate, 0)
        assert_equal(obj.scope, 0)
        assert_equal(obj.variance, 0)
      end
    end
  end

  if RGSS == 3
  class TestRPGEquipItem < Test
    @@klass = RPG::EquipItem

    def test_superclass
      assert_equal(@@klass.superclass, RPG::BaseItem)
    end

    def test_constants
      if RGSS == 3
        assert_symset_equal(@@klass.constants, [:Feature])
        assert_equal(@@klass::Feature, RPG::BaseItem::Feature)
      else
        assert_symset_equal(@@klass.constants, [])
      end
    end

    def test_class_variables
      assert_symset_equal(@@klass.class_variables, [])
    end

    def test_class_methods
      assert_symset_equal(@@klass.methods - Object.methods, [])
    end

    def test_instance_methods
      assert_symset_equal(owned_instance_methods(@@klass), [
        :etype_id, :etype_id=, :params, :params=, :price, :price=])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [
        :@description, :@etype_id, :@features, :@icon_index, :@id, :@name,
        :@note, :@params, :@price])
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }

      assert_equal(obj.description, "")
      assert_equal(obj.etype_id, 0)
      assert_equal(obj.features, [])
      assert_equal(obj.icon_index, 0)
      assert_equal(obj.id, 0)
      assert_equal(obj.name, "")
      assert_equal(obj.note, "")
      assert_equal(obj.params, [0, 0, 0, 0, 0, 0, 0, 0])
      assert_equal(obj.price, 0)
    end
  end
  end # if RGSS == 3

  class TestRPGWeapon < Test
    @@klass = RPG::Weapon

    def test_superclass
      if RGSS == 3
        assert_equal(@@klass.superclass, RPG::EquipItem)
      elsif RGSS == 2
        assert_equal(@@klass.superclass, RPG::BaseItem)
      else
        assert_equal(@@klass.superclass, Object)
      end
    end

    def test_constants
      if RGSS == 3
        assert_symset_equal(@@klass.constants, [:Feature])
        assert_equal(@@klass::Feature, RPG::BaseItem::Feature)
      else
        assert_symset_equal(@@klass.constants, [])
      end
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
          :animation_id, :animation_id=, :performance, :wtype_id, :wtype_id=])
      elsif RGSS == 2
        assert_symset_equal(owned_instance_methods(@@klass), [
          :agi, :agi=, :animation_id, :animation_id=, :atk, :atk=,
          :critical_bonus, :critical_bonus=, :def, :def=, :dual_attack,
          :dual_attack=, :element_set, :element_set=, :fast_attack,
          :fast_attack=, :hit, :hit=, :price, :price=, :spi, :spi=, :state_set,
          :state_set=, :two_handed, :two_handed=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :agi_plus, :agi_plus=, :animation1_id, :animation1_id=,
          :animation2_id, :animation2_id=, :atk, :atk=, :description,
          :description=, :dex_plus, :dex_plus=, :element_set, :element_set=,
          :icon_name, :icon_name=, :id, :id=, :int_plus, :int_plus=, :mdef,
          :mdef=, :minus_state_set, :minus_state_set=, :name, :name=, :pdef,
          :pdef=, :plus_state_set, :plus_state_set=, :price, :price=,
          :str_plus, :str_plus=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@animation_id, :@description, :@etype_id, :@features, :@icon_index,
          :@id, :@name, :@note, :@params, :@price, :@wtype_id])
      elsif RGSS == 2
        assert_symset_equal(obj.instance_variables, [
          :@agi, :@animation_id, :@atk, :@critical_bonus, :@def, :@description,
          :@dual_attack, :@element_set, :@fast_attack, :@hit, :@icon_index,
          :@id, :@name, :@note, :@price, :@spi, :@state_set, :@two_handed])
      else
        assert_symset_equal(obj.instance_variables, [
          :@agi_plus, :@animation1_id, :@animation2_id, :@atk, :@description,
          :@dex_plus, :@element_set, :@icon_name, :@id, :@int_plus, :@mdef,
          :@minus_state_set, :@name, :@pdef, :@plus_state_set, :@price,
          :@str_plus])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }

      if RGSS == 3
        assert_equal(obj.animation_id, 0)
        assert_equal(obj.description, "")
        assert_equal(obj.etype_id, 0)
        assert_equal(obj.features.size, 2)
        assert_equal(obj.features[0].class, RPG::BaseItem::Feature)
        assert_equal(obj.features[0].code, 31)
        assert_equal(obj.features[0].data_id, 1)
        assert_equal(obj.features[0].value, 0)
        assert_equal(obj.features[1].class, RPG::BaseItem::Feature)
        assert_equal(obj.features[1].code, 22)
        assert_equal(obj.features[1].data_id, 0)
        assert_equal(obj.features[1].value, 0)
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.params, [0, 0, 0, 0, 0, 0, 0, 0])
        assert_equal(obj.price, 0)
        assert_equal(obj.wtype_id, 0)
      elsif RGSS == 2
        assert_equal(obj.agi, 0)
        assert_equal(obj.animation_id, 0)
        assert_equal(obj.atk, 0)
        assert_equal(obj.critical_bonus, false)
        assert_equal(obj.def, 0)
        assert_equal(obj.description, "")
        assert_equal(obj.dual_attack, false)
        assert_equal(obj.element_set, [])
        assert_equal(obj.fast_attack, false)
        assert_equal(obj.hit, 95)
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.price, 0)
        assert_equal(obj.spi, 0)
        assert_equal(obj.state_set, [])
        assert_equal(obj.two_handed, false)
      else
        assert_equal(obj.agi_plus, 0)
        assert_equal(obj.animation1_id, 0)
        assert_equal(obj.animation2_id, 0)
        assert_equal(obj.atk, 0)
        assert_equal(obj.description, "")
        assert_equal(obj.dex_plus, 0)
        assert_equal(obj.element_set, [])
        assert_equal(obj.icon_name, "")
        assert_equal(obj.id, 0)
        assert_equal(obj.int_plus, 0)
        assert_equal(obj.mdef, 0)
        assert_equal(obj.minus_state_set, [])
        assert_equal(obj.name, "")
        assert_equal(obj.pdef, 0)
        assert_equal(obj.plus_state_set, [])
        assert_equal(obj.price, 0)
        assert_equal(obj.str_plus, 0)
      end
    end

    if RGSS == 3
    def test_performance_1
      obj = @@klass.new
      obj.params = [639, 384, 103, 898, 904, 945, 110, 227]
      assert_equal(obj.performance, 5217)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_performance_2
      obj = @@klass.new
      obj.params = [996, 76, 970, 365, 477, 718, 994, 721]
      assert_equal(obj.performance, 6764)
    end
    end # if RGSS == 3
  end

  class TestRPGArmor < Test
    @@klass = RPG::Armor

    def test_superclass
      if RGSS == 3
        assert_equal(@@klass.superclass, RPG::EquipItem)
      elsif RGSS == 2
        assert_equal(@@klass.superclass, RPG::BaseItem)
      else
        assert_equal(@@klass.superclass, Object)
      end
    end

    def test_constants
      if RGSS == 3
        assert_symset_equal(@@klass.constants, [:Feature])
        assert_equal(@@klass::Feature, RPG::BaseItem::Feature)
      else
        assert_symset_equal(@@klass.constants, [])
      end
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
          :atype_id, :atype_id=, :performance])
      elsif RGSS == 2
        assert_symset_equal(owned_instance_methods(@@klass), [
          :agi, :agi=, :atk, :atk=, :auto_hp_recover, :auto_hp_recover=, :def,
          :def=, :double_exp_gain, :double_exp_gain=, :element_set,
          :element_set=, :eva, :eva=, :half_mp_cost, :half_mp_cost=, :kind,
          :kind=, :prevent_critical, :prevent_critical=, :price, :price=, :spi,
          :spi=, :state_set, :state_set=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :agi_plus, :agi_plus=, :auto_state_id, :auto_state_id=, :description,
          :description=, :dex_plus, :dex_plus=, :eva, :eva=,
          :guard_element_set, :guard_element_set=, :guard_state_set,
          :guard_state_set=, :icon_name, :icon_name=, :id, :id=, :int_plus,
          :int_plus=, :kind, :kind=, :mdef, :mdef=, :name, :name=, :pdef,
          :pdef=, :price, :price=, :str_plus, :str_plus=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@atype_id, :@description, :@etype_id, :@features, :@icon_index,
          :@id, :@name, :@note, :@params, :@price])
      elsif RGSS == 2
        assert_symset_equal(obj.instance_variables, [
          :@agi, :@atk, :@auto_hp_recover, :@def, :@description,
          :@double_exp_gain, :@element_set, :@eva, :@half_mp_cost,
          :@icon_index, :@id, :@kind, :@name, :@note, :@prevent_critical,
          :@price, :@spi, :@state_set])
      else
        assert_symset_equal(obj.instance_variables, [
          :@agi_plus, :@auto_state_id, :@description, :@dex_plus, :@eva,
          :@guard_element_set, :@guard_state_set, :@icon_name, :@id,
          :@int_plus, :@kind, :@mdef, :@name, :@pdef, :@price, :@str_plus])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }

      if RGSS == 3
        assert_equal(obj.atype_id, 0)
        assert_equal(obj.description, "")
        assert_equal(obj.etype_id, 1)
        assert_equal(obj.features.size, 1)
        assert_equal(obj.features[0].class, RPG::BaseItem::Feature)
        assert_equal(obj.features[0].code, 22)
        assert_equal(obj.features[0].data_id, 1)
        assert_equal(obj.features[0].value, 0)
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.params, [0, 0, 0, 0, 0, 0, 0, 0])
        assert_equal(obj.price, 0)
      elsif RGSS == 2
        assert_equal(obj.agi, 0)
        assert_equal(obj.atk, 0)
        assert_equal(obj.auto_hp_recover, false)
        assert_equal(obj.def, 0)
        assert_equal(obj.description, "")
        assert_equal(obj.double_exp_gain, false)
        assert_equal(obj.element_set, [])
        assert_equal(obj.eva, 0)
        assert_equal(obj.half_mp_cost, false)
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.kind, 0)
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.prevent_critical, false)
        assert_equal(obj.price, 0)
        assert_equal(obj.spi, 0)
        assert_equal(obj.state_set, [])
      else
        assert_equal(obj.agi_plus, 0)
        assert_equal(obj.auto_state_id, 0)
        assert_equal(obj.description, "")
        assert_equal(obj.dex_plus, 0)
        assert_equal(obj.eva, 0)
        assert_equal(obj.guard_element_set, [])
        assert_equal(obj.guard_state_set, [])
        assert_equal(obj.icon_name, "")
        assert_equal(obj.id, 0)
        assert_equal(obj.int_plus, 0)
        assert_equal(obj.kind, 0)
        assert_equal(obj.mdef, 0)
        assert_equal(obj.name, "")
        assert_equal(obj.pdef, 0)
        assert_equal(obj.price, 0)
        assert_equal(obj.str_plus, 0)
      end
    end

    if RGSS == 3
    def test_performance_1
      obj = @@klass.new
      obj.params = [639, 384, 103, 898, 904, 945, 110, 227]
      assert_equal(obj.performance, 6053)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_performance_2
      obj = @@klass.new
      obj.params = [996, 76, 970, 365, 477, 718, 994, 721]
      assert_equal(obj.performance, 6400)
    end
    end # if RGSS == 3
  end

  class TestRPGEnemy < Test
    @@klass = RPG::Enemy

    def test_superclass
      if RGSS == 3
        assert_equal(@@klass.superclass, RPG::BaseItem)
      else
        assert_equal(@@klass.superclass, Object)
      end
    end

    def test_constants
      if RGSS == 3
        assert_symset_equal(@@klass.constants, [:Action, :DropItem, :Feature])
        assert_equal(@@klass::Feature, RPG::BaseItem::Feature)
      elsif RGSS == 2
        assert_symset_equal(@@klass.constants, [:Action, :DropItem])
      else
        assert_symset_equal(@@klass.constants, [:Action])
      end
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
          :actions, :actions=, :battler_hue, :battler_hue=, :battler_name,
          :battler_name=, :drop_items, :drop_items=, :exp, :exp=, :gold,
          :gold=, :params, :params=])
      elsif RGSS == 2
        assert_symset_equal(owned_instance_methods(@@klass), [
          :actions, :actions=, :agi, :agi=, :atk, :atk=, :battler_hue,
          :battler_hue=, :battler_name, :battler_name=, :def, :def=,
          :drop_item1, :drop_item1=, :drop_item2, :drop_item2=, :element_ranks,
          :element_ranks=, :eva, :eva=, :exp, :exp=, :gold, :gold=,
          :has_critical, :has_critical=, :hit, :hit=, :id, :id=, :levitate,
          :levitate=, :maxhp, :maxhp=, :maxmp, :maxmp=, :name, :name=, :note,
          :note=, :spi, :spi=, :state_ranks, :state_ranks=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :actions, :actions=, :agi, :agi=, :animation1_id, :animation1_id=,
          :animation2_id, :animation2_id=, :armor_id, :armor_id=, :atk, :atk=,
          :battler_hue, :battler_hue=, :battler_name, :battler_name=, :dex,
          :dex=, :element_ranks, :element_ranks=, :eva, :eva=, :exp, :exp=,
          :gold, :gold=, :id, :id=, :int, :int=, :item_id, :item_id=, :maxhp,
          :maxhp=, :maxsp, :maxsp=, :mdef, :mdef=, :name, :name=, :pdef,
          :pdef=, :state_ranks, :state_ranks=, :str, :str=, :treasure_prob,
          :treasure_prob=, :weapon_id, :weapon_id=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@actions, :@battler_hue, :@battler_name, :@description,
          :@drop_items, :@exp, :@features, :@gold, :@icon_index, :@id, :@name,
          :@note, :@params])
      elsif RGSS == 2
        assert_symset_equal(obj.instance_variables, [
          :@actions, :@agi, :@atk, :@battler_hue, :@battler_name, :@def,
          :@drop_item1, :@drop_item2, :@element_ranks, :@eva, :@exp, :@gold,
          :@has_critical, :@hit, :@id, :@levitate, :@maxhp, :@maxmp, :@name,
          :@note, :@spi, :@state_ranks])
      else
        assert_symset_equal(obj.instance_variables, [
          :@actions, :@agi, :@animation1_id, :@animation2_id, :@armor_id,
          :@atk, :@battler_hue, :@battler_name, :@dex, :@element_ranks, :@eva,
          :@exp, :@gold, :@id, :@int, :@item_id, :@maxhp, :@maxsp, :@mdef,
          :@name, :@pdef, :@state_ranks, :@str, :@treasure_prob, :@weapon_id])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }

      if RGSS == 3
        assert_equal(obj.actions.size, 1)
        assert_equal(obj.actions[0].class, RPG::Enemy::Action)
        assert_equal(obj.actions[0].condition_param1, 0)
        assert_equal(obj.actions[0].condition_param2, 0)
        assert_equal(obj.actions[0].condition_type, 0)
        assert_equal(obj.actions[0].rating, 5)
        assert_equal(obj.actions[0].skill_id, 1)
        assert_equal(obj.battler_hue, 0)
        assert_equal(obj.battler_name, "")
        assert_equal(obj.description, "")
        assert_equal(obj.drop_items.size, 3)
        assert_equal(obj.drop_items[0].class, RPG::Enemy::DropItem)
        assert_equal(obj.drop_items[0].data_id, 1)
        assert_equal(obj.drop_items[0].denominator, 1)
        assert_equal(obj.drop_items[0].kind, 0)
        assert_equal(obj.drop_items[1].class, RPG::Enemy::DropItem)
        assert_equal(obj.drop_items[1].data_id, 1)
        assert_equal(obj.drop_items[1].denominator, 1)
        assert_equal(obj.drop_items[1].kind, 0)
        assert_equal(obj.drop_items[2].class, RPG::Enemy::DropItem)
        assert_equal(obj.drop_items[2].data_id, 1)
        assert_equal(obj.drop_items[2].denominator, 1)
        assert_equal(obj.drop_items[2].kind, 0)
        assert_equal(obj.exp, 0)
        assert_equal(obj.features.size, 3)
        assert_equal(obj.features[0].class, RPG::BaseItem::Feature)
        assert_equal(obj.features[0].code, 22)
        assert_equal(obj.features[0].data_id, 0)
        assert_equal(obj.features[0].value, 0.95)
        assert_equal(obj.features[1].class, RPG::BaseItem::Feature)
        assert_equal(obj.features[1].code, 22)
        assert_equal(obj.features[1].data_id, 1)
        assert_equal(obj.features[1].value, 0.05)
        assert_equal(obj.features[2].class, RPG::BaseItem::Feature)
        assert_equal(obj.features[2].code, 31)
        assert_equal(obj.features[2].data_id, 1)
        assert_equal(obj.features[2].value, 0)
        assert_equal(obj.features[2].value.class, Fixnum)
        assert_equal(obj.gold, 0)
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.params, [100, 0, 10, 10, 10, 10, 10, 10])
      elsif RGSS == 2
        assert_equal(obj.actions.size, 1)
        assert_equal(obj.actions[0].class, RPG::Enemy::Action)
        assert_equal(obj.actions[0].basic, 0)
        assert_equal(obj.actions[0].condition_param1, 0)
        assert_equal(obj.actions[0].condition_param2, 0)
        assert_equal(obj.actions[0].condition_type, 0)
        assert_equal(obj.actions[0].kind, 0)
        assert_equal(obj.actions[0].rating, 5)
        assert_equal(obj.actions[0].skill_id, 1)
        assert_equal(obj.agi, 10)
        assert_equal(obj.atk, 10)
        assert_equal(obj.battler_hue, 0)
        assert_equal(obj.battler_name, "")
        assert_equal(obj.def, 10)
        assert_equal(obj.drop_item1.class, RPG::Enemy::DropItem)
        assert_equal(obj.drop_item1.armor_id, 1)
        assert_equal(obj.drop_item1.denominator, 1)
        assert_equal(obj.drop_item1.item_id, 1)
        assert_equal(obj.drop_item1.kind, 0)
        assert_equal(obj.drop_item1.weapon_id, 1)
        assert_equal(obj.drop_item2.class, RPG::Enemy::DropItem)
        assert_equal(obj.drop_item2.armor_id, 1)
        assert_equal(obj.drop_item2.denominator, 1)
        assert_equal(obj.drop_item2.item_id, 1)
        assert_equal(obj.drop_item2.kind, 0)
        assert_equal(obj.drop_item2.weapon_id, 1)
        assert_equal(obj.element_ranks.class, Table)
        assert_equal(obj.element_ranks._dump(0), Table.new(1)._dump(0))
        assert_equal(obj.eva, 5)
        assert_equal(obj.exp, 0)
        assert_equal(obj.gold, 0)
        assert_equal(obj.has_critical, false)
        assert_equal(obj.hit, 95)
        assert_equal(obj.id, 0)
        assert_equal(obj.levitate, false)
        assert_equal(obj.maxhp, 10)
        assert_equal(obj.maxmp, 10)
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.spi, 10)
        assert_equal(obj.state_ranks.class, Table)
        assert_equal(obj.state_ranks._dump(0), Table.new(1)._dump(0))
      else
        assert_equal(obj.actions.size, 1)
        assert_equal(obj.actions[0].class, RPG::Enemy::Action)
        assert_equal(obj.actions[0].basic, 0)
        assert_equal(obj.actions[0].condition_hp, 100)
        assert_equal(obj.actions[0].condition_level, 1)
        assert_equal(obj.actions[0].condition_switch_id, 0)
        assert_equal(obj.actions[0].condition_turn_a, 0)
        assert_equal(obj.actions[0].condition_turn_b, 1)
        assert_equal(obj.actions[0].kind, 0)
        assert_equal(obj.actions[0].rating, 5)
        assert_equal(obj.actions[0].skill_id, 1)
        assert_equal(obj.agi, 50)
        assert_equal(obj.animation1_id, 0)
        assert_equal(obj.animation2_id, 0)
        assert_equal(obj.armor_id, 0)
        assert_equal(obj.atk, 100)
        assert_equal(obj.battler_hue, 0)
        assert_equal(obj.battler_name, "")
        assert_equal(obj.dex, 50)
        assert_equal(obj.element_ranks.class, Table)
        assert_equal(obj.element_ranks._dump(0), Table.new(1)._dump(0))
        assert_equal(obj.eva, 0)
        assert_equal(obj.exp, 0)
        assert_equal(obj.gold, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.int, 50)
        assert_equal(obj.item_id, 0)
        assert_equal(obj.maxhp, 500)
        assert_equal(obj.maxsp, 500)
        assert_equal(obj.mdef, 100)
        assert_equal(obj.name, "")
        assert_equal(obj.pdef, 100)
        assert_equal(obj.state_ranks.class, Table)
        assert_equal(obj.state_ranks._dump(0), Table.new(1)._dump(0))
        assert_equal(obj.str, 50)
        assert_equal(obj.treasure_prob, 100)
        assert_equal(obj.weapon_id, 0)
      end
    end
  end

  if RGSS >= 2
  class TestRPGEnemyDropItem < Test
    @@klass = RPG::Enemy::DropItem

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
          :data_id, :data_id=, :denominator, :denominator=, :kind, :kind=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :armor_id, :armor_id=, :denominator, :denominator=, :item_id,
          :item_id=, :kind, :kind=, :weapon_id, :weapon_id=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@data_id, :@denominator, :@kind])
      else
        assert_symset_equal(obj.instance_variables, [
          :@armor_id, :@denominator, :@item_id, :@kind, :@weapon_id])
      end
    end

    def test_new
      obj = @@klass.new
      if RGSS == 3
        assert_equal(obj.data_id, 1)
        assert_equal(obj.denominator, 1)
        assert_equal(obj.kind, 0)
      else
        assert_equal(obj.item_id, 1)
        assert_equal(obj.denominator, 1)
        assert_equal(obj.kind, 0)
        assert_equal(obj.armor_id, 1)
        assert_equal(obj.weapon_id, 1)
      end

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
    end
  end
  end # if RGSS >= 2

  class TestRPGEnemyAction < Test
    @@klass = RPG::Enemy::Action

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
          :condition_param1, :condition_param1=, :condition_param2,
          :condition_param2=, :condition_type, :condition_type=, :rating,
          :rating=, :skill_id, :skill_id=])
      elsif RGSS == 2
        assert_symset_equal(owned_instance_methods(@@klass), [
          :basic, :basic=, :condition_param1, :condition_param1=,
          :condition_param2, :condition_param2=, :condition_type,
          :condition_type=, :kind, :kind=, :rating, :rating=, :skill?,
          :skill_id, :skill_id=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :basic, :basic=, :condition_hp, :condition_hp=, :condition_level,
          :condition_level=, :condition_switch_id, :condition_switch_id=,
          :condition_turn_a, :condition_turn_a=, :condition_turn_b,
          :condition_turn_b=, :kind, :kind=, :rating, :rating=, :skill_id,
          :skill_id=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@condition_param1, :@condition_param2, :@condition_type, :@rating,
          :@skill_id])
      elsif RGSS == 2
        assert_symset_equal(obj.instance_variables, [
          :@basic, :@condition_param1, :@condition_param2, :@condition_type,
          :@kind, :@rating, :@skill_id])
      else
        assert_symset_equal(obj.instance_variables, [
          :@basic, :@condition_hp, :@condition_level, :@condition_switch_id,
          :@condition_turn_a, :@condition_turn_b, :@kind, :@rating,
          :@skill_id])
      end
    end

    def test_new
      obj = @@klass.new
      if RGSS == 3
        assert_equal(obj.condition_param1, 0)
        assert_equal(obj.condition_param2, 0)
        assert_equal(obj.condition_type, 0)
        assert_equal(obj.rating, 5)
        assert_equal(obj.skill_id, 1)
      elsif RGSS == 2
        assert_equal(obj.basic, 0)
        assert_equal(obj.condition_param1, 0)
        assert_equal(obj.condition_param2, 0)
        assert_equal(obj.condition_type, 0)
        assert_equal(obj.kind, 0)
        assert_equal(obj.rating, 5)
        assert_equal(obj.skill_id, 1)
      else
        assert_equal(obj.basic, 0)
        assert_equal(obj.condition_hp, 100)
        assert_equal(obj.condition_level, 1)
        assert_equal(obj.condition_switch_id, 0)
        assert_equal(obj.condition_turn_a, 0)
        assert_equal(obj.condition_turn_b, 1)
        assert_equal(obj.kind, 0)
        assert_equal(obj.rating, 5)
        assert_equal(obj.skill_id, 1)
      end

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
    end

    if RGSS == 2
    def test_skill_p
      obj = @@klass.new
      obj.kind = 0
      assert_equal(obj.skill?, false)
      obj.kind = 1
      assert_equal(obj.skill?, true)
    end
    end # if RGSS == 2
  end

  class TestRPGState < Test
    @@klass = RPG::State

    def test_superclass
      if RGSS == 3
        assert_equal(@@klass.superclass, RPG::BaseItem)
      else
        assert_equal(@@klass.superclass, Object)
      end
    end

    def test_constants
      if RGSS == 3
        assert_symset_equal(@@klass.constants, [:Feature])
        assert_equal(@@klass::Feature, RPG::BaseItem::Feature)
      else
        assert_symset_equal(@@klass.constants, [])
      end
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
          :auto_removal_timing, :auto_removal_timing=, :chance_by_damage,
          :chance_by_damage=, :max_turns, :max_turns=, :message1, :message1=,
          :message2, :message2=, :message3, :message3=, :message4, :message4=,
          :min_turns, :min_turns=, :priority, :priority=,
          :remove_at_battle_end, :remove_at_battle_end=, :remove_by_damage,
          :remove_by_damage=, :remove_by_restriction, :remove_by_restriction=,
          :remove_by_walking, :remove_by_walking=, :restriction, :restriction=,
          :steps_to_remove, :steps_to_remove=])
      elsif RGSS == 2
        assert_symset_equal(owned_instance_methods(@@klass), [
          :agi_rate, :agi_rate=, :atk_rate, :atk_rate=, :auto_release_prob,
          :auto_release_prob=, :battle_only, :battle_only=, :def_rate,
          :def_rate=, :element_set, :element_set=, :hold_turn, :hold_turn=,
          :icon_index, :icon_index=, :id, :id=, :message1, :message1=,
          :message2, :message2=, :message3, :message3=, :message4, :message4=,
          :name, :name=, :nonresistance, :nonresistance=, :note, :note=,
          :offset_by_opposite, :offset_by_opposite=, :priority, :priority=,
          :reduce_hit_ratio, :reduce_hit_ratio=, :release_by_damage,
          :release_by_damage=, :restriction, :restriction=, :slip_damage,
          :slip_damage=, :spi_rate, :spi_rate=, :state_set, :state_set=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :agi_rate, :agi_rate=, :animation_id, :animation_id=, :atk_rate,
          :atk_rate=, :auto_release_prob, :auto_release_prob=, :battle_only,
          :battle_only=, :cant_evade, :cant_evade=, :cant_get_exp,
          :cant_get_exp=, :dex_rate, :dex_rate=, :eva, :eva=,
          :guard_element_set, :guard_element_set=, :hit_rate, :hit_rate=,
          :hold_turn, :hold_turn=, :id, :id=, :int_rate, :int_rate=,
          :maxhp_rate, :maxhp_rate=, :maxsp_rate, :maxsp_rate=, :mdef_rate,
          :mdef_rate=, :minus_state_set, :minus_state_set=, :name, :name=,
          :nonresistance, :nonresistance=, :pdef_rate, :pdef_rate=,
          :plus_state_set, :plus_state_set=, :rating, :rating=, :restriction,
          :restriction=, :shock_release_prob, :shock_release_prob=,
          :slip_damage, :slip_damage=, :str_rate, :str_rate=, :zero_hp,
          :zero_hp=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@auto_removal_timing, :@chance_by_damage, :@description, :@features,
          :@icon_index, :@id, :@max_turns, :@message1, :@message2, :@message3,
          :@message4, :@min_turns, :@name, :@note, :@priority,
          :@remove_at_battle_end, :@remove_by_damage, :@remove_by_restriction,
          :@remove_by_walking, :@restriction, :@steps_to_remove])
      elsif RGSS == 2
        assert_symset_equal(obj.instance_variables, [
          :@agi_rate, :@atk_rate, :@auto_release_prob, :@battle_only,
          :@def_rate, :@element_set, :@hold_turn, :@icon_index, :@id,
          :@message1, :@message2, :@message3, :@message4, :@name,
          :@nonresistance, :@note, :@offset_by_opposite, :@priority,
          :@reduce_hit_ratio, :@release_by_damage, :@restriction,
          :@slip_damage, :@spi_rate, :@state_set])
      else
        assert_symset_equal(obj.instance_variables, [
          :@agi_rate, :@animation_id, :@atk_rate, :@auto_release_prob,
          :@battle_only, :@cant_evade, :@cant_get_exp, :@dex_rate, :@eva,
          :@guard_element_set, :@hit_rate, :@hold_turn, :@id, :@int_rate,
          :@maxhp_rate, :@maxsp_rate, :@mdef_rate, :@minus_state_set, :@name,
          :@nonresistance, :@pdef_rate, :@plus_state_set, :@rating,
          :@restriction, :@shock_release_prob, :@slip_damage, :@str_rate,
          :@zero_hp])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }

      if RGSS == 3
        assert_equal(obj.auto_removal_timing, 0)
        assert_equal(obj.chance_by_damage, 100)
        assert_equal(obj.description, "")
        assert_equal(obj.features, [])
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.max_turns, 1)
        assert_equal(obj.message1, "")
        assert_equal(obj.message2, "")
        assert_equal(obj.message3, "")
        assert_equal(obj.message4, "")
        assert_equal(obj.min_turns, 1)
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.priority, 50)
        assert_equal(obj.remove_at_battle_end, false)
        assert_equal(obj.remove_by_damage, false)
        assert_equal(obj.remove_by_restriction, false)
        assert_equal(obj.remove_by_walking, false)
        assert_equal(obj.restriction, 0)
        assert_equal(obj.steps_to_remove, 100)
      elsif RGSS == 2
        assert_equal(obj.agi_rate, 100)
        assert_equal(obj.atk_rate, 100)
        assert_equal(obj.auto_release_prob, 0)
        assert_equal(obj.battle_only, true)
        assert_equal(obj.def_rate, 100)
        assert_equal(obj.element_set, [])
        assert_equal(obj.hold_turn, 0)
        assert_equal(obj.icon_index, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.message1, "")
        assert_equal(obj.message2, "")
        assert_equal(obj.message3, "")
        assert_equal(obj.message4, "")
        assert_equal(obj.name, "")
        assert_equal(obj.nonresistance, false)
        assert_equal(obj.note, "")
        assert_equal(obj.offset_by_opposite, false)
        assert_equal(obj.priority, 5)
        assert_equal(obj.reduce_hit_ratio, false)
        assert_equal(obj.release_by_damage, false)
        assert_equal(obj.restriction, 0)
        assert_equal(obj.slip_damage, false)
        assert_equal(obj.spi_rate, 100)
        assert_equal(obj.state_set, [])
      else
        assert_equal(obj.agi_rate, 100)
        assert_equal(obj.animation_id, 0)
        assert_equal(obj.atk_rate, 100)
        assert_equal(obj.auto_release_prob, 0)
        assert_equal(obj.battle_only, true)
        assert_equal(obj.cant_evade, false)
        assert_equal(obj.cant_get_exp, false)
        assert_equal(obj.dex_rate, 100)
        assert_equal(obj.eva, 0)
        assert_equal(obj.guard_element_set, [])
        assert_equal(obj.hit_rate, 100)
        assert_equal(obj.hold_turn, 0)
        assert_equal(obj.id, 0)
        assert_equal(obj.int_rate, 100)
        assert_equal(obj.maxhp_rate, 100)
        assert_equal(obj.maxsp_rate, 100)
        assert_equal(obj.mdef_rate, 100)
        assert_equal(obj.minus_state_set, [])
        assert_equal(obj.name, "")
        assert_equal(obj.nonresistance, false)
        assert_equal(obj.pdef_rate, 100)
        assert_equal(obj.plus_state_set, [])
        assert_equal(obj.rating, 5)
        assert_equal(obj.restriction, 0)
        assert_equal(obj.shock_release_prob, 0)
        assert_equal(obj.slip_damage, false)
        assert_equal(obj.str_rate, 100)
        assert_equal(obj.zero_hp, false)
      end
    end
  end
end
