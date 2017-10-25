# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

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
