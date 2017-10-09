module RGSSTest
  class TestRPGBaseItem
    include RGSSTest

    @@klass = RPG::BaseItem if RGSS >= 2

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

  class TestRPGBaseItemFeature
    include RGSSTest

    @@klass = RPG::BaseItem::Feature if RGSS == 3

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

  class TestRPGActor
    include RGSSTest

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

  class TestRPGClass
    include RGSSTest

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

    def test_exp_for_level_1
      RGSS == 3 or return
      obj = @@klass.new
      obj.exp_params = [0, 0, 25, 1.0/0.0]
      assert_equal(obj.exp_for_level(2), 0)
      assert_equal(obj.exp_for_level(50), 0)
      assert_equal(obj.exp_for_level(99), 0)
    end

    def test_exp_for_level_2
      RGSS == 3 or return
      obj = @@klass.new
      obj.exp_params = [0, 1, 25, 1.0/0.0]
      assert_equal(obj.exp_for_level(2), 1)
      assert_equal(obj.exp_for_level(50), 49)
      assert_equal(obj.exp_for_level(99), 98)
    end

    def test_exp_for_level_3
      RGSS == 3 or return
      obj = @@klass.new
      obj.exp_params = [0, 10, 25, 1.0/0.0]
      assert_equal(obj.exp_for_level(2), 10)
      assert_equal(obj.exp_for_level(50), 490)
      assert_equal(obj.exp_for_level(99), 980)
    end

    def test_exp_for_level_4
      RGSS == 3 or return
      obj = @@klass.new
      obj.exp_params = [0, 0.999, 25, 1.0/0.0]
      assert_equal(obj.exp_for_level(2), 1)
      assert_equal(obj.exp_for_level(50), 49)
      assert_equal(obj.exp_for_level(99), 98)
    end

    def test_exp_for_level_5
      RGSS == 3 or return
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

    def test_exp_for_level_6
      RGSS == 3 or return
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

    def test_exp_for_level_7
      RGSS == 3 or return
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

    def test_exp_for_level_8
      RGSS == 3 or return
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

    def test_exp_for_level_9
      RGSS == 3 or return
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

    def test_exp_for_level_10
      RGSS == 3 or return
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

    def test_exp_for_level_11
      RGSS == 3 or return
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

    def test_exp_for_level_12
      RGSS == 3 or return
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

    def test_exp_for_level_13
      RGSS == 3 or return
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

    def test_exp_for_level_14
      RGSS == 3 or return
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

    def test_exp_for_level_15
      RGSS == 3 or return
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
  end

  class TestRPGClassLearning
    include RGSSTest

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

  class TestRPGUsableItem
    include RGSSTest

    @@klass = RPG::UsableItem if RGSS >= 2

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

    def test_certain_p
      RGSS == 3 or return
      obj = @@klass.new
      assert_equal((0..2).select {|x| obj.hit_type = x; obj.certain? }, [0])
    end

    def test_dual_p
      RGSS == 2 or return
      obj = @@klass.new
      assert_equal((0..11).select {|x| obj.scope = x; obj.dual? }, [3])
    end

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

    def test_for_three_p
      RGSS == 2 or return
      obj = @@klass.new
      assert_equal((0..11).select {|x| obj.scope = x; obj.for_three? }, [6])
    end

    def test_for_two_p
      RGSS == 2 or return
      obj = @@klass.new
      assert_equal((0..11).select {|x| obj.scope = x; obj.for_two? }, [5])
    end

    def test_for_user_p
      obj = @@klass.new
      assert_equal((0..11).select {|x| obj.scope = x; obj.for_user? }, [11])
    end

    def test_magical_p
      RGSS == 3 or return
      obj = @@klass.new
      assert_equal((0..2).select {|x| obj.hit_type = x; obj.magical? }, [2])
    end

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

    def test_number_of_targets
      RGSS == 3 or return
      obj = @@klass.new
      assert_equal(
        (0..11).map {|x| obj.scope = x; obj.number_of_targets },
        [0, 0, 0, 1, 2, 3, 4, 0, 0, 0, 0, 0])
    end

    def test_physical_p
      RGSS == 3 or return
      obj = @@klass.new
      assert_equal((0..2).select {|x| obj.hit_type = x; obj.physical? }, [1])
    end
  end

  class TestRPGUsableItemDamage
    include RGSSTest

    @@klass = RPG::UsableItem::Damage if RGSS == 3

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

  class TestRPGUsableItemEffect
    include RGSSTest

    @@klass = RPG::UsableItem::Effect if RGSS == 3

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

  run_test(TestRPGBaseItem) if RGSS >= 2
  run_test(TestRPGBaseItemFeature) if RGSS == 3
  run_test(TestRPGActor)
  run_test(TestRPGClass)
  run_test(TestRPGClassLearning)
  run_test(TestRPGUsableItem) if RGSS >= 2
  run_test(TestRPGUsableItemDamage) if RGSS == 3
  run_test(TestRPGUsableItemEffect) if RGSS == 3
end
