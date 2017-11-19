# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestRPGCommonEvent < Test
    @@klass = RPG::CommonEvent

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
          :autorun?, :id, :id=, :list, :list=, :name, :name=, :parallel?,
          :switch_id, :switch_id=, :trigger, :trigger=])
      else
        assert_symset_equal(owned_instance_methods(@@klass), [
          :id, :id=, :list, :list=, :name, :name=, :switch_id, :switch_id=,
          :trigger, :trigger=])
      end
    end

    def test_instance_variables
      obj = @@klass.new
      assert_symset_equal(obj.instance_variables, [
        :@id, :@list, :@name, :@switch_id, :@trigger])
    end

    def test_new
      obj = @@klass.new

      assert_raise(ArgumentError) { @@klass.new(:hoge) }
      assert_equal(obj.id, 0)
      assert_equal(obj.list.size, 1)
      assert_equal(obj.list[0].class, RPG::EventCommand)
      assert_equal(obj.list[0].code, 0)
      assert_equal(obj.list[0].indent, 0)
      assert_equal(obj.list[0].parameters, [])
      assert_equal(obj.name, "")
      assert_equal(obj.switch_id, 1)
      assert_equal(obj.trigger, 0)
    end

    if RGSS == 3
    def test_autorun_p
      obj = @@klass.new
      obj.trigger = 0
      assert_equal(obj.autorun?, false)
      obj.trigger = 1
      assert_equal(obj.autorun?, true)
      obj.trigger = 2
      assert_equal(obj.autorun?, false)
    end
    end # if RGSS == 3

    if RGSS == 3
    def test_parallel_p
      obj = @@klass.new
      obj.trigger = 0
      assert_equal(obj.parallel?, false)
      obj.trigger = 1
      assert_equal(obj.parallel?, false)
      obj.trigger = 2
      assert_equal(obj.parallel?, true)
    end
    end # if RGSS == 3
  end
end
