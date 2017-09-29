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

    def test_rpg_map
      map = RPG::Map.new(13, 17)

      assert_equal(RPG::Map.superclass, Object)
      assert_symset_equal(RPG::Map.class_variables, [])
      assert_symset_equal(RPG::Map.methods - Object.methods, [])
      if RGSS == 3
        assert_symset_equal(RPG::Map.constants, [:Encounter])
        assert_symset_equal(owned_instance_methods(RPG::Map), [
          :autoplay_bgm, :autoplay_bgm=, :autoplay_bgs, :autoplay_bgs=,
          :battleback1_name, :battleback1_name=, :battleback2_name,
          :battleback2_name=, :bgm, :bgm=, :bgs, :bgs=, :data, :data=,
          :disable_dashing, :disable_dashing=, :display_name, :display_name=,
          :encounter_list, :encounter_list=, :encounter_step, :encounter_step=,
          :events, :events=, :height, :height=, :note, :note=,
          :parallax_loop_x, :parallax_loop_x=, :parallax_loop_y,
          :parallax_loop_y=, :parallax_name, :parallax_name=, :parallax_show,
          :parallax_show=, :parallax_sx, :parallax_sx=, :parallax_sy,
          :parallax_sy=, :scroll_type, :scroll_type=, :specify_battleback,
          :specify_battleback=, :tileset_id, :tileset_id=, :width, :width=])
        assert_equal(map.instance_variables.sort, [
          :@autoplay_bgm, :@autoplay_bgs, :@battleback1_name,
          :@battleback2_name, :@bgm, :@bgs, :@data, :@disable_dashing,
          :@display_name, :@encounter_list, :@encounter_step, :@events,
          :@height, :@note, :@parallax_loop_x, :@parallax_loop_y,
          :@parallax_name, :@parallax_show, :@parallax_sx, :@parallax_sy,
          :@scroll_type, :@specify_battleback, :@tileset_id, :@width])
      elsif RGSS == 2
        assert_symset_equal(RPG::Map.constants, [])
        assert_symset_equal(owned_instance_methods(RPG::Map),  [
          :autoplay_bgm, :autoplay_bgm=, :autoplay_bgs, :autoplay_bgs=, :bgm,
          :bgm=, :bgs, :bgs=, :data, :data=, :disable_dashing,
          :disable_dashing=, :encounter_list, :encounter_list=,
          :encounter_step, :encounter_step=, :events, :events=, :height,
          :height=, :parallax_loop_x, :parallax_loop_x=, :parallax_loop_y,
          :parallax_loop_y=, :parallax_name, :parallax_name=, :parallax_show,
          :parallax_show=, :parallax_sx, :parallax_sx=, :parallax_sy,
          :parallax_sy=, :scroll_type, :scroll_type=, :width, :width=])
        assert_symset_equal(map.instance_variables.sort, [
          :@autoplay_bgm, :@autoplay_bgs, :@bgm, :@bgs, :@data,
          :@disable_dashing, :@encounter_list, :@encounter_step, :@events,
          :@height, :@parallax_loop_x, :@parallax_loop_y, :@parallax_name,
          :@parallax_show, :@parallax_sx, :@parallax_sy, :@scroll_type,
          :@width])
      else
        assert_symset_equal(RPG::Map.constants, [])
        assert_symset_equal(owned_instance_methods(RPG::Map), [
          :autoplay_bgm, :autoplay_bgm=, :autoplay_bgs, :autoplay_bgs=, :bgm,
          :bgm=, :bgs, :bgs=, :data, :data=, :encounter_list, :encounter_list=,
          :encounter_step, :encounter_step=, :events, :events=, :height,
          :height=, :tileset_id, :tileset_id=, :width, :width=])
        assert_symset_equal(map.instance_variables.sort, [
          :@autoplay_bgm, :@autoplay_bgs, :@bgm, :@bgs, :@data,
          :@encounter_list, :@encounter_step, :@events, :@height, :@tileset_id,
          :@width])
      end
      assert_raise(ArgumentError) { RPG::Map.new(:hoge) }
      assert_raise(ArgumentError) { RPG::Map.new(:hoge, :fuga, :piyo) }
      assert_raise(TypeError) { RPG::Map.new(0, Object.new) }
      assert_raise(TypeError) { RPG::Map.new(Object.new, 0) }
      if RGSSTest::RGSS == 3
        assert_equal(map.autoplay_bgm, false)
        assert_equal(map.autoplay_bgs, false)
        assert_equal(map.battleback1_name, "")
        assert_equal(map.battleback2_name, "")
        assert_equal(map.bgm.class, RPG::BGM)
        assert_equal(map.bgm.name, "")
        assert_equal(map.bgm.volume, 100)
        assert_equal(map.bgm.pitch, 100)
        assert_equal(map.bgm.pos, nil)
        assert_equal(map.bgs.class, RPG::BGS)
        assert_equal(map.bgs.name, "")
        assert_equal(map.bgs.volume, 80)
        assert_equal(map.bgs.pitch, 100)
        assert_equal(map.bgs.pos, nil)
        assert_equal(map.data._dump(0), Table.new(13, 17, 4)._dump(0))
        assert_equal(map.disable_dashing, false)
        assert_equal(map.display_name, "")
        assert_equal(map.encounter_list, [])
        assert_equal(map.encounter_step, 30)
        assert_equal(map.events, {})
        assert_equal(map.height, 17)
        assert_equal(map.note, "")
        assert_equal(map.parallax_loop_x, false)
        assert_equal(map.parallax_loop_y, false)
        assert_equal(map.parallax_name, "")
        assert_equal(map.parallax_show, false)
        assert_equal(map.parallax_sx, 0)
        assert_equal(map.parallax_sy, 0)
        assert_equal(map.scroll_type, 0)
        assert_equal(map.specify_battleback, false)
        assert_equal(map.tileset_id, 1)
        assert_equal(map.width, 13)
      elsif RGSSTest::RGSS == 2
        assert_equal(map.autoplay_bgm, false)
        assert_equal(map.autoplay_bgs, false)
        assert_equal(map.bgm.class, RPG::BGM)
        assert_equal(map.bgm.name, "")
        assert_equal(map.bgm.volume, 100)
        assert_equal(map.bgm.pitch, 100)
        assert_equal(map.bgs.class, RPG::BGS)
        assert_equal(map.bgs.name, "")
        assert_equal(map.bgs.volume, 80)
        assert_equal(map.bgs.pitch, 100)
        assert_equal(map.data._dump(0), Table.new(13, 17, 3)._dump(0))
        assert_equal(map.disable_dashing, false)
        assert_equal(map.encounter_list, [])
        assert_equal(map.encounter_step, 30)
        assert_equal(map.events, {})
        assert_equal(map.height, 17)
        assert_equal(map.parallax_loop_x, false)
        assert_equal(map.parallax_loop_y, false)
        assert_equal(map.parallax_name, "")
        assert_equal(map.parallax_show, false)
        assert_equal(map.parallax_sx, 0)
        assert_equal(map.parallax_sy, 0)
        assert_equal(map.scroll_type, 0)
        assert_equal(map.width, 13)
      else
        assert_equal(map.autoplay_bgm, false)
        assert_equal(map.autoplay_bgs, false)
        assert_equal(map.bgm.class, RPG::AudioFile)
        assert_equal(map.bgm.name, "")
        assert_equal(map.bgm.volume, 100)
        assert_equal(map.bgm.pitch, 100)
        assert_equal(map.bgs.class, RPG::AudioFile)
        assert_equal(map.bgs.name, "")
        assert_equal(map.bgs.volume, 80)
        assert_equal(map.bgs.pitch, 100)
        assert_equal(map.data._dump(0), Table.new(13, 17, 3)._dump(0))
        assert_equal(map.encounter_list, [])
        assert_equal(map.encounter_step, 30)
        assert_equal(map.events, {})
        assert_equal(map.height, 17)
        assert_equal(map.tileset_id, 1)
        assert_equal(map.width, 13)
      end
    end

    def test_rpg_map_encounter
      RGSSTest::RGSS == 3 or return
      encounter = RPG::Map::Encounter.new

      assert_equal(RPG::Map::Encounter.superclass, Object)
      assert_symset_equal(RPG::Map::Encounter.constants, [])
      assert_symset_equal(RPG::Map::Encounter.class_variables, [])
      assert_symset_equal(RPG::Map::Encounter.methods - Object.methods, [])
      assert_symset_equal(owned_instance_methods(RPG::Map::Encounter), [
        :region_set, :region_set=, :troop_id, :troop_id=, :weight, :weight=])
      assert_symset_equal(encounter.instance_variables, [
        :@region_set, :@troop_id, :@weight])
      assert_raise(ArgumentError) { RPG::Map.new(:hoge) }
      assert_equal(encounter.region_set, [])
      assert_equal(encounter.troop_id, 1)
      assert_equal(encounter.weight, 10)
    end

    def test_rpg_mapinfo
      obj = RPG::MapInfo.new

      assert_equal(RPG::MapInfo.superclass, Object)
      assert_symset_equal(RPG::MapInfo.constants, [])
      assert_symset_equal(RPG::MapInfo.class_variables, [])
      assert_symset_equal(RPG::MapInfo.methods - Object.methods, [])
      assert_symset_equal(owned_instance_methods(RPG::MapInfo), [
        :expanded, :expanded=, :name, :name=, :order, :order=, :parent_id,
        :parent_id=, :scroll_x, :scroll_x=, :scroll_y, :scroll_y=])
      assert_equal(obj.instance_variables.sort.map{|s|s.to_sym}, [
        :@expanded, :@name, :@order, :@parent_id, :@scroll_x, :@scroll_y])
      assert_raise(ArgumentError) { RPG::MapInfo.new(:hoge) }
      assert_equal(obj.expanded, false)
      assert_equal(obj.name, "")
      assert_equal(obj.order, 0)
      assert_equal(obj.parent_id, 0)
      assert_equal(obj.scroll_x, 0)
      assert_equal(obj.scroll_y, 0)
    end

    def test_rpg_area
      RGSSTest::RGSS == 2 or return
      obj = RPG::Area.new

      assert_equal(RPG::Area.superclass, Object)
      assert_symset_equal(RPG::Area.constants, [])
      assert_symset_equal(RPG::Area.class_variables, [])
      assert_symset_equal(RPG::Area.methods - Object.methods, [])
      assert_symset_equal(owned_instance_methods(RPG::Area), [
        :encounter_list, :encounter_list=, :id, :id=, :map_id, :map_id=,
        :name, :name=, :order, :order=, :rect, :rect=])
      assert_symset_equal(obj.instance_variables, [
        :@encounter_list, :@id, :@map_id, :@name, :@order, :@rect])
      assert_raise(ArgumentError) { RPG::Area.new(:hoge) }
      assert_equal(obj.encounter_list, [])
      assert_equal(obj.id, 0)
      assert_equal(obj.map_id, 0)
      assert_equal(obj.name, "")
      assert_equal(obj.order, 0)
      assert_equal(obj.rect, Rect.new(0, 0, 0, 0))
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
