# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestRGSSError < Test
    def test_class
      assert_equal(RGSSError.superclass, StandardError)
      assert_symset_equal(RGSSError.constants, [])
      assert_symset_equal(RGSSError.class_variables, [])
      assert_symset_equal(RGSSError.methods - Object.methods, [:exception])
      assert_symset_equal(owned_instance_methods(RGSSError), [])
    end
  end
end
