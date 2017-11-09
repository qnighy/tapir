# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestRPGSystem < Test
    @@klass = RPG::System

    def test_superclass
      assert_equal(@@klass.superclass, Object)
    end

    def test_constants
      if RGSS >= 2
        assert_symset_equal(@@klass.constants, [
          :Terms, :TestBattler, :Vehicle])
      else
        assert_symset_equal(@@klass.constants, [:TestBattler, :Words])
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
          :airship, :airship=, :armor_types, :armor_types=, :battle_bgm,
          :battle_bgm=, :battle_end_me, :battle_end_me=, :battleback1_name,
          :battleback1_name=, :battleback2_name, :battleback2_name=,
          :battler_hue, :battler_hue=, :battler_name, :battler_name=, :boat,
          :boat=, :currency_unit, :currency_unit=, :edit_map_id, :edit_map_id=,
          :elements, :elements=, :game_title, :game_title=, :gameover_me,
          :gameover_me=, :japanese, :japanese=, :opt_display_tp,
          :opt_display_tp=, :opt_draw_title, :opt_draw_title=, :opt_extra_exp,
          :opt_extra_exp=, :opt_floor_death, :opt_floor_death=, :opt_followers,
          :opt_followers=, :opt_slip_death, :opt_slip_death=, :opt_transparent,
          :opt_transparent=, :opt_use_midi, :opt_use_midi=, :party_members,
          :party_members=, :ship, :ship=, :skill_types, :skill_types=, :sounds,
          :sounds=, :start_map_id, :start_map_id=, :start_x, :start_x=,
          :start_y, :start_y=, :switches, :switches=, :terms, :terms=,
          :test_battlers, :test_battlers=, :test_troop_id, :test_troop_id=,
          :title1_name, :title1_name=, :title2_name, :title2_name=, :title_bgm,
          :title_bgm=, :variables, :variables=, :version_id, :version_id=,
          :weapon_types, :weapon_types=, :window_tone, :window_tone=])
      elsif RGSS == 2
        assert_symset_equal(owned_instance_methods(@@klass), [
          :airship, :airship=, :battle_bgm, :battle_bgm=, :battle_end_me,
          :battle_end_me=, :battler_hue, :battler_hue=, :battler_name,
          :battler_name=, :boat, :boat=, :edit_map_id, :edit_map_id=,
          :elements, :elements=, :game_title, :game_title=, :gameover_me,
          :gameover_me=, :party_members, :party_members=, :passages,
          :passages=, :ship, :ship=, :sounds, :sounds=, :start_map_id,
          :start_map_id=, :start_x, :start_x=, :start_y, :start_y=, :switches,
          :switches=, :terms, :terms=, :test_battlers, :test_battlers=,
          :test_troop_id, :test_troop_id=, :title_bgm, :title_bgm=, :variables,
          :variables=, :version_id, :version_id=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :actor_collapse_se, :actor_collapse_se=, :battle_bgm, :battle_bgm=,
          :battle_end_me, :battle_end_me=, :battle_start_se, :battle_start_se=,
          :battle_transition, :battle_transition=, :battleback_name,
          :battleback_name=, :battler_hue, :battler_hue=, :battler_name,
          :battler_name=, :buzzer_se, :buzzer_se=, :cancel_se, :cancel_se=,
          :cursor_se, :cursor_se=, :decision_se, :decision_se=, :edit_map_id,
          :edit_map_id=, :elements, :elements=, :enemy_collapse_se,
          :enemy_collapse_se=, :equip_se, :equip_se=, :escape_se, :escape_se=,
          :gameover_me, :gameover_me=, :gameover_name, :gameover_name=,
          :load_se, :load_se=, :magic_number, :magic_number=, :party_members,
          :party_members=, :save_se, :save_se=, :shop_se, :shop_se=,
          :start_map_id, :start_map_id=, :start_x, :start_x=, :start_y,
          :start_y=, :switches, :switches=, :test_battlers, :test_battlers=,
          :test_troop_id, :test_troop_id=, :title_bgm, :title_bgm=,
          :title_name, :title_name=, :variables, :variables=, :windowskin_name,
          :windowskin_name=, :words, :words=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@airship, :@armor_types, :@battle_bgm, :@battle_end_me,
          :@battleback1_name, :@battleback2_name, :@battler_hue,
          :@battler_name, :@boat, :@currency_unit, :@edit_map_id, :@elements,
          :@game_title, :@gameover_me, :@japanese, :@opt_display_tp,
          :@opt_draw_title, :@opt_extra_exp, :@opt_floor_death,
          :@opt_followers, :@opt_slip_death, :@opt_transparent, :@opt_use_midi,
          :@party_members, :@ship, :@skill_types, :@sounds, :@start_map_id,
          :@start_x, :@start_y, :@switches, :@terms, :@test_battlers,
          :@test_troop_id, :@title1_name, :@title2_name, :@title_bgm,
          :@variables, :@version_id, :@weapon_types, :@window_tone])
      elsif RGSS == 2
        assert_symset_equal(obj.instance_variables, [
          :@airship, :@battle_bgm, :@battle_end_me, :@battler_hue,
          :@battler_name, :@boat, :@edit_map_id, :@elements, :@game_title,
          :@gameover_me, :@party_members, :@passages, :@ship, :@sounds,
          :@start_map_id, :@start_x, :@start_y, :@switches, :@terms,
          :@test_battlers, :@test_troop_id, :@title_bgm, :@variables,
          :@version_id])
      else
        assert_symset_equal(obj.instance_variables, [
          :@actor_collapse_se, :@battle_bgm, :@battle_end_me,
          :@battle_start_se, :@battle_transition, :@battleback_name,
          :@battler_hue, :@battler_name, :@buzzer_se, :@cancel_se, :@cursor_se,
          :@decision_se, :@edit_map_id, :@elements, :@enemy_collapse_se,
          :@equip_se, :@escape_se, :@gameover_me, :@gameover_name, :@load_se,
          :@magic_number, :@party_members, :@save_se, :@shop_se,
          :@start_map_id, :@start_x, :@start_y, :@switches, :@test_battlers,
          :@test_troop_id, :@title_bgm, :@title_name, :@variables,
          :@windowskin_name, :@words])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      if RGSS == 3
        assert_equal(obj.airship.class, RPG::System::Vehicle)
        assert_equal(obj.airship.bgm.class, RPG::BGM)
        assert_equal(obj.airship.bgm.name, "")
        assert_equal(obj.airship.bgm.pitch, 100)
        assert_equal(obj.airship.bgm.volume, 100)
        assert_equal(obj.airship.character_index, 0)
        assert_equal(obj.airship.character_name, "")
        assert_equal(obj.airship.start_map_id, 0)
        assert_equal(obj.airship.start_x, 0)
        assert_equal(obj.airship.start_y, 0)
        assert_equal(obj.armor_types, [nil, ""])
        assert_equal(obj.battle_bgm.class, RPG::BGM)
        assert_equal(obj.battle_bgm.name, "")
        assert_equal(obj.battle_bgm.pitch, 100)
        assert_equal(obj.battle_bgm.volume, 100)
        assert_equal(obj.battle_end_me.class, RPG::ME)
        assert_equal(obj.battle_end_me.name, "")
        assert_equal(obj.battle_end_me.pitch, 100)
        assert_equal(obj.battle_end_me.volume, 100)
        assert_equal(obj.battleback1_name, "")
        assert_equal(obj.battleback2_name, "")
        assert_equal(obj.battler_hue, 0)
        assert_equal(obj.battler_name, "")
        assert_equal(obj.boat.class, RPG::System::Vehicle)
        assert_equal(obj.boat.bgm.class, RPG::BGM)
        assert_equal(obj.boat.bgm.name, "")
        assert_equal(obj.boat.bgm.pitch, 100)
        assert_equal(obj.boat.bgm.volume, 100)
        assert_equal(obj.boat.character_index, 0)
        assert_equal(obj.boat.character_name, "")
        assert_equal(obj.boat.start_map_id, 0)
        assert_equal(obj.boat.start_x, 0)
        assert_equal(obj.boat.start_y, 0)
        assert_equal(obj.currency_unit, "")
        assert_equal(obj.edit_map_id, 1)
        assert_equal(obj.elements, [nil, ""])
        assert_equal(obj.game_title, "")
        assert_equal(obj.gameover_me.class, RPG::ME)
        assert_equal(obj.gameover_me.name, "")
        assert_equal(obj.gameover_me.pitch, 100)
        assert_equal(obj.gameover_me.volume, 100)
        assert_equal(obj.japanese, true)
        assert_equal(obj.opt_display_tp, true)
        assert_equal(obj.opt_draw_title, true)
        assert_equal(obj.opt_extra_exp, false)
        assert_equal(obj.opt_floor_death, false)
        assert_equal(obj.opt_followers, true)
        assert_equal(obj.opt_slip_death, false)
        assert_equal(obj.opt_transparent, false)
        assert_equal(obj.opt_use_midi, false)
        assert_equal(obj.party_members, [1])
        assert_equal(obj.ship.class, RPG::System::Vehicle)
        assert_equal(obj.ship.bgm.class, RPG::BGM)
        assert_equal(obj.ship.bgm.name, "")
        assert_equal(obj.ship.bgm.pitch, 100)
        assert_equal(obj.ship.bgm.volume, 100)
        assert_equal(obj.ship.character_index, 0)
        assert_equal(obj.ship.character_name, "")
        assert_equal(obj.ship.start_map_id, 0)
        assert_equal(obj.ship.start_x, 0)
        assert_equal(obj.ship.start_y, 0)
        assert_equal(obj.skill_types, [nil, ""])
        assert_equal(obj.sounds.size, 24)
        24.times do|i|
          assert_equal(obj.sounds[i].class, RPG::SE)
          assert_equal(obj.sounds[i].name, "")
          assert_equal(obj.sounds[i].volume, 100)
          assert_equal(obj.sounds[i].pitch, 100)
        end
        assert_equal(obj.start_map_id, 1)
        assert_equal(obj.start_x, 0)
        assert_equal(obj.start_y, 0)
        assert_equal(obj.switches, [nil, ""])
        assert_equal(obj.terms.class, RPG::System::Terms)
        assert_equal(obj.terms.basic, ["", "", "", "", "", "", "", ""])
        assert_equal(obj.terms.commands, ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""])
        assert_equal(obj.terms.etypes, ["", "", "", "", ""])
        assert_equal(obj.terms.params, ["", "", "", "", "", "", "", ""])
        assert_equal(obj.test_battlers, [])
        assert_equal(obj.test_troop_id, 1)
        assert_equal(obj.title1_name, "")
        assert_equal(obj.title2_name, "")
        assert_equal(obj.title_bgm.class, RPG::BGM)
        assert_equal(obj.title_bgm.name, "")
        assert_equal(obj.title_bgm.pitch, 100)
        assert_equal(obj.title_bgm.volume, 100)
        assert_equal(obj.variables, [nil, ""])
        assert_equal(obj.version_id, 0)
        assert_equal(obj.weapon_types, [nil, ""])
        assert_equal(obj.window_tone, Tone.new(0, 0, 0, 0))
      elsif RGSS == 2
        assert_equal(obj.airship.class, RPG::System::Vehicle)
        assert_equal(obj.airship.bgm.class, RPG::BGM)
        assert_equal(obj.airship.bgm.name, "")
        assert_equal(obj.airship.bgm.pitch, 100)
        assert_equal(obj.airship.bgm.volume, 100)
        assert_equal(obj.airship.character_index, 0)
        assert_equal(obj.airship.character_name, "")
        assert_equal(obj.airship.start_map_id, 0)
        assert_equal(obj.airship.start_x, 0)
        assert_equal(obj.airship.start_y, 0)
        assert_equal(obj.battle_bgm.class, RPG::BGM)
        assert_equal(obj.battle_bgm.name, "")
        assert_equal(obj.battle_bgm.pitch, 100)
        assert_equal(obj.battle_bgm.volume, 100)
        assert_equal(obj.battle_end_me.class, RPG::ME)
        assert_equal(obj.battle_end_me.name, "")
        assert_equal(obj.battle_end_me.pitch, 100)
        assert_equal(obj.battle_end_me.volume, 100)
        assert_equal(obj.battler_hue, 0)
        assert_equal(obj.battler_name, "")
        assert_equal(obj.boat.class, RPG::System::Vehicle)
        assert_equal(obj.boat.bgm.class, RPG::BGM)
        assert_equal(obj.boat.bgm.name, "")
        assert_equal(obj.boat.bgm.pitch, 100)
        assert_equal(obj.boat.bgm.volume, 100)
        assert_equal(obj.boat.character_index, 0)
        assert_equal(obj.boat.character_name, "")
        assert_equal(obj.boat.start_map_id, 0)
        assert_equal(obj.boat.start_x, 0)
        assert_equal(obj.boat.start_y, 0)
        assert_equal(obj.edit_map_id, 1)
        assert_equal(obj.elements, [nil, ""])
        assert_equal(obj.game_title, "")
        assert_equal(obj.gameover_me.class, RPG::ME)
        assert_equal(obj.gameover_me.name, "")
        assert_equal(obj.gameover_me.pitch, 100)
        assert_equal(obj.gameover_me.volume, 100)
        assert_equal(obj.party_members, [1])
        assert_equal(obj.passages.class, Table)
        assert_equal(obj.passages._dump(0), Table.new(8192)._dump(0))
        assert_equal(obj.ship.class, RPG::System::Vehicle)
        assert_equal(obj.ship.bgm.class, RPG::BGM)
        assert_equal(obj.ship.bgm.name, "")
        assert_equal(obj.ship.bgm.pitch, 100)
        assert_equal(obj.ship.bgm.volume, 100)
        assert_equal(obj.ship.character_index, 0)
        assert_equal(obj.ship.character_name, "")
        assert_equal(obj.ship.start_map_id, 0)
        assert_equal(obj.ship.start_x, 0)
        assert_equal(obj.ship.start_y, 0)
        assert_equal(obj.sounds.size, 20)
        20.times do|i|
          assert_equal(obj.sounds[i].class, RPG::SE)
          assert_equal(obj.sounds[i].name, "")
          assert_equal(obj.sounds[i].volume, 100)
          assert_equal(obj.sounds[i].pitch, 100)
        end
        assert_equal(obj.start_map_id, 1)
        assert_equal(obj.start_x, 0)
        assert_equal(obj.start_y, 0)
        assert_equal(obj.switches, [nil, ""])
        assert_equal(obj.terms.class, RPG::System::Terms)
        assert_equal(obj.terms.agi, "")
        assert_equal(obj.terms.armor1, "")
        assert_equal(obj.terms.armor2, "")
        assert_equal(obj.terms.armor3, "")
        assert_equal(obj.terms.armor4, "")
        assert_equal(obj.terms.atk, "")
        assert_equal(obj.terms.attack, "")
        assert_equal(obj.terms.cancel, "")
        assert_equal(obj.terms.continue, "")
        assert_equal(obj.terms.def, "")
        assert_equal(obj.terms.equip, "")
        assert_equal(obj.terms.escape, "")
        assert_equal(obj.terms.fight, "")
        assert_equal(obj.terms.game_end, "")
        assert_equal(obj.terms.gold, "")
        assert_equal(obj.terms.guard, "")
        assert_equal(obj.terms.hp, "")
        assert_equal(obj.terms.hp_a, "")
        assert_equal(obj.terms.item, "")
        assert_equal(obj.terms.level, "")
        assert_equal(obj.terms.level_a, "")
        assert_equal(obj.terms.mp, "")
        assert_equal(obj.terms.mp_a, "")
        assert_equal(obj.terms.new_game, "")
        assert_equal(obj.terms.save, "")
        assert_equal(obj.terms.shutdown, "")
        assert_equal(obj.terms.skill, "")
        assert_equal(obj.terms.spi, "")
        assert_equal(obj.terms.status, "")
        assert_equal(obj.terms.to_title, "")
        assert_equal(obj.terms.weapon1, "")
        assert_equal(obj.terms.weapon2, "")
        assert_equal(obj.terms.weapon, "")
        assert_equal(obj.test_battlers, [])
        assert_equal(obj.test_troop_id, 1)
        assert_equal(obj.title_bgm.class, RPG::BGM)
        assert_equal(obj.title_bgm.name, "")
        assert_equal(obj.title_bgm.pitch, 100)
        assert_equal(obj.title_bgm.volume, 100)
        assert_equal(obj.variables, [nil, ""])
        assert_equal(obj.version_id, 0)
      else
        assert_equal(obj.actor_collapse_se.class, RPG::AudioFile)
        assert_equal(obj.actor_collapse_se.name, "")
        assert_equal(obj.actor_collapse_se.volume, 80)
        assert_equal(obj.actor_collapse_se.pitch, 100)
        assert_equal(obj.battle_bgm.class, RPG::AudioFile)
        assert_equal(obj.battle_bgm.name, "")
        assert_equal(obj.battle_bgm.volume, 100)
        assert_equal(obj.battle_bgm.pitch, 100)
        assert_equal(obj.battle_end_me.class, RPG::AudioFile)
        assert_equal(obj.battle_end_me.name, "")
        assert_equal(obj.battle_end_me.volume, 100)
        assert_equal(obj.battle_end_me.pitch, 100)
        assert_equal(obj.battle_start_se.class, RPG::AudioFile)
        assert_equal(obj.battle_start_se.name, "")
        assert_equal(obj.battle_start_se.volume, 80)
        assert_equal(obj.battle_start_se.pitch, 100)
        assert_equal(obj.battle_transition, "")
        assert_equal(obj.battleback_name, "")
        assert_equal(obj.battler_hue, 0)
        assert_equal(obj.battler_name, "")
        assert_equal(obj.buzzer_se.class, RPG::AudioFile)
        assert_equal(obj.buzzer_se.name, "")
        assert_equal(obj.buzzer_se.volume, 80)
        assert_equal(obj.buzzer_se.pitch, 100)
        assert_equal(obj.cancel_se.class, RPG::AudioFile)
        assert_equal(obj.cancel_se.name, "")
        assert_equal(obj.cancel_se.volume, 80)
        assert_equal(obj.cancel_se.pitch, 100)
        assert_equal(obj.cursor_se.class, RPG::AudioFile)
        assert_equal(obj.cursor_se.name, "")
        assert_equal(obj.cursor_se.volume, 80)
        assert_equal(obj.cursor_se.pitch, 100)
        assert_equal(obj.decision_se.class, RPG::AudioFile)
        assert_equal(obj.decision_se.name, "")
        assert_equal(obj.decision_se.volume, 80)
        assert_equal(obj.decision_se.pitch, 100)
        assert_equal(obj.edit_map_id, 1)
        assert_equal(obj.elements, [nil, ""])
        assert_equal(obj.enemy_collapse_se.class, RPG::AudioFile)
        assert_equal(obj.enemy_collapse_se.name, "")
        assert_equal(obj.enemy_collapse_se.volume, 80)
        assert_equal(obj.enemy_collapse_se.pitch, 100)
        assert_equal(obj.equip_se.class, RPG::AudioFile)
        assert_equal(obj.equip_se.name, "")
        assert_equal(obj.equip_se.volume, 80)
        assert_equal(obj.equip_se.pitch, 100)
        assert_equal(obj.escape_se.class, RPG::AudioFile)
        assert_equal(obj.escape_se.name, "")
        assert_equal(obj.escape_se.volume, 80)
        assert_equal(obj.escape_se.pitch, 100)
        assert_equal(obj.gameover_me.class, RPG::AudioFile)
        assert_equal(obj.gameover_me.name, "")
        assert_equal(obj.gameover_me.volume, 100)
        assert_equal(obj.gameover_me.pitch, 100)
        assert_equal(obj.gameover_name, "")
        assert_equal(obj.load_se.class, RPG::AudioFile)
        assert_equal(obj.load_se.name, "")
        assert_equal(obj.load_se.volume, 80)
        assert_equal(obj.load_se.pitch, 100)
        assert_equal(obj.magic_number, 0)
        assert_equal(obj.party_members, [1])
        assert_equal(obj.save_se.class, RPG::AudioFile)
        assert_equal(obj.save_se.name, "")
        assert_equal(obj.save_se.volume, 80)
        assert_equal(obj.save_se.pitch, 100)
        assert_equal(obj.shop_se.class, RPG::AudioFile)
        assert_equal(obj.shop_se.name, "")
        assert_equal(obj.shop_se.volume, 80)
        assert_equal(obj.shop_se.pitch, 100)
        assert_equal(obj.start_map_id, 1)
        assert_equal(obj.start_x, 0)
        assert_equal(obj.start_y, 0)
        assert_equal(obj.switches, [nil, ""])
        assert_equal(obj.test_battlers, [])
        assert_equal(obj.test_troop_id, 1)
        assert_equal(obj.title_bgm.class, RPG::AudioFile)
        assert_equal(obj.title_bgm.name, "")
        assert_equal(obj.title_bgm.volume, 100)
        assert_equal(obj.title_bgm.pitch, 100)
        assert_equal(obj.title_name, "")
        assert_equal(obj.variables, [nil, ""])
        assert_equal(obj.windowskin_name, "")
        assert_equal(obj.words.class, RPG::System::Words)
        assert_equal(obj.words.agi, "")
        assert_equal(obj.words.armor1, "")
        assert_equal(obj.words.armor2, "")
        assert_equal(obj.words.armor3, "")
        assert_equal(obj.words.armor4, "")
        assert_equal(obj.words.atk, "")
        assert_equal(obj.words.attack, "")
        assert_equal(obj.words.dex, "")
        assert_equal(obj.words.equip, "")
        assert_equal(obj.words.gold, "")
        assert_equal(obj.words.guard, "")
        assert_equal(obj.words.hp, "")
        assert_equal(obj.words.int, "")
        assert_equal(obj.words.item, "")
        assert_equal(obj.words.mdef, "")
        assert_equal(obj.words.pdef, "")
        assert_equal(obj.words.skill, "")
        assert_equal(obj.words.sp, "")
        assert_equal(obj.words.str, "")
        assert_equal(obj.words.weapon, "")
      end
    end
  end

  if RGSS >= 2
  class TestRPGSystemVehicle < Test
    @@klass = RPG::System::Vehicle

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
        :bgm, :bgm=, :character_index, :character_index=, :character_name,
        :character_name=, :start_map_id, :start_map_id=, :start_x, :start_x=,
        :start_y, :start_y=])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [
        :@bgm, :@character_index, :@character_name, :@start_map_id, :@start_x,
        :@start_y])
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      assert_equal(obj.bgm.class, RPG::BGM)
      assert_equal(obj.bgm.name, "")
      assert_equal(obj.bgm.pitch, 100)
      assert_equal(obj.bgm.volume, 100)
      assert_equal(obj.character_index, 0)
      assert_equal(obj.character_name, "")
      assert_equal(obj.start_map_id, 0)
      assert_equal(obj.start_x, 0)
      assert_equal(obj.start_y, 0)
    end
  end
  end # if RGSS >= 2

  class TestRPGSystemTerms < Test
    if RGSS >= 2
      @@klass = RPG::System::Terms
    else
      @@klass = RPG::System::Words
    end

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
          :basic, :basic=, :commands, :commands=, :etypes, :etypes=, :params,
          :params=])
      elsif RGSS == 2
        assert_symset_equal(owned_instance_methods(@@klass), [
          :agi, :agi=, :armor1, :armor1=, :armor2, :armor2=, :armor3, :armor3=,
          :armor4, :armor4=, :atk, :atk=, :attack, :attack=, :cancel, :cancel=,
          :continue, :continue=, :def, :def=, :equip, :equip=, :escape,
          :escape=, :fight, :fight=, :game_end, :game_end=, :gold, :gold=,
          :guard, :guard=, :hp, :hp=, :hp_a, :hp_a=, :item, :item=, :level,
          :level=, :level_a, :level_a=, :mp, :mp=, :mp_a, :mp_a=, :new_game,
          :new_game=, :save, :save=, :shutdown, :shutdown=, :skill, :skill=,
          :spi, :spi=, :status, :status=, :to_title, :to_title=, :weapon,
          :weapon1, :weapon1=, :weapon2, :weapon2=, :weapon=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :agi, :agi=, :armor1, :armor1=, :armor2, :armor2=, :armor3, :armor3=,
          :armor4, :armor4=, :atk, :atk=, :attack, :attack=, :dex, :dex=,
          :equip, :equip=, :gold, :gold=, :guard, :guard=, :hp, :hp=, :int,
          :int=, :item, :item=, :mdef, :mdef=, :pdef, :pdef=, :skill, :skill=,
          :sp, :sp=, :str, :str=, :weapon, :weapon=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@basic, :@commands, :@etypes, :@params])
      elsif RGSS == 2
        assert_symset_equal(obj.instance_variables, [
          :@agi, :@armor1, :@armor2, :@armor3, :@armor4, :@atk, :@attack,
          :@cancel, :@continue, :@def, :@equip, :@escape, :@fight, :@game_end,
          :@gold, :@guard, :@hp, :@hp_a, :@item, :@level, :@level_a, :@mp,
          :@mp_a, :@new_game, :@save, :@shutdown, :@skill, :@spi, :@status,
          :@to_title, :@weapon, :@weapon1, :@weapon2])
      else
        assert_symset_equal(obj.instance_variables, [
          :@agi, :@armor1, :@armor2, :@armor3, :@armor4, :@atk, :@attack,
          :@dex, :@equip, :@gold, :@guard, :@hp, :@int, :@item, :@mdef, :@pdef,
          :@skill, :@sp, :@str, :@weapon])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      if RGSS == 3
        assert_equal(obj.basic, ["", "", "", "", "", "", "", ""])
        assert_equal(obj.commands, ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""])
        assert_equal(obj.etypes, ["", "", "", "", ""])
        assert_equal(obj.params, ["", "", "", "", "", "", "", ""])
      elsif RGSS == 2
        assert_equal(obj.agi, "")
        assert_equal(obj.armor1, "")
        assert_equal(obj.armor2, "")
        assert_equal(obj.armor3, "")
        assert_equal(obj.armor4, "")
        assert_equal(obj.atk, "")
        assert_equal(obj.attack, "")
        assert_equal(obj.cancel, "")
        assert_equal(obj.continue, "")
        assert_equal(obj.def, "")
        assert_equal(obj.equip, "")
        assert_equal(obj.escape, "")
        assert_equal(obj.fight, "")
        assert_equal(obj.game_end, "")
        assert_equal(obj.gold, "")
        assert_equal(obj.guard, "")
        assert_equal(obj.hp, "")
        assert_equal(obj.hp_a, "")
        assert_equal(obj.item, "")
        assert_equal(obj.level, "")
        assert_equal(obj.level_a, "")
        assert_equal(obj.mp, "")
        assert_equal(obj.mp_a, "")
        assert_equal(obj.new_game, "")
        assert_equal(obj.save, "")
        assert_equal(obj.shutdown, "")
        assert_equal(obj.skill, "")
        assert_equal(obj.spi, "")
        assert_equal(obj.status, "")
        assert_equal(obj.to_title, "")
        assert_equal(obj.weapon1, "")
        assert_equal(obj.weapon2, "")
        assert_equal(obj.weapon, "")
      else
        assert_equal(obj.agi, "")
        assert_equal(obj.armor1, "")
        assert_equal(obj.armor2, "")
        assert_equal(obj.armor3, "")
        assert_equal(obj.armor4, "")
        assert_equal(obj.atk, "")
        assert_equal(obj.attack, "")
        assert_equal(obj.dex, "")
        assert_equal(obj.equip, "")
        assert_equal(obj.gold, "")
        assert_equal(obj.guard, "")
        assert_equal(obj.hp, "")
        assert_equal(obj.int, "")
        assert_equal(obj.item, "")
        assert_equal(obj.mdef, "")
        assert_equal(obj.pdef, "")
        assert_equal(obj.skill, "")
        assert_equal(obj.sp, "")
        assert_equal(obj.str, "")
        assert_equal(obj.weapon, "")
      end
    end
  end

  class TestRPGSystemTestBattler < Test
    @@klass = RPG::System::TestBattler

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
          :actor_id, :actor_id=, :equips, :equips=, :level, :level=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :actor_id, :actor_id=, :armor1_id, :armor1_id=, :armor2_id,
          :armor2_id=, :armor3_id, :armor3_id=, :armor4_id, :armor4_id=,
          :level, :level=, :weapon_id, :weapon_id=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      if RGSS == 3
        assert_symset_equal(obj.instance_variables, [
          :@actor_id, :@equips, :@level])
      else
        assert_symset_equal(obj.instance_variables, [
          :@actor_id, :@armor1_id, :@armor2_id, :@armor3_id, :@armor4_id,
          :@level, :@weapon_id])
      end
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      if RGSS == 3
        assert_equal(obj.actor_id, 1)
        assert_equal(obj.equips, [0, 0, 0, 0, 0])
        assert_equal(obj.level, 1)
      else
        assert_equal(obj.actor_id, 1)
        assert_equal(obj.armor1_id, 0)
        assert_equal(obj.armor2_id, 0)
        assert_equal(obj.armor3_id, 0)
        assert_equal(obj.armor4_id, 0)
        assert_equal(obj.level, 1)
        assert_equal(obj.weapon_id, 0)
      end
    end
  end
end
