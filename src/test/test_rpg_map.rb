# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestRPGMap < Test
    @@klass = RPG::Map

    def test_superclass
      assert_equal(@@klass.superclass, Object)
    end

    def test_constants
      if RGSS == 3
        assert_symset_equal(@@klass.constants, [:Encounter])
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
      elsif RGSS == 2
        assert_symset_equal(owned_instance_methods(@@klass),  [
          :autoplay_bgm, :autoplay_bgm=, :autoplay_bgs, :autoplay_bgs=, :bgm,
          :bgm=, :bgs, :bgs=, :data, :data=, :disable_dashing,
          :disable_dashing=, :encounter_list, :encounter_list=,
          :encounter_step, :encounter_step=, :events, :events=, :height,
          :height=, :parallax_loop_x, :parallax_loop_x=, :parallax_loop_y,
          :parallax_loop_y=, :parallax_name, :parallax_name=, :parallax_show,
          :parallax_show=, :parallax_sx, :parallax_sx=, :parallax_sy,
          :parallax_sy=, :scroll_type, :scroll_type=, :width, :width=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :autoplay_bgm, :autoplay_bgm=, :autoplay_bgs, :autoplay_bgs=, :bgm,
          :bgm=, :bgs, :bgs=, :data, :data=, :encounter_list, :encounter_list=,
          :encounter_step, :encounter_step=, :events, :events=, :height,
          :height=, :tileset_id, :tileset_id=, :width, :width=])
      end
    end

    def test_instance_variables
      obj = @@klass.new(13, 17)
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@autoplay_bgm, :@autoplay_bgs, :@battleback1_name,
          :@battleback2_name, :@bgm, :@bgs, :@data, :@disable_dashing,
          :@display_name, :@encounter_list, :@encounter_step, :@events,
          :@height, :@note, :@parallax_loop_x, :@parallax_loop_y,
          :@parallax_name, :@parallax_show, :@parallax_sx, :@parallax_sy,
          :@scroll_type, :@specify_battleback, :@tileset_id, :@width])
      elsif RGSS == 2
        assert_symset_equal(obj.instance_variables, [
          :@autoplay_bgm, :@autoplay_bgs, :@bgm, :@bgs, :@data,
          :@disable_dashing, :@encounter_list, :@encounter_step, :@events,
          :@height, :@parallax_loop_x, :@parallax_loop_y, :@parallax_name,
          :@parallax_show, :@parallax_sx, :@parallax_sy, :@scroll_type,
          :@width])
      else
        assert_symset_equal(obj.instance_variables, [
          :@autoplay_bgm, :@autoplay_bgs, :@bgm, :@bgs, :@data,
          :@encounter_list, :@encounter_step, :@events, :@height, :@tileset_id,
          :@width])
      end
    end

    def test_new
      map = @@klass.new(13, 17)

      assert_raise(ArgumentError) { RPG::Map.new(:hoge) }
      assert_raise(ArgumentError) { RPG::Map.new(:hoge, :fuga, :piyo) }
      assert_raise(TypeError) { RPG::Map.new(0, Object.new) }
      assert_raise(TypeError) { RPG::Map.new(Object.new, 0) }

      if RGSS == 3
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
      elsif RGSS == 2
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
  end

  if RGSS == 3
  class TestRPGMapEncounter < Test
    @@klass = RPG::Map::Encounter

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
        :region_set, :region_set=, :troop_id, :troop_id=, :weight, :weight=])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [
        :@region_set, :@troop_id, :@weight])
    end


    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }

      assert_equal(obj.region_set, [])
      assert_equal(obj.troop_id, 1)
      assert_equal(obj.weight, 10)
    end
  end
  end # if RGSS == 3

  class TestRPGMapInfo < Test
    @@klass = RPG::MapInfo

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
        :expanded, :expanded=, :name, :name=, :order, :order=, :parent_id,
        :parent_id=, :scroll_x, :scroll_x=, :scroll_y, :scroll_y=])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [
        :@expanded, :@name, :@order, :@parent_id, :@scroll_x, :@scroll_y])
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }

      assert_equal(obj.expanded, false)
      assert_equal(obj.name, "")
      assert_equal(obj.order, 0)
      assert_equal(obj.parent_id, 0)
      assert_equal(obj.scroll_x, 0)
      assert_equal(obj.scroll_y, 0)
    end
  end

  if RGSS == 2
  class TestRPGArea < Test
    @@klass = RPG::Area

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
        :encounter_list, :encounter_list=, :id, :id=, :map_id, :map_id=,
        :name, :name=, :order, :order=, :rect, :rect=])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [
        :@encounter_list, :@id, :@map_id, :@name, :@order, :@rect])
    end

    def test_new
      obj = RPG::Area.new

      assert_raise(ArgumentError) { RPG::Area.new(:hoge) }

      assert_equal(obj.encounter_list, [])
      assert_equal(obj.id, 0)
      assert_equal(obj.map_id, 0)
      assert_equal(obj.name, "")
      assert_equal(obj.order, 0)
      assert_equal(obj.rect, Rect.new(0, 0, 0, 0))
    end
  end
  end # if RGSS == 2
end
