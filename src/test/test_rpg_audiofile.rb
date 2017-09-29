module RGSSTest
  class TestRPGAudioFile
    include RGSSTest

    def test_rpg_audiofile
      audiofile = RPG::AudioFile.new

      assert_equal(RPG::AudioFile.superclass, Object)
      assert_symset_equal(RPG::AudioFile.constants, [])
      assert_symset_equal(RPG::AudioFile.class_variables, [])
      assert_symset_equal(RPG::AudioFile.methods - Object.methods, [])
      assert_symset_equal(owned_instance_methods(RPG::AudioFile), [
        :name, :name=, :pitch, :pitch=, :volume, :volume=])
      assert_symset_equal(audiofile.instance_variables, [
        :@name, :@pitch, :@volume])
      assert_raise(ArgumentError) {
        RPG::AudioFile.new(:hoge, :fuga, :piyo, :quux)
      }
      assert_equal(audiofile.name, "")
      assert_equal(audiofile.pitch, 100)
      assert_equal(audiofile.volume, 100)

      audiofile = RPG::AudioFile.new("hoge")
      assert_equal(audiofile.name, "hoge")
      assert_equal(audiofile.pitch, 100)
      assert_equal(audiofile.volume, 100)

      audiofile = RPG::AudioFile.new("hoge", 137)
      assert_equal(audiofile.name, "hoge")
      assert_equal(audiofile.pitch, 100)
      assert_equal(audiofile.volume, 137)

      audiofile = RPG::AudioFile.new("hoge", 137, 227)
      assert_equal(audiofile.name, "hoge")
      assert_equal(audiofile.pitch, 227)
      assert_equal(audiofile.volume, 137)
    end

    def test_rpg_bgm
      RGSSTest::RGSS >= 2 or return
      obj = RPG::BGM.new

      assert_equal(RPG::BGM.superclass, RPG::AudioFile)
      assert_symset_equal(RPG::BGM.constants, [])
      assert_symset_equal(RPG::BGM.class_variables, [:@@last])
      assert_symset_equal(RPG::BGM.methods - Object.methods, [
        :fade, :last, :stop])
      if RGSSTest::RGSS == 3
        assert_symset_equal(owned_instance_methods(RPG::BGM), [
          :play, :pos, :pos=, :replay])
      else
        assert_symset_equal(owned_instance_methods(RPG::BGM), [:play])
      end
      assert_symset_equal(obj.instance_variables, [:@name, :@pitch, :@volume])
      assert_raise(ArgumentError) { RPG::BGM.new(:hoge, :fuga, :piyo, :quux) }
      assert_equal(obj.name, "")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.pos, nil) if RGSSTest::RGSS == 3
      assert_equal(obj.volume, 100)

      obj = RPG::BGM.new("hoge")
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.pos, nil) if RGSSTest::RGSS == 3
      assert_equal(obj.volume, 100)

      obj = RPG::BGM.new("hoge", 22)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.pos, nil) if RGSSTest::RGSS == 3
      assert_equal(obj.volume, 22)

      obj = RPG::BGM.new("hoge", 22, 37)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 37)
      assert_equal(obj.pos, nil) if RGSSTest::RGSS == 3
      assert_equal(obj.volume, 22)

      last = RPG::BGM.last
      assert_equal(last.class, RPG::BGM)

      history = mock_audio {
        obj = RPG::BGM.new
        obj.play
        assert_not_same(obj, RPG::BGM.last)
      }
      assert_equal(history, [[:bgm_stop]])

      history = mock_audio {
        obj = RPG::BGM.new("hoge", 22, 37)
        obj.play
        last = RPG::BGM.last
        assert_not_same(obj, last) if RGSSTest::RGSS == 3
        assert_same(obj, last) if RGSSTest::RGSS == 2
        assert_equal(last.class, RPG::BGM)
        assert_equal(last.name, "hoge")
        assert_equal(last.pitch, 37)
        assert_equal(last.pos, 33) if RGSSTest::RGSS == 3
        assert_equal(last.volume, 22)

        RPG::BGM.stop
        last = RPG::BGM.last
        assert_equal(last.class, RPG::BGM)
        assert_equal(last.name, "")
        assert_equal(last.pitch, 100)
        # assert_equal(last.pos, 0) if RGSSTest::RGSS == 3
        assert_equal(last.volume, 100)

        obj = RPG::BGM.new("hoge", 22, 37)
        obj.play
        RPG::BGM.fade(48)
        last = RPG::BGM.last
        assert_equal(last.class, RPG::BGM)
        assert_equal(last.name, "")
        assert_equal(last.pitch, 100)
        # assert_equal(last.pos, 0) if RGSSTest::RGSS == 3
        assert_equal(last.volume, 100)
      }
      if RGSSTest::RGSS == 3
        assert_equal(history, [
          [:bgm_play, "Audio/BGM/hoge", 22, 37, 0],
          [:bgm_stop],
          [:bgm_play, "Audio/BGM/hoge", 22, 37, 0],
          [:bgm_fade, 48]])
      else
        assert_equal(history, [
          [:bgm_play, "Audio/BGM/hoge", 22, 37],
          [:bgm_stop],
          [:bgm_play, "Audio/BGM/hoge", 22, 37],
          [:bgm_fade, 48]])
      end

      if RGSSTest::RGSS == 3
        history = mock_audio {
          obj = RPG::BGM.new("hoge", 22, 37)
          obj.play(24)
        }
        assert_equal(history, [[:bgm_play, "Audio/BGM/hoge", 22, 37, 24]])
      end
    end

    def test_rpg_bgs
      RGSSTest::RGSS >= 2 or return
      obj = RPG::BGS.new

      assert_equal(RPG::BGS.superclass, RPG::AudioFile)
      assert_equal(RPG::BGS.constants, [])
      assert_symset_equal(RPG::BGS.class_variables, [:@@last])
      assert_symset_equal(RPG::BGS.methods - Object.methods, [
        :fade, :last, :stop])
      if RGSSTest::RGSS == 3
        assert_symset_equal(owned_instance_methods(RPG::BGS), [
          :play, :pos, :pos=, :replay])
      else
        assert_symset_equal(owned_instance_methods(RPG::BGS), [:play])
      end
      assert_symset_equal(obj.instance_variables, [:@name, :@pitch, :@volume])
      assert_raise(ArgumentError) { RPG::BGS.new(:hoge, :fuga, :piyo, :quux) }
      assert_equal(obj.name, "")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.pos, nil) if RGSSTest::RGSS == 3
      assert_equal(obj.volume, 100)

      obj = RPG::BGS.new("hoge")
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.pos, nil) if RGSSTest::RGSS == 3
      assert_equal(obj.volume, 100)

      obj = RPG::BGS.new("hoge", 22)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.pos, nil) if RGSSTest::RGSS == 3
      assert_equal(obj.volume, 22)

      obj = RPG::BGS.new("hoge", 22, 37)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 37)
      assert_equal(obj.pos, nil) if RGSSTest::RGSS == 3
      assert_equal(obj.volume, 22)

      last = RPG::BGS.last
      assert_equal(last.class, RPG::BGS)

      history = mock_audio {
        obj = RPG::BGS.new
        obj.play
        assert_not_same(obj, RPG::BGS.last)
      }
      assert_equal(history, [[:bgs_stop]])

      history = mock_audio {
        obj = RPG::BGS.new("hoge", 22, 37)
        obj.play
        last = RPG::BGS.last
        assert_not_same(obj, last) if RGSSTest::RGSS == 3
        assert_same(obj, last) if RGSSTest::RGSS == 2
        assert_equal(last.class, RPG::BGS)
        assert_equal(last.name, "hoge")
        assert_equal(last.pitch, 37)
        assert_equal(last.pos, 44) if RGSSTest::RGSS == 3
        assert_equal(last.volume, 22)

        RPG::BGS.stop
        last = RPG::BGS.last
        assert_equal(last.class, RPG::BGS)
        assert_equal(last.name, "")
        assert_equal(last.pitch, 100)
        # assert_equal(last.pos, 0) if RGSSTest::RGSS == 3
        assert_equal(last.volume, 100)

        obj = RPG::BGS.new("hoge", 22, 37)
        obj.play
        RPG::BGS.fade(48)
        last = RPG::BGS.last
        assert_equal(last.class, RPG::BGS)
        assert_equal(last.name, "")
        assert_equal(last.pitch, 100)
        # assert_equal(last.pos, 0) if RGSSTest::RGSS == 3
        assert_equal(last.volume, 100)
      }
      if RGSSTest::RGSS == 3
        assert_equal(history, [
          [:bgs_play, "Audio/BGS/hoge", 22, 37, 0],
          [:bgs_stop],
          [:bgs_play, "Audio/BGS/hoge", 22, 37, 0],
          [:bgs_fade, 48]])
      else
        assert_equal(history, [
          [:bgs_play, "Audio/BGS/hoge", 22, 37],
          [:bgs_stop],
          [:bgs_play, "Audio/BGS/hoge", 22, 37],
          [:bgs_fade, 48]])
      end

      if RGSSTest::RGSS == 3
        history = mock_audio {
          obj = RPG::BGS.new("hoge", 22, 37)
          obj.play(24)
        }
        assert_equal(history, [[:bgs_play, "Audio/BGS/hoge", 22, 37, 24]])
      end
    end

    def test_rpg_me
      RGSSTest::RGSS >= 2 or return
      obj = RPG::ME.new

      assert_equal(RPG::ME.superclass, RPG::AudioFile)
      assert_symset_equal(RPG::ME.constants, [])
      assert_symset_equal(RPG::ME.class_variables, [])
      assert_symset_equal(RPG::ME.methods - Object.methods, [:fade, :stop])
      assert_symset_equal(owned_instance_methods(RPG::ME), [:play])
      assert_symset_equal(obj.instance_variables, [:@name, :@pitch, :@volume])
      assert_raise(ArgumentError) { RPG::ME.new(:hoge, :fuga, :piyo, :quux) }
      assert_equal(obj.name, "")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 100)

      obj = RPG::ME.new("hoge")
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 100)

      obj = RPG::ME.new("hoge", 22)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 22)

      obj = RPG::ME.new("hoge", 22, 37)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 37)
      assert_equal(obj.volume, 22)

      history = mock_audio {
        obj = RPG::ME.new
        obj.play
      }
      assert_equal(history, [[:me_stop]])

      history = mock_audio {
        obj = RPG::ME.new("hoge", 22, 37)
        obj.play

        RPG::ME.stop

        obj = RPG::ME.new("hoge", 22, 37)
        obj.play
        RPG::ME.fade(48)
      }
      assert_equal(history, [
        [:me_play, "Audio/ME/hoge", 22, 37],
        [:me_stop],
        [:me_play, "Audio/ME/hoge", 22, 37],
        [:me_fade, 48]])
    end

    def test_rpg_se
      RGSSTest::RGSS >= 2 or return
      obj = RPG::SE.new

      assert_equal(RPG::SE.superclass, RPG::AudioFile)
      assert_symset_equal(RPG::SE.constants, [])
      assert_symset_equal(RPG::SE.class_variables, [])
      assert_symset_equal(RPG::SE.methods - Object.methods, [:stop])
      assert_symset_equal(owned_instance_methods(RPG::SE), [:play])
      assert_symset_equal(obj.instance_variables, [:@name, :@pitch, :@volume])
      assert_raise(ArgumentError) { RPG::SE.new(:hoge, :fuga, :piyo, :quux) }
      assert_equal(obj.name, "")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 100)

      obj = RPG::SE.new("hoge")
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 100)

      obj = RPG::SE.new("hoge", 22)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 100)
      assert_equal(obj.volume, 22)

      obj = RPG::SE.new("hoge", 22, 37)
      assert_equal(obj.name, "hoge")
      assert_equal(obj.pitch, 37)
      assert_equal(obj.volume, 22)

      history = mock_audio {
        obj = RPG::SE.new
        obj.play
      }
      assert_equal(history, [])

      history = mock_audio {
        obj = RPG::SE.new("hoge", 22, 37)
        obj.play

        RPG::SE.stop
      }
      assert_equal(history, [
        [:se_play, "Audio/SE/hoge", 22, 37],
        [:se_stop]])
    end

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

  run_test(TestRPGAudioFile)
end
