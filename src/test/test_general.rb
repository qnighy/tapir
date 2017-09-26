module RGSSTest
  class TestGeneral
    include RGSSTest

    def test_debug
      $stderr.puts $DEBUG.inspect
      $stderr.puts $TEST.inspect
      $stderr.puts $BTEST.inspect
      if RGSSTest::RGSS == 1
        assert_equal($DEBUG, false)
        assert_equal($TEST, nil)
        assert_equal($BTEST, false)
      else
        assert_equal($DEBUG, false)
        assert_equal($TEST, false)
        assert_equal($BTEST, false)
      end
    end
  end

  run_test(TestGeneral)
end
