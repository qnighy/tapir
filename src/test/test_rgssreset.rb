module RGSSTest
  class TestRGSSReset
    include RGSSTest

    def test_class
      # TODO: in RGSS1/2, hidden class Reset is generated on-demand.
      RGSSTest::RGSS == 3 or return
      assert_equal(RGSSReset.superclass, Exception)
      assert_symset_equal(RGSSReset.constants, [])
      assert_symset_equal(RGSSReset.class_variables, [])
      assert_symset_equal(RGSSReset.methods - Object.methods, [:exception])
      assert_symset_equal(owned_instance_methods(RGSSReset), [])
    end
  end

  run_test(TestRGSSReset)
end
