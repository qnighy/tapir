module RGSSTest
  class TestRGSSError
    include RGSSTest

    def test_class
      assert_equal(RGSSError.superclass, StandardError)
      assert_symset_equal(RGSSError.constants, [])
      assert_symset_equal(RGSSError.class_variables, [])
      assert_symset_equal(RGSSError.methods - Object.methods, [:exception])
      assert_symset_equal(owned_instance_methods(RGSSError), [])
    end
  end

  run_test(TestRGSSError)
end
