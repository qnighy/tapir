# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  if RGSS == 1 || RGSS == 3
  class TestRPGTileset < Test
    @@klass = RPG::Tileset

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
          :flags, :flags=, :id, :id=, :mode, :mode=, :name, :name=, :note,
          :note=, :tileset_names, :tileset_names=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :autotile_names, :autotile_names=, :battleback_name,
          :battleback_name=, :fog_blend_type, :fog_blend_type=, :fog_hue,
          :fog_hue=, :fog_name, :fog_name=, :fog_opacity, :fog_opacity=,
          :fog_sx, :fog_sx=, :fog_sy, :fog_sy=, :fog_zoom, :fog_zoom=, :id,
          :id=, :name, :name=, :panorama_hue, :panorama_hue=, :panorama_name,
          :panorama_name=, :passages, :passages=, :priorities, :priorities=,
          :terrain_tags, :terrain_tags=, :tileset_name, :tileset_name=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@flags, :@id, :@mode, :@name, :@note, :@tileset_names])
      else
        assert_symset_equal(obj.instance_variables, [
          :@autotile_names, :@battleback_name, :@fog_blend_type, :@fog_hue,
          :@fog_name, :@fog_opacity, :@fog_sx, :@fog_sy, :@fog_zoom, :@id,
          :@name, :@panorama_hue, :@panorama_name, :@passages, :@priorities,
          :@terrain_tags, :@tileset_name])
      end
    end


    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      if RGSS == 3
        expected_flags = Table.new(0x2000)
        expected_flags[0] = 0x10
        (0x0800...0x0B00).each {|i| expected_flags[i] = 0x0f }
        (0x1100...0x2000).each {|i| expected_flags[i] = 0x0f }
        assert_equal(obj.flags.class, Table)
        assert_equal(obj.flags._dump(0), expected_flags._dump(0))
        assert_equal(obj.id, 0)
        assert_equal(obj.mode, 1)
        assert_equal(obj.name, "")
        assert_equal(obj.note, "")
        assert_equal(obj.tileset_names, ["", "", "", "", "", "", "", "", ""])
      else
        expected_passages = Table.new(384)
        expected_priorities = Table.new(384)
        expected_priorities[0] = 5
        expected_terrain_tags = Table.new(384)
        assert_equal(obj.autotile_names, ["", "", "", "", "", "", ""])
        assert_equal(obj.battleback_name, "")
        assert_equal(obj.fog_blend_type, 0)
        assert_equal(obj.fog_hue, 0)
        assert_equal(obj.fog_name, "")
        assert_equal(obj.fog_opacity, 64)
        assert_equal(obj.fog_sx, 0)
        assert_equal(obj.fog_sy, 0)
        assert_equal(obj.fog_zoom, 200)
        assert_equal(obj.id, 0)
        assert_equal(obj.name, "")
        assert_equal(obj.panorama_hue, 0)
        assert_equal(obj.panorama_name, "")
        assert_equal(obj.passages.class, Table)
        assert_equal(obj.passages._dump(0), expected_passages._dump(0))
        assert_equal(obj.priorities.class, Table)
        assert_equal(obj.priorities._dump(0), expected_priorities._dump(0))
        assert_equal(obj.terrain_tags.class, Table)
        assert_equal(obj.terrain_tags._dump(0), expected_terrain_tags._dump(0))
        assert_equal(obj.tileset_name, "")
      end
    end
  end
  end # if RGSS == 1 || RGSS == 3
end
