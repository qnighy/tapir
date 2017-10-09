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

  run_test(TestRPGBaseItem) if RGSS >= 2
  run_test(TestRPGBaseItemFeature) if RGSS == 3
  run_test(TestRPGActor)
  run_test(TestRPGClass)
  run_test(TestRPGClassLearning)
end
