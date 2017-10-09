module RGSSTest
  class TestRPGEvent
    include RGSSTest

    @@klass = RPG::Event

    def test_superclass
      assert_equal(@@klass.superclass, Object)
    end

    def test_constants
      assert_symset_equal(@@klass.constants, [:Page])
    end

    def test_class_variables
      assert_symset_equal(@@klass.class_variables, [])
    end

    def test_class_methods
      assert_symset_equal(@@klass.methods - Object.methods, [])
    end

    def test_instance_methods
      assert_symset_equal(owned_instance_methods(@@klass), [
        :id, :id=, :name, :name=, :pages, :pages=, :x, :x=, :y, :y=])
    end

    def test_instance_variables
      obj = @@klass.new(7, 6)
      assert_symset_equal(obj.instance_variables, [
        :@id, :@name, :@pages, :@x, :@y])
    end


    def test_new
      obj = @@klass.new(7, 6)

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      assert_raise(ArgumentError) { @@klass.new(:hoge, :fuga, :piyo) }
      assert_equal(obj.id, 0)
      assert_equal(obj.name, "")
      assert_equal(obj.pages.size, 1)
      assert_equal(obj.pages[0].class, RPG::Event::Page)
      assert_equal(obj.x, 7)
      assert_equal(obj.y, 6)
    end
  end

  run_test(TestRPGEvent)
end
