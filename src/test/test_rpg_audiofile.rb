# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  module MockAudio
    def mock_audio(&b)
      audio_mock = Object.new
      class << audio_mock
        attr_accessor :history
        def bgm_pos
          33
        end
        def bgs_pos
          44
        end
        def method_missing(name, *args)
          @history << [name, *args]
          nil
        end
      end
      audio_mock.history = []
      audio_original = Object::Audio
      begin
        Object.send(:remove_const, :Audio)
        Object.const_set(:Audio, audio_mock)
        b.call
      ensure
        Object.send(:remove_const, :Audio)
        Object.const_set(:Audio, audio_original)
      end
      audio_mock.history
    end
  end

  class TestRPGAudioFile < Test
    @@klass = RPG::AudioFile

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
        :name, :name=, :pitch, :pitch=, :volume, :volume=])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [
        :@name, :@pitch, :@volume])
    end

    def test_new
      obj = @@klass.new
      assert_equal(obj.name, "")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 100)

      obj = @@klass.new("hoge")
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 100)

      obj = @@klass.new("hoge", 137)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 137)

      obj = @@klass.new("hoge", 137, 227)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 227)
      assert_equal(obj.volume, 137)

      assert_raise(ArgumentError) { @@klass.new(:hoge, :fuga, :piyo, :quux) }
    end

    def test_name
      obj = @@klass.new
      assert_equal(obj.name, "")
      obj.name = "hoge"
      assert_equal(obj.name, "hoge")
    end

    def test_pitch
      obj = @@klass.new
      assert_equal(obj.pitch, 100)
      obj.pitch = 227
      assert_equal(obj.pitch, 227)
    end

    def test_volume
      obj = @@klass.new
      assert_equal(obj.volume, 100)
      obj.volume = 137
      assert_equal(obj.volume, 137)
    end
  end

  if RGSS >= 2
  class TestRPGBGM < Test
    include MockAudio

    @@klass = RPG::BGM
    @@last = RPG::BGM.class_eval("@@last")

    def test_superclass
      assert_equal(@@klass.superclass, RPG::AudioFile)
    end

    def test_constants
      assert_symset_equal(@@klass.constants, [])
    end

    def test_class_variables
      assert_symset_equal(@@klass.class_variables, [:@@last])
    end

    def test_class_methods
      assert_symset_equal(@@klass.methods - Object.methods, [
        :fade, :last, :stop])
    end

    def test_instance_methods
      if RGSS == 3
        assert_symset_equal(owned_instance_methods(@@klass), [
          :play, :pos, :pos=, :replay])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [:play])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [:@name, :@pitch, :@volume])
    end

    def test_new
      obj = @@klass.new
      assert_equal(obj.name, "")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.pos, nil) if RGSS == 3
      assert_equal(obj.volume, 100)

      obj = @@klass.new("hoge")
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.pos, nil) if RGSS == 3
      assert_equal(obj.volume, 100)

      obj = @@klass.new("hoge", 22)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.pos, nil) if RGSS == 3
      assert_equal(obj.volume, 22)

      obj = @@klass.new("hoge", 22, 37)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 37)
      assert_equal(obj.pos, nil) if RGSS == 3
      assert_equal(obj.volume, 22)

      assert_raise(ArgumentError) { @@klass.new(:hoge, :fuga, :piyo, :quux) }
    end

    def test_last
      assert_equal(@@last.class, @@klass)
    end

    def test_play
      history = mock_audio {
        @@klass.class_eval("@@last = nil")
        obj = @@klass.new("hoge", 22, 37)
        obj.play
        last = @@klass.last
        assert_not_same(obj, last) if RGSS == 3
        assert_same(obj, last) if RGSS == 2
        assert_equal(last.class, @@klass)
        assert_equal(last.name, "hoge")
        assert_equal(last.pitch, 37)
        assert_equal(last.pos, 33) if RGSS == 3
        assert_equal(last.volume, 22)
      }
      if RGSS == 3
        assert_equal(history, [[:bgm_play, "Audio/BGM/hoge", 22, 37, 0]])
      else
        assert_equal(history, [[:bgm_play, "Audio/BGM/hoge", 22, 37]])
      end
    end

    def test_play_pos
      if RGSS == 2
        assert_raise(ArgumentError) {
          obj = @@klass.new("hoge", 22, 37)
          obj.play(24)
        }
        return
      end
      history = mock_audio {
        @@klass.class_eval("@@last = nil")
        obj = @@klass.new("hoge", 22, 37)
        obj.play(24)
        last = @@klass.last
        assert_not_same(obj, last) if RGSS == 3
        assert_same(obj, last) if RGSS == 2
        assert_equal(last.class, @@klass)
        assert_equal(last.name, "hoge")
        assert_equal(last.pitch, 37)
        assert_equal(last.pos, 33) if RGSS == 3
        assert_equal(last.volume, 22)
      }
      assert_equal(history, [[:bgm_play, "Audio/BGM/hoge", 22, 37, 24]])
    end

    def test_play_empty
      history = mock_audio {
        @@klass.class_eval("@@last = nil")
        obj = @@klass.new("", 22, 37)
        obj.play
        last = @@klass.last
        assert_not_same(obj, last)
        assert_equal(last.class, @@klass)
        assert_equal(last.name, "")
        assert_equal(last.pitch, 100)
        assert_equal(last.pos, 33) if RGSS == 3
        assert_equal(last.volume, 100)
      }
      assert_equal(history, [[:bgm_stop]])
    end

    if RGSS == 3
    def test_replay
      history = mock_audio {
        @@klass.class_eval("@@last = nil")
        obj = @@klass.new("hoge", 22, 37)
        obj.pos = 24
        obj.replay
        last = @@klass.last
        assert_not_same(obj, last)
        assert_equal(last.class, @@klass)
        assert_equal(last.name, "hoge")
        assert_equal(last.pitch, 37)
        assert_equal(last.pos, 33)
        assert_equal(last.volume, 22)
      }
      assert_equal(history, [[:bgm_play, "Audio/BGM/hoge", 22, 37, 24]])
    end
    end # if RGSS == 3

    def test_stop
      history = mock_audio {
        @@klass.class_eval("@@last = nil")
        @@klass.stop
        last = @@klass.last
        assert_equal(last.class, @@klass)
        assert_equal(last.name, "")
        assert_equal(last.pitch, 100)
        # assert_equal(last.pos, 0) if RGSS == 3
        assert_equal(last.volume, 100)
      }
      assert_equal(history, [[:bgm_stop]])
    end

    def test_fade
      history = mock_audio {
        @@klass.class_eval("@@last = nil")
        @@klass.fade(48)
        last = @@klass.last
        assert_equal(last.class, @@klass)
        assert_equal(last.name, "")
        assert_equal(last.pitch, 100)
        # assert_equal(last.pos, 0) if RGSS == 3
        assert_equal(last.volume, 100)
      }
      assert_equal(history, [[:bgm_fade, 48]])
    end
  end
  end # if RGSS >= 2

  if RGSS >= 2
  class TestRPGBGS < Test
    include MockAudio

    @@klass = RPG::BGS
    @@last = RPG::BGS.class_eval("@@last")

    def test_superclass
      assert_equal(@@klass.superclass, RPG::AudioFile)
    end

    def test_constants
      assert_symset_equal(@@klass.constants, [])
    end

    def test_class_variables
      assert_symset_equal(@@klass.class_variables, [:@@last])
    end

    def test_class_methods
      assert_symset_equal(@@klass.methods - Object.methods, [
        :fade, :last, :stop])
    end

    def test_instance_methods
      if RGSS == 3
        assert_symset_equal(owned_instance_methods(@@klass), [
          :play, :pos, :pos=, :replay])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [:play])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [:@name, :@pitch, :@volume])
    end

    def test_new
      obj = @@klass.new
      assert_equal(obj.name, "")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.pos, nil) if RGSS == 3
      assert_equal(obj.volume, 100)

      obj = @@klass.new("hoge")
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.pos, nil) if RGSS == 3
      assert_equal(obj.volume, 100)

      obj = @@klass.new("hoge", 22)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.pos, nil) if RGSS == 3
      assert_equal(obj.volume, 22)

      obj = @@klass.new("hoge", 22, 37)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 37)
      assert_equal(obj.pos, nil) if RGSS == 3
      assert_equal(obj.volume, 22)

      assert_raise(ArgumentError) { @@klass.new(:hoge, :fuga, :piyo, :quux) }
    end

    def test_last
      assert_equal(@@last.class, @@klass)
    end

    def test_play
      history = mock_audio {
        @@klass.class_eval("@@last = nil")
        obj = @@klass.new("hoge", 22, 37)
        obj.play
        last = @@klass.last
        assert_not_same(obj, last) if RGSS == 3
        assert_same(obj, last) if RGSS == 2
        assert_equal(last.class, @@klass)
        assert_equal(last.name, "hoge")
        assert_equal(last.pitch, 37)
        assert_equal(last.pos, 44) if RGSS == 3
        assert_equal(last.volume, 22)
      }
      if RGSS == 3
        assert_equal(history, [[:bgs_play, "Audio/BGS/hoge", 22, 37, 0]])
      else
        assert_equal(history, [[:bgs_play, "Audio/BGS/hoge", 22, 37]])
      end
    end

    def test_play_pos
      if RGSS == 2
        assert_raise(ArgumentError) {
          obj = @@klass.new("hoge", 22, 37)
          obj.play(24)
        }
        return
      end
      history = mock_audio {
        @@klass.class_eval("@@last = nil")
        obj = @@klass.new("hoge", 22, 37)
        obj.play(24)
        last = @@klass.last
        assert_not_same(obj, last) if RGSS == 3
        assert_same(obj, last) if RGSS == 2
        assert_equal(last.class, @@klass)
        assert_equal(last.name, "hoge")
        assert_equal(last.pitch, 37)
        assert_equal(last.pos, 44) if RGSS == 3
        assert_equal(last.volume, 22)
      }
      assert_equal(history, [[:bgs_play, "Audio/BGS/hoge", 22, 37, 24]])
    end

    def test_play_empty
      history = mock_audio {
        @@klass.class_eval("@@last = nil")
        obj = @@klass.new("", 22, 37)
        obj.play
        last = @@klass.last
        assert_not_same(obj, last)
        assert_equal(last.class, @@klass)
        assert_equal(last.name, "")
        assert_equal(last.pitch, 100)
        assert_equal(last.pos, 44) if RGSS == 3
        assert_equal(last.volume, 100)
      }
      assert_equal(history, [[:bgs_stop]])
    end

    if RGSS == 3
    def test_replay
      history = mock_audio {
        @@klass.class_eval("@@last = nil")
        obj = @@klass.new("hoge", 22, 37)
        obj.pos = 24
        obj.replay
        last = @@klass.last
        assert_not_same(obj, last)
        assert_equal(last.class, @@klass)
        assert_equal(last.name, "hoge")
        assert_equal(last.pitch, 37)
        assert_equal(last.pos, 44)
        assert_equal(last.volume, 22)
      }
      assert_equal(history, [[:bgs_play, "Audio/BGS/hoge", 22, 37, 24]])
    end
    end # if RGSS == 3

    def test_stop
      history = mock_audio {
        @@klass.class_eval("@@last = nil")
        @@klass.stop
        last = @@klass.last
        assert_equal(last.class, @@klass)
        assert_equal(last.name, "")
        assert_equal(last.pitch, 100)
        # assert_equal(last.pos, 0) if RGSS == 3
        assert_equal(last.volume, 100)
      }
      assert_equal(history, [[:bgs_stop]])
    end

    def test_fade
      history = mock_audio {
        @@klass.class_eval("@@last = nil")
        @@klass.fade(48)
        last = @@klass.last
        assert_equal(last.class, @@klass)
        assert_equal(last.name, "")
        assert_equal(last.pitch, 100)
        # assert_equal(last.pos, 0) if RGSS == 3
        assert_equal(last.volume, 100)
      }
      assert_equal(history, [[:bgs_fade, 48]])
    end
  end
  end # if RGSS >= 2

  if RGSS >= 2
  class TestRPGME < Test
    include MockAudio

    @@klass = RPG::ME

    def test_superclass
      assert_equal(@@klass.superclass, RPG::AudioFile)
    end

    def test_constants
      assert_symset_equal(@@klass.constants, [])
    end

    def test_class_variables
      assert_symset_equal(@@klass.class_variables, [])
    end

    def test_class_methods
      assert_symset_equal(@@klass.methods - Object.methods, [:fade, :stop])
    end

    def test_instance_methods
      assert_symset_equal(owned_instance_methods(@@klass), [:play])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [:@name, :@pitch, :@volume])
    end

    def test_new
      obj = @@klass.new
      assert_equal(obj.name, "")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 100)

      obj = @@klass.new("hoge")
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 100)

      obj = @@klass.new("hoge", 22)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 22)

      obj = @@klass.new("hoge", 22, 37)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 37)
      assert_equal(obj.volume, 22)

      assert_raise(ArgumentError) { @@klass.new(:hoge, :fuga, :piyo, :quux) }
    end

    def test_play
      history = mock_audio {
        obj = @@klass.new("hoge", 22, 37)
        obj.play
      }
      assert_equal(history, [[:me_play, "Audio/ME/hoge", 22, 37]])
    end

    def test_play_empty
      history = mock_audio {
        obj = @@klass.new("", 22, 37)
        obj.play
      }
      assert_equal(history, [[:me_stop]])
    end

    def test_stop
      history = mock_audio {
        @@klass.stop
      }
      assert_equal(history, [[:me_stop]])
    end

    def test_fade
      history = mock_audio {
        @@klass.fade(48)
      }
      assert_equal(history, [[:me_fade, 48]])
    end
  end
  end # if RGSS >= 2

  if RGSS >= 2
  class TestRPGSE < Test
    include MockAudio

    @@klass = RPG::SE

    def test_superclass
      assert_equal(@@klass.superclass, RPG::AudioFile)
    end

    def test_constants
      assert_symset_equal(@@klass.constants, [])
    end

    def test_class_variables
      assert_symset_equal(@@klass.class_variables, [])
    end

    def test_class_methods
      assert_symset_equal(@@klass.methods - Object.methods, [:stop])
    end

    def test_instance_methods
      assert_symset_equal(owned_instance_methods(@@klass), [:play])
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [:@name, :@pitch, :@volume])
    end

    def test_new
      obj = @@klass.new
      assert_equal(obj.name, "")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 100)

      obj = @@klass.new("hoge")
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 100)

      obj = @@klass.new("hoge", 22)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 22)

      obj = @@klass.new("hoge", 22, 37)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 37)
      assert_equal(obj.volume, 22)

      assert_raise(ArgumentError) { @@klass.new(:hoge, :fuga, :piyo, :quux) }
    end

    def test_play
      history = mock_audio {
        obj = @@klass.new("hoge", 22, 37)
        obj.play
      }
      assert_equal(history, [[:se_play, "Audio/SE/hoge", 22, 37]])
    end

    def test_play_empty
      history = mock_audio {
        obj = @@klass.new("", 22, 37)
        obj.play
      }
      assert_equal(history, [])
    end

    def test_stop
      history = mock_audio {
        @@klass.stop
      }
      assert_equal(history, [[:se_stop]])
    end
  end
  end # if RGSS >= 2
end
