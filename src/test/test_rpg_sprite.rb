# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  module MockSprite
    SpriteMethods = [
      :initialize, :dispose, :disposed?, :viewport, :flash, :update]
    def mock_sprite(&b)
      ::Sprite.class_eval do
        self.class_eval("@@history = []")
        SpriteMethods.each do|mname|
          m_orig_name = "#{mname}_orig".to_sym
          alias_method m_orig_name, mname
          self.class_eval(
            "def #{mname}(*args)\n" +
            "  @@history << [#{mname.inspect}, *args]\n" +
            "  send(#{m_orig_name.inspect}, *args)\n" +
            "end\n")
        end
      end
      begin
        b.call
        history = ::Sprite.class_eval("@@history")
        ::Sprite.class_eval("remove_class_variable(:@@history)")
      ensure
        ::Sprite.class_eval do
          SpriteMethods.each do|mname|
            m_orig_name = "#{mname.to_s}_orig".to_sym
            alias_method mname, m_orig_name
            remove_method m_orig_name
          end
        end
      end
      history
    end
  end

  if RGSS == 1
  class TestRPGSprite < Test
    include MockSprite

    @@klass = RPG::Sprite

    def test_superclass
      assert_equal(@@klass.superclass, ::Sprite)
    end

    def test_constants
      assert_symset_equal(@@klass.constants, [])
    end

    def test_class_variables
      assert_symset_equal(@@klass.class_variables, [
        :@@_animations, :@@_reference_count])
    end

    def test_class_methods
      assert_symset_equal(@@klass.methods - Object.methods, [])
    end

    def test_instance_methods
      assert_symset_equal(owned_instance_methods(@@klass), [
        :animation, :animation_process_timing, :animation_set_sprites, :appear,
        :blink?, :blink_off, :blink_on, :collapse, :damage, :dispose,
        :dispose_animation, :dispose_damage, :dispose_loop_animation,
        :effect?, :escape, :loop_animation, :update, :update_animation,
        :update_loop_animation, :whiten, :x=, :y=])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [
        :@_animation_duration, :@_appear_duration, :@_blink,
        :@_collapse_duration, :@_damage_duration, :@_escape_duration,
        :@_whiten_duration])
    end

    def get(obj)
      [obj.bitmap, obj.src_rect, obj.visible, obj.x, obj.y, obj.z, obj.ox,
       obj.oy, obj.zoom_x, obj.zoom_y, obj.angle, obj.mirror, obj.bush_depth,
       obj.opacity, obj.blend_type, obj.color, obj.tone,
       obj.instance_eval("@_animation_duration"),
       obj.instance_eval("@_appear_duration"),
       obj.instance_eval("@_blink"),
       obj.instance_eval("@_collapse_duration"),
       obj.instance_eval("@_damage_duration"),
       obj.instance_eval("@_escape_duration"),
       obj.instance_eval("@_whiten_duration")]
    end

    def set(obj, a)
      obj.bitmap = a.shift
      obj.src_rect = a.shift
      obj.visible = a.shift
      obj.x = a.shift
      obj.y = a.shift
      obj.z = a.shift
      obj.ox = a.shift
      obj.oy = a.shift
      obj.zoom_x = a.shift
      obj.zoom_y = a.shift
      obj.angle = a.shift
      obj.mirror = a.shift
      obj.bush_depth = a.shift
      obj.opacity = a.shift
      obj.blend_type = a.shift
      obj.color = a.shift
      obj.tone = a.shift
      obj.instance_eval("@_animation_duration = #{a.shift.inspect}")
      obj.instance_eval("@_appear_duration = #{a.shift.inspect}")
      obj.instance_eval("@_blink = #{a.shift.inspect}")
      obj.instance_eval("@_collapse_duration = #{a.shift.inspect}")
      obj.instance_eval("@_damage_duration = #{a.shift.inspect}")
      obj.instance_eval("@_escape_duration = #{a.shift.inspect}")
      obj.instance_eval("@_whiten_duration = #{a.shift.inspect}")
    end

    def test_new
      obj = @@klass.new
      obj = @@klass.new(Viewport.new(0, 0, 0, 0))
      assert_raise(ArgumentError) { @@klass.new(:hoge, :fuga) }
      assert_raise(TypeError) { @@klass.new(:hoge) }

      history = mock_sprite {
        obj = @@klass.new
      }
      assert_equal(history, [[:initialize, nil]])
      assert_equal(get(obj), [
        nil, Rect.new(0, 0, 0, 0), true, 0, 0, 0, 0, 0, 1.0, 1.0, 0.0,
        false, 0, 255, 0, Color.new(0, 0, 0, 0), Tone.new(0, 0, 0, 0),
        0, 0, false, 0, 0, 0, 0])
    end

    def test_whiten_1
      obj = @@klass.new
      history = mock_sprite {
        obj.whiten
      }
      assert_equal(history, [])
      assert_equal(get(obj), [
        nil, Rect.new(0, 0, 0, 0), true, 0, 0, 0, 0, 0, 1.0, 1.0, 0.0,
        false, 0, 255, 0, Color.new(255, 255, 255, 128), Tone.new(0, 0, 0, 0),
        0, 0, false, 0, 0, 0, 16])
    end

    def test_whiten_2
      obj = @@klass.new
      b = Bitmap.new(32, 32)
      set(obj, [
        b, Rect.new(22, 5, 20, -2), false, 3, -7, 2, 57, 13, 1.1, 0.9, 4.0,
        true, 7, 234, 2, Color.new(123, 3.4, 240, 10), Tone.new(1, 2, -7, 13),
        23, 5, true, 7, 9, 13, 6])
      obj.whiten
      assert_equal(get(obj), [
        b, Rect.new(22, 5, 20, -2), false, 3, -7, 2, 57, 13, 1.1, 0.9, 4.0,
        true, 7, 255, 0, Color.new(255, 255, 255, 128), Tone.new(1, 2, -7, 13),
        23, 0, true, 0, 9, 0, 16])
    end

    def test_whiten_3
      obj = @@klass.new
      assert_raise(ArgumentError) { obj.whiten(:hoge) }
    end

    def test_appear_1
      obj = @@klass.new
      history = mock_sprite {
        obj.appear
      }
      assert_equal(history, [])
      assert_equal(get(obj), [
        nil, Rect.new(0, 0, 0, 0), true, 0, 0, 0, 0, 0, 1.0, 1.0, 0.0,
        false, 0, 0, 0, Color.new(0, 0, 0, 0), Tone.new(0, 0, 0, 0),
        0, 16, false, 0, 0, 0, 0])
    end

    def test_appear_2
      obj = @@klass.new
      b = Bitmap.new(32, 32)
      set(obj, [
        b, Rect.new(-100, 2, 7, 5), false, -27, 3, 10, 20, 44, 3.0, 8.0, 180.0,
        true, 7, 117, 1, Color.new(16, 28, 155, 30), Tone.new(30, 30, 20, 99),
        654, 321, true, 213, 12, 3, 2])
      obj.appear
      assert_equal(get(obj), [
        b, Rect.new(-100, 2, 7, 5), false, -27, 3, 10, 20, 44, 3.0, 8.0, 180.0,
        true, 7, 0, 0, Color.new(0, 0, 0, 0), Tone.new(30, 30, 20, 99),
        654, 16, true, 0, 12, 0, 0])
    end

    def test_appear_3
      obj = @@klass.new
      assert_raise(ArgumentError) { obj.appear(:hoge) }
    end

    def test_escape_1
      obj = @@klass.new
      history = mock_sprite {
        obj.escape
      }
      assert_equal(history, [])
      assert_equal(get(obj), [
        nil, Rect.new(0, 0, 0, 0), true, 0, 0, 0, 0, 0, 1.0, 1.0, 0.0,
        false, 0, 255, 0, Color.new(0, 0, 0, 0), Tone.new(0, 0, 0, 0),
        0, 0, false, 0, 0, 32, 0])
    end

    def test_escape_2
      obj = @@klass.new
      b = Bitmap.new(32, 32)
      set(obj, [
        b, Rect.new(76, 55, -30, -9), false, 19, 101, 1, 9, 5, 0.5, 0.5, 3.0,
        true, 27, 27, 2, Color.new(192, 155, 100, 33), Tone.new(1, 2, 3, 4),
        6, 11, true, 27, 5, 33, 37])
      obj.escape
      assert_equal(get(obj), [
        b, Rect.new(76, 55, -30, -9), false, 19, 101, 1, 9, 5, 0.5, 0.5, 3.0,
        true, 27, 255, 0, Color.new(0, 0, 0, 0), Tone.new(1, 2, 3, 4),
        6, 0, true, 0, 5, 32, 0])
    end

    def test_escape_3
      obj = @@klass.new
      assert_raise(ArgumentError) { obj.escape(:hoge) }
    end

    def test_collapse_1
      obj = @@klass.new
      history = mock_sprite {
        obj.collapse
      }
      assert_equal(history, [])
      assert_equal(get(obj), [
        nil, Rect.new(0, 0, 0, 0), true, 0, 0, 0, 0, 0, 1.0, 1.0, 0.0,
        false, 0, 255, 1, Color.new(255, 64, 64, 255), Tone.new(0, 0, 0, 0),
        0, 0, false, 48, 0, 0, 0])
    end

    def test_collapse_2
      obj = @@klass.new
      b = Bitmap.new(32, 32)
      set(obj, [
        b, Rect.new(1, 3, -5, -7), false, 3, 3, 3, 3, 3, 3.0, 3.0, 3.0,
        true, 3, 3, 2, Color.new(3, 3, 3, 3), Tone.new(3, 3, 3, 3),
        3, 3, true, 30, 300, 3000, 30000])
      obj.collapse
      assert_equal(get(obj), [
        b, Rect.new(1, 3, -5, -7), false, 3, 3, 3, 3, 3, 3.0, 3.0, 3.0,
        true, 3, 255, 1, Color.new(255, 64, 64, 255), Tone.new(3, 3, 3, 3),
        3, 0, true, 48, 300, 0, 0])
    end

    def test_collapse_3
      obj = @@klass.new
      assert_raise(ArgumentError) { obj.collapse(:hoge) }
    end

    # TODO
    # def test_damage
    # end

    # TODO
    # def test_animation
    # end

    # TODO
    # def test_loop_animation
    # end

    def test_blink_on_1
      obj = @@klass.new
      history = mock_sprite {
        obj.blink_on
      }
      assert_equal(history, [])
      assert_equal(get(obj), [
        nil, Rect.new(0, 0, 0, 0), true, 0, 0, 0, 0, 0, 1.0, 1.0, 0.0,
        false, 0, 255, 0, Color.new(0, 0, 0, 0), Tone.new(0, 0, 0, 0),
        0, 0, true, 0, 0, 0, 0])
    end

    def test_blink_on_2
      obj = @@klass.new
      b = Bitmap.new(32, 32)
      set(obj, [
        b, Rect.new(7, 8, 9, 10), false, 11, 12, 13, 14, 15, 16.0, 17.0, 18.0,
        true, 19, 20, 1, Color.new(22, 23, 24, 25), Tone.new(26, 27, 28, 29),
        30, 31, true, 32, 33, 34, 35])
      obj.blink_on
      assert_equal(get(obj), [
        b, Rect.new(7, 8, 9, 10), false, 11, 12, 13, 14, 15, 16.0, 17.0, 18.0,
        true, 19, 20, 1, Color.new(22, 23, 24, 25), Tone.new(26, 27, 28, 29),
        30, 31, true, 32, 33, 34, 35])
    end

    def test_blink_on_3
      obj = @@klass.new
      assert_raise(ArgumentError) { obj.blink_on(:hoge) }
    end

    def test_blink_off_1
      obj = @@klass.new
      history = mock_sprite {
        obj.blink_off
      }
      assert_equal(history, [])
      assert_equal(get(obj), [
        nil, Rect.new(0, 0, 0, 0), true, 0, 0, 0, 0, 0, 1.0, 1.0, 0.0,
        false, 0, 255, 0, Color.new(0, 0, 0, 0), Tone.new(0, 0, 0, 0),
        0, 0, false, 0, 0, 0, 0])
    end

    def test_blink_off_2
      obj = @@klass.new
      b = Bitmap.new(32, 32)
      set(obj, [
        b, Rect.new(7, 8, 9, 10), false, 11, 12, 13, 14, 15, 16.0, 17.0, 18.0,
        true, 19, 20, 1, Color.new(22, 23, 24, 25), Tone.new(26, 27, 28, 29),
        30, 31, true, 32, 33, 34, 35])
      obj.blink_off
      assert_equal(get(obj), [
        b, Rect.new(7, 8, 9, 10), false, 11, 12, 13, 14, 15, 16.0, 17.0, 18.0,
        true, 19, 20, 1, Color.new(0, 0, 0, 0), Tone.new(26, 27, 28, 29),
        30, 31, false, 32, 33, 34, 35])
    end

    def test_blink_off_3
      obj = @@klass.new
      assert_raise(ArgumentError) { obj.blink_off(:hoge) }
    end

    def test_blink_p_1
      obj = @@klass.new
      assert_equal(obj.blink?, false)
    end

    def test_blink_p_2
      obj = @@klass.new
      set(obj, [
        nil, Rect.new(0, 0, 0, 0), true, 0, 0, 0, 0, 0, 1.0, 1.0, 0.0,
        false, 0, 255, 0, Color.new(0, 0, 0, 0), Tone.new(0, 0, 0, 0),
        0, 0, true, 0, 0, 0, 0])
      assert_equal(obj.blink?, true)
    end

    def test_blink_p_3
      obj = @@klass.new
      b = Bitmap.new(32, 32)
      set(obj, [
        b, Rect.new(8, 9, 8, 9), false, 8, 9, 8, 9, 8, 9.0, 8.0, 9.0,
        true, 8, 9, 1, Color.new(9, 8, 9, 8), Tone.new(9, 8, 9, 8),
        9, 8, true, 8, 9, 8, 9])
      assert_equal(obj.blink?, true)
    end

    def test_blink_p_4
      obj = @@klass.new
      assert_raise(ArgumentError) { obj.blink?(:hoge) }
    end

    def test_effect_p_1
      obj = @@klass.new
      assert_equal(obj.effect?, false)
    end

    def test_effect_p_2
      obj = @@klass.new
      set(obj, [
        nil, Rect.new(0, 0, 0, 0), true, 0, 0, 0, 0, 0, 1.0, 1.0, 0.0,
        false, 0, 255, 0, Color.new(0, 0, 0, 0), Tone.new(0, 0, 0, 0),
        0, 0, true, 0, 0, 0, 0])
      assert_equal(obj.effect?, false)
    end

    def test_effect_p_3
      obj = @@klass.new
      b = Bitmap.new(32, 32)
      set(obj, [
        b, Rect.new(1, 1, 1, 1), false, 1, 1, 1, 1, 1, 2.0, 2.0, 1.0,
        true, 1, 254, 1, Color.new(1, 1, 1, 1), Tone.new(1, 1, 1, 1),
        0, 0, true, 0, 0, 0, 0])
      assert_equal(obj.effect?, false)
    end

    def test_effect_p_4
      obj = @@klass.new
      b = Bitmap.new(32, 32)
      set(obj, [
        b, Rect.new(1, 1, 1, 1), false, 1, 1, 1, 1, 1, 2.0, 2.0, 1.0,
        true, 1, 254, 1, Color.new(1, 1, 1, 1), Tone.new(1, 1, 1, 1),
        1, 0, true, 0, 0, 0, 0])
      assert_equal(obj.effect?, true)
    end

    def test_effect_p_5
      obj = @@klass.new
      b = Bitmap.new(32, 32)
      set(obj, [
        b, Rect.new(1, 1, 1, 1), false, 1, 1, 1, 1, 1, 2.0, 2.0, 1.0,
        true, 1, 254, 1, Color.new(1, 1, 1, 1), Tone.new(1, 1, 1, 1),
        0, 1, true, 0, 0, 0, 0])
      assert_equal(obj.effect?, true)
    end

    def test_effect_p_6
      obj = @@klass.new
      b = Bitmap.new(32, 32)
      set(obj, [
        b, Rect.new(1, 1, 1, 1), false, 1, 1, 1, 1, 1, 2.0, 2.0, 1.0,
        true, 1, 254, 1, Color.new(1, 1, 1, 1), Tone.new(1, 1, 1, 1),
        0, 0, true, 1, 0, 0, 0])
      assert_equal(obj.effect?, true)
    end

    def test_effect_p_7
      obj = @@klass.new
      b = Bitmap.new(32, 32)
      set(obj, [
        b, Rect.new(1, 1, 1, 1), false, 1, 1, 1, 1, 1, 2.0, 2.0, 1.0,
        true, 1, 254, 1, Color.new(1, 1, 1, 1), Tone.new(1, 1, 1, 1),
        0, 0, true, 0, 1, 0, 0])
      assert_equal(obj.effect?, true)
    end

    def test_effect_p_8
      obj = @@klass.new
      b = Bitmap.new(32, 32)
      set(obj, [
        b, Rect.new(1, 1, 1, 1), false, 1, 1, 1, 1, 1, 2.0, 2.0, 1.0,
        true, 1, 254, 1, Color.new(1, 1, 1, 1), Tone.new(1, 1, 1, 1),
        0, 0, true, 0, 0, 1, 0])
      assert_equal(obj.effect?, true)
    end

    def test_effect_p_9
      obj = @@klass.new
      b = Bitmap.new(32, 32)
      set(obj, [
        b, Rect.new(1, 1, 1, 1), false, 1, 1, 1, 1, 1, 2.0, 2.0, 1.0,
        true, 1, 254, 1, Color.new(1, 1, 1, 1), Tone.new(1, 1, 1, 1),
        0, 0, true, 0, 0, 0, 1])
      assert_equal(obj.effect?, true)
    end

    # TODO
    # def test_update
    # end
  end
  end # if RGSS == 1
end
