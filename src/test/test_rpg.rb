module RGSSTest
  class TestRPG
    include RGSSTest

    def test_rpg
      if RGSSTest::RGSS == 3
        assert_symset_equal(RPG.constants, [
          :Actor, :Animation, :Armor, :AudioFile, :BGM, :BGS, :BaseItem,
          :Class, :CommonEvent, :Enemy, :EquipItem, :Event, :EventCommand,
          :Item, :ME, :Map, :MapInfo, :MoveCommand, :MoveRoute, :SE, :Skill,
          :State, :System, :Tileset, :Troop, :UsableItem, :Weapon])
      elsif RGSSTest::RGSS == 2
        assert_symset_equal(RPG.constants, [
          :Actor, :Animation, :Area, :Armor, :AudioFile, :BGM, :BGS,
          :BaseItem, :Class, :CommonEvent, :Enemy, :Event, :EventCommand,
          :Item, :ME, :Map, :MapInfo, :MoveCommand, :MoveRoute, :SE, :Skill,
          :State, :System, :Troop, :UsableItem, :Weapon])
      else
        assert_symset_equal(RPG.constants, [
          :Actor, :Animation, :Armor, :AudioFile, :Cache, :Class, :CommonEvent,
          :Enemy, :Event, :EventCommand, :Item, :Map, :MapInfo, :MoveCommand,
          :MoveRoute, :Skill, :Sprite, :State, :System, :Tileset, :Troop,
          :Weapon, :Weather])
      end
      assert_symset_equal(RPG.class_variables, [])
      assert_symset_equal(RPG.methods - Object.methods, [])
    end

    def test_rpg_event
      obj = RPG::Event.new(7, 6)

      assert_equal(RPG::Event.superclass, Object)
      assert_symset_equal(RPG::Event.constants, [:Page])
      assert_symset_equal(RPG::Event.class_variables, [])
      assert_symset_equal(RPG::Event.methods - Object.methods, [])
      assert_symset_equal(owned_instance_methods(RPG::Event), [
        :id, :id=, :name, :name=, :pages, :pages=, :x, :x=, :y, :y=])
      assert_symset_equal(obj.instance_variables, [
        :@id, :@name, :@pages, :@x, :@y])
      assert_raise(ArgumentError) { RPG::Event.new(:hoge) }
      assert_raise(ArgumentError) { RPG::Event.new(:hoge, :fuga, :piyo) }
      assert_equal(obj.id, 0)
      assert_equal(obj.name, "")
      assert_equal(obj.pages.size, 1)
      assert_equal(obj.pages[0].class, RPG::Event::Page)
      assert_equal(obj.x, 7)
      assert_equal(obj.y, 6)
    end
  end

  run_test(TestRPG)
end
