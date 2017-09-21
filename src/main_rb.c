#include <ruby.h>
#include "main_rb.h"

#if RGSS == 3
#define RGSS_RESET "RGSSReset"
#define TERMS "Terms"
#define SCRIPT_PATH "\"Data/Scripts.rvdata2\""
#elif RGSS == 2
#define RGSS_RESET "Reset"
#define TERMS "Terms"
#define SCRIPT_PATH "\"Data/Scripts.rvdata\""
#else
#define RGSS_RESET "Reset"
#define TERMS "Words"
#define SCRIPT_PATH "\"Data/Scripts.rxdata\""
#endif

VALUE main_rb(VALUE data) {
  (void) data;
  rb_eval_string(
#if RGSS < 3
      "$KCODE = \"u\"\n"
#endif
      "$unimplemented_warnings = {}\n"
      /* TODO: this is only for developing purpose. */
      /* We want to remove it when it becomes unnecessary. */
      "def warn_unimplemented(name)\n"
      "  if !$unimplemented_warnings[name]\n"
      "    $unimplemented_warnings[name] = true\n"
      "    $stderr.puts \"unimplemented: #{name}\"\n"
      "  end\n"
      "end\n"
      "class Module\n"
      "  def attr_unimplemented(*names)\n"
      "    names.each do|name|\n"
      "      class_eval(\n"
      "        \"def #{name}\\n\" +\n"
      "        \"  warn_unimplemented(\\\"#{self}\\##{name}\\\")\\n\" +\n"
      "        \"  @#{name}\\n\" +\n"
      "        \"end\\n\" +\n"
      "        \"def #{name}=(#{name})\\n\" +\n"
      "        \"  warn_unimplemented(\\\"#{self}\\##{name}\\\")\\n\" +\n"
      "        \"  @#{name} = #{name}\\n\" +\n"
      "        \"end\\n\"\n"
      "      )\n"
      "    end\n"
      "  end\n"
      "end\n"
      "module Audio\n"
#if RGSS == 3
      "  def self.setup_midi\n"
      "    warn_unimplemented(\"Audio.setup_midi\")\n"
      "  end\n"
#endif
#if RGSS == 3
      "  def self.bgm_play(path, volume=nil, pitch=nil, pos=nil)\n"
      "    warn_unimplemented(\"Audio.bgm_play\")\n"
      "  end\n"
#else
      "  def self.bgm_play(path, volume=nil, pitch=nil)\n"
      "    warn_unimplemented(\"Audio.bgm_play\")\n"
      "  end\n"
#endif
      "  def self.bgm_stop\n"
      "    warn_unimplemented(\"Audio.bgm_stop\")\n"
      "  end\n"
      "  def self.bgm_fade(time)\n"
      "    warn_unimplemented(\"Audio.bgm_fade\")\n"
      "  end\n"
#if RGSS == 3
      "  def self.bgm_pos\n"
      "    warn_unimplemented(\"Audio.bgm_pos\")\n"
      "    0\n"
      "  end\n"
#endif
#if RGSS == 3
      "  def self.bgs_play(path, volume=nil, pitch=nil, pos=nil)\n"
      "    warn_unimplemented(\"Audio.bgs_play\")\n"
      "  end\n"
#else
      "  def self.bgs_play(path, volume=nil, pitch=nil)\n"
      "    warn_unimplemented(\"Audio.bgs_play\")\n"
      "  end\n"
#endif
      "  def self.bgs_stop\n"
      "    warn_unimplemented(\"Audio.bgs_stop\")\n"
      "  end\n"
      "  def self.bgs_fade(time)\n"
      "    warn_unimplemented(\"Audio.bgs_fade\")\n"
      "  end\n"
#if RGSS == 3
      "  def self.bgs_pos\n"
      "    warn_unimplemented(\"Audio.bgs_pos\")\n"
      "    0\n"
      "  end\n"
#endif
      "  def self.me_play(path, volume=nil, pitch=nil)\n"
      "    warn_unimplemented(\"Audio.me_play\")\n"
      "  end\n"
      "  def self.me_stop\n"
      "    warn_unimplemented(\"Audio.me_stop\")\n"
      "  end\n"
      "  def self.me_fade(time)\n"
      "    warn_unimplemented(\"Audio.me_fade\")\n"
      "  end\n"
      "  def self.se_play(path, volume=nil, pitch=nil)\n"
      "    warn_unimplemented(\"Audio.se_play\")\n"
      "  end\n"
      "  def self.se_stop\n"
      "    warn_unimplemented(\"Audio.se_stop\")\n"
      "  end\n"
      "end\n"
      "class Bitmap\n"
      "  def blur\n"
      "    warn_unimplemented(\"Bitmap#blur\")\n"
      "  end\n"
      "  def radial_blur\n"
      "    warn_unimplemented(\"Bitmap#radial_blur\")\n"
      "  end\n"
      "  def stretch_blt(*args)\n"
      "    warn_unimplemented(\"Bitmap#stretch_blt\")\n"
      "  end\n"
      "  def hue_change(hue)\n"
      "    warn_unimplemented(\"Bitmap#hue_change\")\n"
      "  end\n"
      "  def gradient_fill_rect(*args)\n"
      "    warn_unimplemented(\"Bitmap#gradient_fill_rect\")\n"
      "  end\n"
      "  def rect\n"
      "    Rect.new(0, 0, width, height)\n"
      "  end\n"
      "end\n"
      "class Font\n"
#if RGSS == 3
      "  @@default_name = \"VL Gothic\"\n"
      "  @@default_size = 24\n"
#elif RGSS == 2
      "  @@default_name = [\"UmePlus Gothic\", \"ＭＳ ゴシック\", \"Courier New\"] \n"
      "  @@default_size = 20\n"
#else
      "  @@default_name = \"ＭＳ Ｐゴシック\"\n"
      "  @@default_size = 22\n"
#endif
      "  @@default_bold = false\n"
      "  @@default_italic = false\n"
#if RGSS == 3
      "  @@default_outline = true\n"
      "  @@default_shadow = false\n"
#elif RGSS == 2
      "  @@default_shadow = true\n"
#endif
      "  @@default_color = Color.new(255, 255, 255, 255)\n"
#if RGSS == 3
      "  @@default_out_color = Color.new(0, 0, 0, 128)\n"
#endif
      "  def self.default_name\n"
      "    @@default_name\n"
      "  end\n"
      "  def self.default_name=(default_name)\n"
      "    @@default_name = default_name\n"
      "  end\n"
      "  def self.default_size\n"
      "    @@default_size\n"
      "  end\n"
      "  def self.default_size=(default_size)\n"
      "    @@default_size = default_size\n"
      "  end\n"
      "  def self.default_bold\n"
      "    @@default_bold\n"
      "  end\n"
      "  def self.default_bold=(default_bold)\n"
      "    @@default_bold = default_bold\n"
      "  end\n"
      "  def self.default_italic\n"
      "    @@default_italic\n"
      "  end\n"
      "  def self.default_italic=(default_italic)\n"
      "    @@default_italic = default_italic\n"
      "  end\n"
#if RGSS == 3
      "  def self.default_outline\n"
      "    @@default_outline\n"
      "  end\n"
      "  def self.default_outline=(default_outline)\n"
      "    @@default_outline = default_outline\n"
      "  end\n"
#endif
#if RGSS >= 2
      "  def self.default_shadow\n"
      "    @@default_shadow\n"
      "  end\n"
      "  def self.default_shadow=(default_shadow)\n"
      "    @@default_shadow = default_shadow\n"
      "  end\n"
#endif
      "  def self.default_color\n"
      "    @@default_color\n"
      "  end\n"
      "  def self.default_color=(default_color)\n"
      "    @@default_color = default_color\n"
      "  end\n"
#if RGSS == 3
      "  def self.default_out_color\n"
      "    @@default_out_color\n"
      "  end\n"
      "  def self.default_out_color=(default_out_color)\n"
      "    @@default_out_color = default_out_color\n"
      "  end\n"
#endif
      "end\n"
      "module Graphics\n"
      "  def self.frame_reset\n"
      "    warn_unimplemented(\"Graphics.frame_reset\")\n"
      "  end\n"
      "  def self.frame_rate\n"
      "    warn_unimplemented(\"Graphics.frame_rate\")\n"
#if RGSS >= 2
      "    60\n"
#else
      "    40\n"
#endif
      "  end\n"
      "  def self.frame_rate=(rate)\n"
      "    warn_unimplemented(\"Graphics.frame_rate=\")\n"
      "  end\n"
      "  def self.frame_count=(count)\n"
      "    warn_unimplemented(\"Graphics.frame_count=\")\n"
      "  end\n"
      "  def self.brightness\n"
      "    warn_unimplemented(\"Graphics.brightness\")\n"
      "    255\n"
      "  end\n"
      "  def self.brightness=(brightness)\n"
      "    warn_unimplemented(\"Graphics.brightness=\")\n"
      "  end\n"
      "  def self.transition(frames = nil)\n"
      "    warn_unimplemented(\"Graphics.transition\")\n"
      "  end\n"
      "  def self.wait(duration)\n"
      "    warn_unimplemented(\"Graphics.wait\")\n"
      "  end\n"
      "  def self.fadein(duration)\n"
      "    warn_unimplemented(\"Graphics.fadein\")\n"
      "  end\n"
      "  def self.fadeout(duration)\n"
      "    warn_unimplemented(\"Graphics.fadeout\")\n"
      "  end\n"
      "  def self.freeze\n"
      "    warn_unimplemented(\"Graphics.freeze\")\n"
      "  end\n"
      "  def self.resize_screen(width, height)\n"
      "    warn_unimplemented(\"Graphics.resize_screen\")\n"
      "  end\n"
      "  def self.snap_to_bitmap\n"
      "    warn_unimplemented(\"Graphics.snap_to_bitmap\")\n"
      "    Bitmap.new(width, height)\n"
      "  end\n"
      "  def self.play_movie(filename)\n"
      "    warn_unimplemented(\"Graphics.play_movie\")\n"
      "  end\n"
      "end\n"
      "class Plane\n"
      "  attr_unimplemented :bitmap, :blend_type, :opacity, :ox, :oy, :tone, :visible, :z, :zoom_x, :zoom_y\n"
      "  def dispose\n"
      "    warn_unimplemented(\"Plane#dispose\")\n"
      "  end\n"
      "  def disposed?\n"
      "    warn_unimplemented(\"Plane#disposed?\")\n"
      "    false\n"
      "  end\n"
      "  def initialize(viewport=nil)\n"
      "    warn_unimplemented(\"Plane.new\")\n"
      "    @bitmap = Bitmap.new(1,1)\n"
      "    @viewport = viewport\n"
      "    @visible = true\n"
      "    @z = 0\n"
      "    @ox = 0\n"
      "    @oy = 0\n"
      "    @zoom_x = 1.0\n"
      "    @zoom_y = 1.0\n"
      "    @opacity = 255\n"
      "    @blend_type = 0\n"
      "    @color = Color.new(0, 0, 0, 0)\n"
      "    @tone = Tone.new(0, 0, 0, 0)\n"
      "  end\n"
      "end\n"
      "class Sprite\n"
      "  def flash(color, condition)\n"
      "    warn_unimplemented(\"Sprite#flash\")\n"
      "  end\n"
      "  def update\n"
      "    warn_unimplemented(\"Sprite#update\")\n"
      "  end\n"
      "end\n"
      "class Tilemap\n"
#if RGSS >= 2
      "  attr_unimplemented :bitmaps, :flags, :flash_data, :map_data, :ox, :oy, :passages, :viewport, :visible\n"
      "  def initialize(viewport=nil)\n"
      "    warn_unimplemented(\"Tilemap.new\")\n"
      "    @bitmaps = [nil] * 9\n"
      "    @map_data = nil\n"
      "    @flash_data = nil\n"
      "    @flags = nil\n"
      "    @viewport = viewport\n"
      "    @visible = true\n"
      "    @ox = 0\n"
      "    @oy = 0\n"
      "  end\n"
      "  def update\n"
      "    warn_unimplemented(\"Tilemap#update\")\n"
      "  end\n"
      "  def dispose\n"
      "    warn_unimplemented(\"Tilemap#dispose\")\n"
      "  end\n"
      "  def disposed?\n"
      "    warn_unimplemented(\"Tilemap#disposed?\")\n"
      "    false\n"
      "  end\n"
#else
      "  attr_unimplemented :autotiles, :map_data, :ox, :oy, :priorities, :tileset\n"
      "  def initialize(viewport=nil)\n"
      "    warn_unimplemented(\"Tilemap.new\")\n"
      "    @autotiles = [nil] * 7\n"
      "    @viewport = viewport\n"
      "    @tileset = nil\n"
      "    @map_data = nil\n"
      "    @flash_data = nil\n"
      "    @priorities = nil\n"
      "    @visible = true\n"
      "    @ox = 0\n"
      "    @oy = 0\n"
      "  end\n"
      "  def update\n"
      "    warn_unimplemented(\"Tilemap#update\")\n"
      "  end\n"
      "  def viewport\n"
      "    warn_unimplemented(\"Tilemap#viewport\")\n"
      "    @viewport\n"
      "  end\n"
      "  def dispose\n"
      "    warn_unimplemented(\"Tilemap#dispose\")\n"
      "  end\n"
      "  def disposed?\n"
      "    warn_unimplemented(\"Tilemap#disposed?\")\n"
      "    false\n"
      "  end\n"
#endif
      "end\n"
      "class Viewport\n"
      "  def flash(color, duration)\n"
      "    warn_unimplemented(\"Viewport#flash\")\n"
      "  end\n"
      "  def update\n"
      "    warn_unimplemented(\"Viewport#update\")\n"
      "  end\n"
      "end\n"
      "class Window\n"
      "  attr_unimplemented :active, :arrows_visible, :back_opacity, :contents_opacity, :cursor_rect, :opacity, :ox, :oy, :padding, :padding_bottom, :pause, :stretch, :tone, :viewport\n"
      "  def update\n"
      "    warn_unimplemented(\"Window#update\")\n"
      "  end\n"
      "  alias_method :initialize_super, :initialize\n"
      "  def initialize(*args)\n"
      "    initialize_super(*args)\n"
      "    @cursor_rect = Rect.new(0, 0, 0, 0)\n"
      "    @ox = 0\n"
      "    @oy = 0\n"
      "    @tone = Tone.new(0.0, 0.0, 0.0, 0.0)\n"
      "    @active = true\n"
      "    @arrows_visible = true\n"
      "    @pause = false\n"
      "    @viewport = nil\n"
      "    @padding = 12\n"
      "    @padding_bottom = 12\n"
      "    @opacity = 255\n"
      "    @back_opacity = 192\n"
      "    @contents_opacity = 255\n"
      "    @tone = Tone.new(0, 0, 0, 0)\n"
      "    @stretch = true\n"
      "  end\n"
      "end\n"
      "\n"
      "module RPG\n"
      "  class AudioFile\n"
#if RGSS == 1
      "    attr_accessor :name, :pitch, :volume\n"
#endif
      "  end\n"
#if RGSS >= 2
      "  class BGM < AudioFile\n"
      "    def play\n"
      "      warn_unimplemented(\"RPG::BGM#play\")\n"
      "    end\n"
      "    def self.stop\n"
      "      warn_unimplemented(\"RPG::BGM.stop\")\n"
      "    end\n"
      "    def self.fade(time)\n"
      "      warn_unimplemented(\"RPG::BGM.fade\")\n"
      "    end\n"
      "  end\n"
      "  class BGS < AudioFile\n"
      "    def play\n"
      "      warn_unimplemented(\"RPG::BGS#play\")\n"
      "    end\n"
      "    def self.stop\n"
      "      warn_unimplemented(\"RPG::BGS.stop\")\n"
      "    end\n"
      "    def self.fade(time)\n"
      "      warn_unimplemented(\"RPG::BGS.fade\")\n"
      "    end\n"
      "  end\n"
      "  class ME < AudioFile\n"
      "    def play\n"
      "      warn_unimplemented(\"RPG::ME#play\")\n"
      "    end\n"
      "    def self.stop\n"
      "      warn_unimplemented(\"RPG::ME.stop\")\n"
      "    end\n"
      "    def self.fade(time)\n"
      "      warn_unimplemented(\"RPG::ME.fade\")\n"
      "    end\n"
      "  end\n"
      "  class SE < AudioFile\n"
      "    def play\n"
      "      warn_unimplemented(\"RPG::SE#play\")\n"
      "    end\n"
      "    def self.stop\n"
      "      warn_unimplemented(\"RPG::SE.stop\")\n"
      "    end\n"
      "  end\n"
#endif
      "  class Animation\n"
      "    class Frame\n"
      "    end\n"
      "    class Timing\n"
      "    end\n"
      "  end\n"
#if RGSS == 2
      "  class Area\n"
      "  end\n"
#endif
#if RGSS >= 2
      "  class BaseItem\n"
      "    attr_accessor :description, :icon_index, :id, :name, :note\n"
#if RGSS == 3
      "    attr_accessor :features\n"
      "    class Feature\n"
      "      attr_accessor :code, :data_id\n"
      "    end\n"
#endif
      "  end\n"
#endif
#if RGSS == 3
      "  class Actor < BaseItem\n"
#else
      "  class Actor\n"
#endif
      "    attr_accessor :character_name, :class_id, :initial_level, :name\n"
#if RGSS == 3
      "    attr_accessor :character_index, :equips, :face_index, :face_name, :nickname\n"
#elif RGSS == 2
      "    attr_accessor :armor1_id, :armor2_id, :armor3_id, :armor4_id, :exp_basis, :exp_inflation, :character_index, :face_index, :face_name, :parameters, :weapon_id\n"
#elif RGSS == 1
      "    attr_accessor :armor1_id, :armor2_id, :armor3_id, :armor4_id, :battler_hue, :battler_name, :character_hue, :exp_basis, :exp_inflation, :final_level, :parameters, :weapon_id\n"
#endif
      "  end\n"
#if RGSS == 3
      "  class Class < BaseItem\n"
#else
      "  class Class\n"
#endif
      "    attr_accessor :learnings\n"
#if RGSS == 3
      "    attr_accessor :params\n"
      "    def exp_for_level(level)\n"
      // TODO: correct exp_for_level implementation
      "      1\n"
      "    end\n"
#elif RGSS == 2
#elif RGSS == 1
#endif
      "    class Learning\n"
      "      attr_accessor :level, :skill_id\n"
#if RGSS == 3
      "      attr_accessor :note\n"
#endif
      "    end\n"
      "  end\n"
#if RGSS >= 2
      "  class UsableItem < BaseItem\n"
#if RGSS == 3
      "    def need_selection?\n"
      "      [1, 7, 9].include?(@scope)\n"
      "    end\n"
      "    class Effect\n"
      "    end\n"
      "    class Damage\n"
      "    end\n"
#endif
      "  end\n"
#endif
#if RGSS >= 2
      "  class Skill < UsableItem\n"
#else
      "  class Skill\n"
#endif
#if RGSS == 3
      "    attr_accessor :id\n"
#endif
      "  end\n"
#if RGSS >= 2
      "  class Item < UsableItem\n"
#else
      "  class Item\n"
#endif
      "  end\n"
#if RGSS == 3
      "  class EquipItem < BaseItem\n"
      "    attr_accessor :etype_id, :params\n"
      "  end\n"
#endif
#if RGSS == 3
      "  class Weapon < EquipItem\n"
#elif RGSS == 2
      "  class Weapon < BaseItem\n"
#else
      "  class Weapon\n"
#endif
#if RGSS == 3
      "    attr_accessor :wtype_id\n"
#endif
      "  end\n"
#if RGSS == 3
      "  class Armor < EquipItem\n"
#elif RGSS == 2
      "  class Armor < BaseItem\n"
#else
      "  class Armor\n"
#endif
#if RGSS == 3
      "    attr_accessor :atype_id\n"
#elif RGSS == 2
#elif RGSS == 1
      "    attr_accessor :auto_state_id\n"
#endif
      "  end\n"
#if RGSS == 3
      "  class Enemy < BaseItem\n"
#else
      "  class Enemy\n"
#endif
      "    class Action\n"
      "    end\n"
#if RGSS >= 2
      "    class DropItem\n"
      "    end\n"
#endif
      "  end\n"
#if RGSS == 3
      "  class State < BaseItem\n"
#else
      "  class State\n"
      "    attr_accessor :auto_release_prob, :agi_rate, :atk_rate, :battle_only, :hold_turn, :name, :nonresistance, :slip_damage, :id\n"
#endif
      "    attr_accessor :restriction\n"
#if RGSS == 3
      "    attr_accessor :auto_removal_timing, :chance_by_damage, :max_turns, :message1, :message2, :message3, :message4, :min_turns, :priority, :steps_to_remove, :remove_at_battle_end, :remove_by_damage, :remove_by_restriction, :remove_by_walking\n"
#elif RGSS == 2
      "    attr_accessor :def_rate, :element_set, :icon_index, :message1, :message2, :message3, :message4, :note, :offset_by_opposite, :priority, :reduce_hit_ratio, :release_by_damage, :spi_rate, :state_set\n"
#elif RGSS == 1
      "    attr_accessor :animation_id, :cant_evade, :cant_get_exp, :eva, :guard_element_set, :hit_rate, :int_rate, :maxhp_rate, :maxsp_rate, :mdef_rate, :minus_state_set, :pdef_rate, :plus_state_set, :rating, :shock_release_prob, :str_rate, :zero_hp\n"
#endif
      "  end\n"
#if RGSS == 1
      "  module Cache\n"
      "    @cache = {}\n"
      "    def self.load_bitmap(dir, name, hue=0)\n"
      "      path = dir + name\n"
      "      key = hue == 0 ? path : [path, hue]\n"
      "      if !@cache[key] || @cache[key].disposed?\n"
      "        if name == \"\"\n"
      "          @cache[key] = Bitmap.new(32, 32)\n"
      "        else\n"
      "          @cache[key] = Bitmap.new(key)\n"
      "          @cache[key].hue_change(hue)\n"
      "        end\n"
      "      end\n"
      "      @cache[key]\n"
      "    end\n"
      "    def self.animation(name, hue)\n"
      "      load_bitmap(\"Graphics/Animations/\", name, hue)\n"
      "    end\n"
      "    def self.autotile(name)\n"
      "      load_bitmap(\"Graphics/Autotiles/\", name)\n"
      "    end\n"
      "    def self.battleback(name)\n"
      "      load_bitmap(\"Graphics/Battlebacks/\", name)\n"
      "    end\n"
      "    def self.battler(name, hue)\n"
      "      load_bitmap(\"Graphics/Battlers/\", name, hue)\n"
      "    end\n"
      "    def self.character(name, hue)\n"
      "      load_bitmap(\"Graphics/Characters/\", name, hue)\n"
      "    end\n"
      "    def self.fog(name, hue)\n"
      "      load_bitmap(\"Graphics/Fogs/\", name, hue)\n"
      "    end\n"
      "    def self.gameover(name)\n"
      "      load_bitmap(\"Graphics/Gameovers/\", name)\n"
      "    end\n"
      "    def self.icon(name)\n"
      "      load_bitmap(\"Graphics/Icons/\", name)\n"
      "    end\n"
      "    def self.panoramas(name, hue)\n"
      "      load_bitmap(\"Graphics/Panoramas/\", name, hue)\n"
      "    end\n"
      "    def self.picture(name)\n"
      "      load_bitmap(\"Graphics/Pictures/\", name)\n"
      "    end\n"
      "    def self.tileset(name)\n"
      "      load_bitmap(\"Graphics/Tilesets/\", name)\n"
      "    end\n"
      "    def self.title(name)\n"
      "      load_bitmap(\"Graphics/Titles/\", name)\n"
      "    end\n"
      "    def self.transition(name)\n"
      "      load_bitmap(\"Graphics/Transitions/\", name)\n"
      "    end\n"
      "    def self.windowskin(name)\n"
      "      load_bitmap(\"Graphics/Windowskins/\", name)\n"
      "    end\n"
      "  end\n"
#endif
      "  class CommonEvent\n"
      "    attr_accessor :id, :name, :trigger, :switch_id, :list\n"
#if RGSS == 3
      "    def autorun?\n"
      "      @trigger == 1\n"
      "    end\n"
      "    def parallel?\n"
      "      @trigger == 2\n"
      "    end\n"
#endif
      "  end\n"
      "  class Event\n"
      "    attr_accessor :id, :name, :pages, :x, :y\n"
      "    class Page\n"
      "      attr_accessor :condition, :direction_fix, :graphic, :list, :move_frequency, :move_route, :move_speed, :move_type, :step_anime, :through, :trigger, :walk_anime\n"
#if RGSS >= 2
      "      attr_accessor :priority_type\n"
#elif RGSS == 1
      "      attr_accessor :always_on_top\n"
#endif
      "      class Condition\n"
      "        attr_accessor :self_switch_ch, :self_switch_valid, :switch1_id, :switch1_valid, :switch2_id, :switch2_valid, :variable_id, :variable_valid, :variable_value\n"
#if RGSS >= 2
      "        attr_accessor :actor_id, :actor_valid, :item_id, :item_valid\n"
#endif
      "      end\n"
      "      class Graphic\n"
      "        attr_accessor :character_name, :direction, :pattern, :tile_id\n"
#if RGSS >= 2
      "        attr_accessor :character_index\n"
#elif RGSS == 1
      "        attr_accessor :blend_type, :character_hue, :character_name, :opacity, :tile_id\n"
#endif
      "      end\n"
      "    end\n"
      "  end\n"
      "  class EventCommand\n"
      "    attr_accessor :code, :parameters\n"
#if RGSS == 3
      "    attr_accessor :indent\n"
#elif RGSS == 2
      "    attr_accessor :indent\n"
#elif RGSS == 1
#endif
      "  end\n"
      "  class Map\n"
      "    attr_accessor :autoplay_bgm, :autoplay_bgs, :bgm, :bgs, :data, :encounter_list, :encounter_step, :events, :height, :width\n"
#if RGSS >= 2
      "    attr_accessor :disable_dashing, :parallax_loop_x, :parallax_loop_y, :parallax_name, :parallax_show, :parallax_sx, :parallax_sy, :scroll_type\n"
#endif
#if RGSS == 3
      "    attr_accessor :battleback1_name, :battleback2_name, :display_name, :note, :specify_battleback, :tileset_id\n"
#endif
#if RGSS == 1
      "    attr_accessor :tileset_id\n"
#endif
      "  end\n"
      "  class MapInfo\n"
#if RGSS == 1
      "    attr_accessor :name\n"
#endif
      "  end\n"
      "  class MoveCommand\n"
      "    attr_accessor :code, :parameters\n"
      "  end\n"
      "  class MoveRoute\n"
      "    attr_accessor :list, :repeat, :skippable\n"
#if RGSS >= 2
      "    attr_accessor :wait\n"
#endif
      "  end\n"
#if RGSS == 1
      "  class Sprite < ::Sprite\n"
      "    @@_animations = []\n"
      "  end\n"
#endif
      "  class System\n"
      "    attr_accessor :party_members, :start_map_id, :start_x, :start_y, :title_bgm\n"
#if RGSS >= 2
      "    attr_accessor :airship, :boat, :ship\n"
      "    attr_accessor :terms\n"
#endif
#if RGSS == 3
      "    attr_accessor :currency_unit, :game_title, :opt_draw_title, :opt_followers, :opt_transparent, :opt_use_midi, :sounds, :title1_name, :title2_name, :window_tone\n"
#elif RGSS == 2
      "    attr_accessor :passages, :sounds\n"
#elif RGSS == 1
      "    attr_accessor :cursor_se, :decision_se, :title_name, :windowskin_name\n"
#endif
      "    class "TERMS"\n"
#if RGSS == 3
      "      attr_accessor :basic, :commands, :etypes, :params\n"
#else
      "      attr_accessor :agi, :armor1, :armor2, :armor3, :armor4, :atk, :attack, :equip, :gold, :guard, :hp, :item, :skill, :weapon\n"
#if RGSS == 2
      "      attr_accessor :cancel, :continue, :def, :escape, :fight, :game_end, :hp_a, :level, :level_a, :mp, :mp_a, :new_game, :save, :shutdown, :spi, :status, :to_title, :weapon1, :weapon2\n"
#else
      "      attr_accessor :dex, :int, :mdef, :pdef, :sp, :str\n"
#endif
#endif
      "    end\n"
      "    class TestBattler\n"
      "    end\n"
#if RGSS >= 2
      "    class Vehicle\n"
      "      attr_accessor :character_index, :character_name, :start_map_id, :start_x, :start_y\n"
#if RGSS == 3
#else
      "      attr_accessor :bgm\n"
#endif
      "    end\n"
#endif
      "  end\n"
#if RGSS == 3
      "  class Tileset\n"
      "    attr_accessor :flags, :id, :mode, :name, :note, :tileset_names\n"
      "  end\n"
#elif RGSS == 1
      "  class Tileset\n"
      "    attr_accessor :autotile_names, :battleback_name, :fog_blend_type, :fog_hue, :fog_name, :fog_opacity, :fog_sx, :fog_sy, :fog_zoom, :id, :name, :panorama_hue, :panorama_name, :passages, :priorities, :terrain_tags, :tileset_name\n"
      "  end\n"
#endif
      "  class Troop\n"
      "    class Member\n"
      "    end\n"
      "    class Page\n"
      "      class Condition\n"
      "      end\n"
      "    end\n"
      "  end\n"
#if RGSS == 1
      "  class Weather\n"
      "    attr_accessor :max, :ox, :oy, :type\n"
      "    def initialize(viewport=nil)\n"
      "    end\n"
      "    def update\n"
      "    end\n"
      "  end\n"
#endif
      "end\n"
      "\n"
#if RGSS == 3
      "def rgss_main\n"
      "  yield\n"
      "rescue "RGSS_RESET"\n"
      "  GC.start\n"
      "  retry\n"
      "end\n"
      "def rgss_stop\n"
      "  loop { Graphics.update }\n"
      "end\n"
      "def msgbox(*args)\n"
      "  print *args\n"
      "end\n"
      "def msgbox_p(*args)\n"
      "  p *args\n"
      "end\n"
#endif
      "def save_data(obj, filename)\n"
      "  File.open(filename.gsub(/\\\\/, \"/\"), \"wb\") do|f|\n"
      "    Marshal.dump(obj, f)\n"
      "  end\n"
      "end\n"
      "begin\n"
      /* TODO: determine script path from Game.ini */
      "  load_data("SCRIPT_PATH").each do|num,title,script|\n"
      "    s = Zlib::Inflate::inflate(script)\n"
#if RGSS == 3
      "    s.force_encoding(\"utf-8\")\n"
#endif
      "    eval(s, binding, title)\n"
      "  end\n"
      "rescue "RGSS_RESET"\n"
      "  retry\n"
      // "rescue SystemExit\n"
      // "  raise\n"
      "rescue Exception => e\n"
      "  $stderr.print(\"#{e.class}: #{e.message}\\n\")\n"
      "  e.backtrace.each do|frame|\n"
      "    $stderr.print(\"\\tfrom #{frame}\\n\")\n"
      "  end\n"
      "end\n"
  );
  return Qnil;
}
