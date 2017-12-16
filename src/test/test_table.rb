# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestTable < Test
    @@klass = Table

    def new_unchecked(dim, xsize, ysize, zsize, size, data)
      Table._load([dim, xsize, ysize, zsize, size, *data].pack("l<l<l<l<l<s*<"))
    end

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
      assert_symset_equal(@@klass.methods - Object.methods, [:_load])
    end

    def test_instance_methods
      assert_symset_equal(owned_instance_methods(@@klass), [
        :[], :[]=, :_dump, :resize, :xsize, :ysize, :zsize])
    end

    def test_instance_variables
      obj = @@klass.new(10)
      assert_symset_equal(obj.instance_variables, [])

      obj = @@klass.new(10, 10)
      assert_symset_equal(obj.instance_variables, [])

      obj = @@klass.new(10, 10, 10)
      assert_symset_equal(obj.instance_variables, [])
    end

    def test_new
      obj = @@klass.new(5.5)
      assert_equal(obj.xsize, 5)
      assert_equal(obj.ysize, 1)
      assert_equal(obj.zsize, 1)
      assert_equal(obj[0], 0)
      assert_equal(obj[4], 0)

      obj = @@klass.new(5, 6.5)
      assert_equal(obj.xsize, 5)
      assert_equal(obj.ysize, 6)
      assert_equal(obj.zsize, 1)
      assert_equal(obj[0, 0], 0)
      assert_equal(obj[4, 5], 0)

      obj = @@klass.new(5, 6, 7.6)
      assert_equal(obj.xsize, 5)
      assert_equal(obj.ysize, 6)
      assert_equal(obj.zsize, 7)
      assert_equal(obj[0, 0, 0], 0)
      assert_equal(obj[4, 5, 6], 0)
    end

    def test_new_large
      assert_raise(RangeError) { @@klass.new(1 << 31) }
      assert_raise(RangeError) { @@klass.new(-(1 << 31) - 1) }

      # # Runtime Error
      # obj = @@klass.new((1 << 30) - 100)

      # # Runtime Error
      # # Note: 65536 * 65536 * 2 == 0 in int32_t
      # obj = @@klass.new(65536, 65536)
      # $stderr.puts obj[60000, 60000]
    end

    def test_new_negative
      obj = @@klass.new(-12)
      assert_equal([obj.xsize, obj.ysize, obj.zsize], [0, 1, 1])

      obj = @@klass.new(-12, 10)
      assert_equal([obj.xsize, obj.ysize, obj.zsize], [0, 10, 1])

      obj = @@klass.new(12, -10)
      assert_equal([obj.xsize, obj.ysize, obj.zsize], [12, 0, 1])

      obj = @@klass.new(-12, 10, 8)
      assert_equal([obj.xsize, obj.ysize, obj.zsize], [0, 10, 8])

      obj = @@klass.new(12, -10, 8)
      assert_equal([obj.xsize, obj.ysize, obj.zsize], [12, 0, 8])

      obj = @@klass.new(12, 10, -8)
      assert_equal([obj.xsize, obj.ysize, obj.zsize], [12, 10, 0])
    end

    def test_new_argerror
      assert_raise(ArgumentError) { @@klass.new }
      assert_raise(ArgumentError) { @@klass.new(1, 1, 1, 1) }
      assert_raise(ArgumentError) { @@klass.new(1, 1, 1, 1, 1) }
    end

    def test_new_typeerror
      assert_raise(TypeError) { @@klass.new("1") }
      assert_raise(TypeError) { @@klass.new("1", 1) }
      assert_raise(TypeError) { @@klass.new(1, "1") }
      assert_raise(TypeError) { @@klass.new("1", 1, 1) }
      assert_raise(TypeError) { @@klass.new(1, "1", 1) }
      assert_raise(TypeError) { @@klass.new(1, 1, "1") }
    end

    def test_aset
      obj = @@klass.new(10)
      obj[5.3] = 13
      assert_equal(obj[5], 13)

      obj = @@klass.new(10, 8)
      obj[5, 7.1] = -3
      assert_equal(obj[5, 7], -3)

      obj = @@klass.new(10, 8, 6)
      obj[5, 7, -0.5] = 100
      assert_equal(obj[5, 7, 0], 100)
    end

    def test_aset_oob
      obj = @@klass.new(3)
      obj[-1] = 3
      obj[3] = 7
      assert_equal([obj[0], obj[1], obj[2]], [0, 0, 0])

      obj = @@klass.new(2, 2)
      obj[-1, 0] = 1
      obj[2, 0] = 1
      obj[0, -1] = 1
      obj[0, 2] = 1
      assert_equal([obj[0, 0], obj[1, 0], obj[0, 1], obj[1, 1]], [0, 0, 0, 0])

      obj = @@klass.new(2, 2, 2)
      obj[-1, 0, 0] = 1
      obj[2, 0, 0] = 1
      obj[0, -1, 0] = 1
      obj[0, 2, 0] = 1
      obj[0, 0, -1] = 1
      obj[0, 0, 2] = 1
      assert_equal(
        [obj[0, 0, 0], obj[1, 0, 0], obj[0, 1, 0], obj[1, 1, 0],
         obj[0, 0, 1], obj[1, 0, 1], obj[0, 1, 1], obj[1, 1, 1]],
        [0, 0, 0, 0, 0, 0, 0, 0])
    end

    def test_aset_oob_2
      obj = @@klass.new(3)
      obj[-1] = 3
      obj[3] = 7
      assert_equal(obj[-1], nil)
      assert_equal(obj[3], nil)

      obj = @@klass.new(2, 2)
      obj[-1, 0] = 1
      obj[2, 0] = 1
      obj[0, -1] = 1
      obj[0, 2] = 1
      assert_equal(obj[-1, 0], nil)
      assert_equal(obj[2, 0], nil)
      assert_equal(obj[0, -1], nil)
      assert_equal(obj[0, 2], nil)

      obj = @@klass.new(2, 2, 2)
      obj[-1, 0, 0] = 1
      obj[2, 0, 0] = 1
      obj[0, -1, 0] = 1
      obj[0, 2, 0] = 1
      obj[0, 0, -1] = 1
      obj[0, 0, 2] = 1
      assert_equal(obj[-1, 0, 0], nil)
      assert_equal(obj[2, 0, 0], nil)
      assert_equal(obj[0, -1, 0], nil)
      assert_equal(obj[0, 2, 0], nil)
      assert_equal(obj[0, 0, -1], nil)
      assert_equal(obj[0, 0, 2], nil)
    end

    def test_aset_large_index
      obj = @@klass.new(10)
      obj[(1 << 31) - 1] = 0
      obj[-(1 << 31)] = 0
      assert_raise(RangeError) { obj[1 << 31] = 0 }
      assert_raise(RangeError) { obj[-(1 << 31) - 1] = 0 }

      obj = @@klass.new(10, 10)
      obj[(1 << 31) - 1, 0] = 0
      obj[-(1 << 31), 0] = 0
      obj[0, (1 << 31) - 1] = 0
      obj[0, -(1 << 31)] = 0
      assert_raise(RangeError) { obj[1 << 31, 0] = 0 }
      assert_raise(RangeError) { obj[-(1 << 31) - 1, 0] = 0 }
      assert_raise(RangeError) { obj[0, 1 << 31] = 0 }
      assert_raise(RangeError) { obj[0, -(1 << 31) - 1] = 0 }

      obj = @@klass.new(10, 10, 10)
      obj[(1 << 31) - 1, 0, 0] = 0
      obj[-(1 << 31), 0, 0] = 0
      obj[0, (1 << 31) - 1, 0] = 0
      obj[0, -(1 << 31), 0] = 0
      obj[0, 0, (1 << 31) - 1] = 0
      obj[0, 0, -(1 << 31)] = 0
      assert_raise(RangeError) { obj[1 << 31, 0, 0] = 0 }
      assert_raise(RangeError) { obj[-(1 << 31) - 1, 0, 0] = 0 }
      assert_raise(RangeError) { obj[0, 1 << 31, 0] = 0 }
      assert_raise(RangeError) { obj[0, -(1 << 31) - 1, 0] = 0 }
      assert_raise(RangeError) { obj[0, 0, 1 << 31] = 0 }
      assert_raise(RangeError) { obj[0, 0, -(1 << 31) - 1] = 0 }
    end

    def test_aset_wrap
      obj = @@klass.new(10)
      obj[0] = 32767
      obj[1] = 32768
      obj[2] = 1000000
      obj[3] = -32768
      obj[4] = -32769
      obj[5] = -123456
      assert_equal(obj[0], 32767)
      assert_equal(obj[1], -32768)
      assert_equal(obj[2], 16960)
      assert_equal(obj[3], -32768)
      assert_equal(obj[4], 32767)
      assert_equal(obj[5], 7616)
    end

    def test_aset_large
      obj = @@klass.new(10)
      obj[0] = (1 << 31) - 1
      obj[0] = -(1 << 31)
      assert_raise(RangeError) { obj[0] = 1 << 31 }
      assert_raise(RangeError) { obj[0] = -(1 << 31) - 1 }
    end

    def test_aset_retval
      obj = @@klass.new(10)
      assert_equal(obj.send(:[]=, 0, 1.5), 1)
      assert_equal(obj.send(:[]=, 0, 70000), 4464)
      assert_equal(obj.send(:[]=, -1, 1.5), nil)

      obj = @@klass.new(10, 10)
      assert_equal(obj.send(:[]=, 0, 0, 2.5), 2)
      assert_equal(obj.send(:[]=, 0, 0, -40000), 25536)
      assert_equal(obj.send(:[]=, 0, -1, 2.5), nil)

      obj = @@klass.new(10, 10, 10)
      assert_equal(obj.send(:[]=, 0, 0, 0, 3.5), 3)
      assert_equal(obj.send(:[]=, 0, 0, 100000000), -7936)
      assert_equal(obj.send(:[]=, 0, 0, -1, 3.5), nil)
    end

    def test_aset_lessarg
      obj = @@klass.new(10)
      obj.send(:[]=, 3)
      assert_equal(obj[0], 3)

      obj = @@klass.new(10, 10)
      obj.send(:[]=, 3, 4)
      assert_equal(obj[3, 0], 4)

      obj = @@klass.new(10, 10, 10)
      obj.send(:[]=, 3, 4, 5)
      assert_equal(obj[3, 4, 0], 5)
    end

    def test_aset_argerror
      obj = @@klass.new(10)
      assert_raise(ArgumentError) { obj.send(:[]=) }
      assert_raise(ArgumentError) { obj.send(:[]=, 0, 0, 0) }
      assert_raise(ArgumentError) { obj.send(:[]=, 0, 0, 0, 0) }
      assert_raise(ArgumentError) { obj.send(:[]=, 0, 0, 0, 0, 0) }

      obj = @@klass.new(10, 10)
      assert_raise(ArgumentError) { obj.send(:[]=) }
      assert_raise(ArgumentError) { obj.send(:[]=, 0) }
      assert_raise(ArgumentError) { obj.send(:[]=, 0, 0, 0, 0) }
      assert_raise(ArgumentError) { obj.send(:[]=, 0, 0, 0, 0, 0) }

      obj = @@klass.new(10, 10, 10)
      assert_raise(ArgumentError) { obj.send(:[]=) }
      assert_raise(ArgumentError) { obj.send(:[]=, 0) }
      assert_raise(ArgumentError) { obj.send(:[]=, 0, 0) }
      assert_raise(ArgumentError) { obj.send(:[]=, 0, 0, 0, 0, 0) }
    end

    def test_aset_typeerror
      obj = @@klass.new(10)
      assert_raise(TypeError) { obj["0"] = 0 }
      assert_raise(TypeError) { obj[0] = "0" }

      obj = @@klass.new(10, 10)
      assert_raise(TypeError) { obj["0", 0] = 0 }
      assert_raise(TypeError) { obj[0, "0"] = 0 }
      assert_raise(TypeError) { obj[0, 0] = "0" }

      obj = @@klass.new(10, 10, 10)
      assert_raise(TypeError) { obj["0", 0, 0] = 0 }
      assert_raise(TypeError) { obj[0, "0", 0] = 0 }
      assert_raise(TypeError) { obj[0, 0, "0"] = 0 }
      assert_raise(TypeError) { obj[0, 0, 0] = "0" }
    end

    def test_aref_oob
      obj = @@klass.new(3)
      assert_equal(obj[-1], nil)
      assert_equal(obj[3], nil)

      obj = @@klass.new(2, 2)
      assert_equal(obj[-1, 0], nil)
      assert_equal(obj[2, 0], nil)
      assert_equal(obj[0, -1], nil)
      assert_equal(obj[0, 2], nil)

      obj = @@klass.new(2, 2, 2)
      assert_equal(obj[-1, 0, 0], nil)
      assert_equal(obj[2, 0, 0], nil)
      assert_equal(obj[0, -1, 0], nil)
      assert_equal(obj[0, 2, 0], nil)
      assert_equal(obj[0, 0, -1], nil)
      assert_equal(obj[0, 0, 2], nil)
    end

    def test_aref_large_index
      obj = @@klass.new(10)
      obj[(1 << 31) - 1]
      obj[-(1 << 31)]
      assert_raise(RangeError) { obj[1 << 31] }
      assert_raise(RangeError) { obj[-(1 << 31) - 1] }

      obj = @@klass.new(10, 10)
      obj[(1 << 31) - 1, 0]
      obj[-(1 << 31), 0]
      obj[0, (1 << 31) - 1]
      obj[0, -(1 << 31)]
      assert_raise(RangeError) { obj[1 << 31, 0] }
      assert_raise(RangeError) { obj[-(1 << 31) - 1, 0] }
      assert_raise(RangeError) { obj[0, 1 << 31] }
      assert_raise(RangeError) { obj[0, -(1 << 31) - 1] }

      obj = @@klass.new(10, 10, 10)
      obj[(1 << 31) - 1, 0, 0]
      obj[-(1 << 31), 0, 0]
      obj[0, (1 << 31) - 1, 0]
      obj[0, -(1 << 31), 0]
      obj[0, 0, (1 << 31) - 1]
      obj[0, 0, -(1 << 31)]
      assert_raise(RangeError) { obj[1 << 31, 0, 0] }
      assert_raise(RangeError) { obj[-(1 << 31) - 1, 0, 0] }
      assert_raise(RangeError) { obj[0, 1 << 31, 0] }
      assert_raise(RangeError) { obj[0, -(1 << 31) - 1, 0] }
      assert_raise(RangeError) { obj[0, 0, 1 << 31] }
      assert_raise(RangeError) { obj[0, 0, -(1 << 31) - 1] }
    end

    def test_aref_argerror
      obj = @@klass.new(10)
      assert_raise(ArgumentError) { obj.send(:[]) }
      assert_raise(ArgumentError) { obj.send(:[], 0, 0) }
      assert_raise(ArgumentError) { obj.send(:[], 0, 0, 0) }
      assert_raise(ArgumentError) { obj.send(:[], 0, 0, 0, 0) }
      assert_raise(ArgumentError) { obj.send(:[], 0, 0, 0, 0, 0) }

      obj = @@klass.new(10, 10)
      assert_raise(ArgumentError) { obj.send(:[]) }
      assert_raise(ArgumentError) { obj.send(:[], 0) }
      assert_raise(ArgumentError) { obj.send(:[], 0, 0, 0) }
      assert_raise(ArgumentError) { obj.send(:[], 0, 0, 0, 0) }
      assert_raise(ArgumentError) { obj.send(:[], 0, 0, 0, 0, 0) }

      obj = @@klass.new(10, 10, 10)
      assert_raise(ArgumentError) { obj.send(:[]) }
      assert_raise(ArgumentError) { obj.send(:[], 0) }
      assert_raise(ArgumentError) { obj.send(:[], 0, 0) }
      assert_raise(ArgumentError) { obj.send(:[], 0, 0, 0, 0) }
      assert_raise(ArgumentError) { obj.send(:[], 0, 0, 0, 0, 0) }
    end

    def test_aref_typeerror
      obj = @@klass.new(10)
      assert_raise(TypeError) { obj["0"] }

      obj = @@klass.new(10, 10)
      assert_raise(TypeError) { obj["0", 0] }
      assert_raise(TypeError) { obj[0, "0"] }

      obj = @@klass.new(10, 10, 10)
      assert_raise(TypeError) { obj["0", 0, 0] }
      assert_raise(TypeError) { obj[0, "0", 0] }
      assert_raise(TypeError) { obj[0, 0, "0"] }
    end

    def test_dup
      obj = @@klass.new(10)
      obj[3] = 7
      obj2 = obj.dup
      obj[3] = 8
      assert_equal(obj2[3], 7)
    end

    def test_load_1
      obj = new_unchecked(1, 10, 1, 1, 10,
                          [10, 11, 12, 13, 14, 15, 16, 17, 18, 19])
      assert_equal(obj.xsize, 10)
      assert_equal(obj.ysize, 1)
      assert_equal(obj.zsize, 1)
      assert_equal(obj[0], 10)
      assert_equal(obj[9], 19)

      obj = new_unchecked(2, 4, 3, 1, 12,
                          [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21])
      assert_equal(obj.xsize, 4)
      assert_equal(obj.ysize, 3)
      assert_equal(obj.zsize, 1)
      assert_equal(obj[0, 0], 10)
      assert_equal(obj[3, 2], 21)

      obj = new_unchecked(3, 1, 2, 4, 8,
                          [10, 11, 12, 13, 14, 15, 16, 17])
      assert_equal(obj.xsize, 1)
      assert_equal(obj.ysize, 2)
      assert_equal(obj.zsize, 4)
      assert_equal(obj[0, 0, 0], 10)
      assert_equal(obj[0, 1, 3], 17)
    end

    def test_load_2
      obj = new_unchecked(1, 2, 1, 1, 2, [-32768, 32767])
      assert_equal(obj[0], -32768)
      assert_equal(obj[1], 32767)
    end

    def test_dump_1
      obj = @@klass.new(10)
      obj[0] = 30
      obj[1] = 31
      obj[2] = 32
      obj[3] = 33
      obj[4] = 34
      obj[5] = 35
      obj[6] = 36
      obj[7] = 37
      obj[8] = 38
      obj[9] = 39
      expected = "\x01\x00\x00\x00\x0A\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x0A\x00\x00\x00\x1E\x00\x1F\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00"
      expected.force_encoding("ASCII-8BIT") rescue nil
      assert_equal(obj._dump(0), expected)

      obj = @@klass.new(3, 3)
      obj[0, 0] = 30
      obj[1, 0] = 31
      obj[2, 0] = 32
      obj[0, 1] = 33
      obj[1, 1] = 34
      obj[2, 1] = 35
      obj[0, 2] = 36
      obj[1, 2] = 37
      obj[2, 2] = 38
      expected = "\x02\x00\x00\x00\x03\x00\x00\x00\x03\x00\x00\x00\x01\x00\x00\x00\x09\x00\x00\x00\x1E\x00\x1F\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00"
      expected.force_encoding("ASCII-8BIT") rescue nil
      assert_equal(obj._dump(0), expected)

      obj = @@klass.new(2, 2, 2)
      obj[0, 0, 0] = 30
      obj[1, 0, 0] = 31
      obj[0, 1, 0] = 32
      obj[1, 1, 0] = 33
      obj[0, 0, 1] = 34
      obj[1, 0, 1] = 35
      obj[0, 1, 1] = 36
      obj[1, 1, 1] = 37
      expected = "\x03\x00\x00\x00\x02\x00\x00\x00\x02\x00\x00\x00\x02\x00\x00\x00\x08\x00\x00\x00\x1E\x00\x1F\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x25\x00"
      expected.force_encoding("ASCII-8BIT") rescue nil
      assert_equal(obj._dump(0), expected)
    end

    def test_resize
      obj = @@klass.new(15)
      obj.resize(5.5)
      assert_equal(obj.xsize, 5)
      assert_equal(obj.ysize, 1)
      assert_equal(obj.zsize, 1)
      assert_equal(obj[0], 0)
      assert_equal(obj[4], 0)

      obj = @@klass.new(15, 15)
      obj.resize(5, 6.5)
      assert_equal(obj.xsize, 5)
      assert_equal(obj.ysize, 6)
      assert_equal(obj.zsize, 1)
      assert_equal(obj[0, 0], 0)
      assert_equal(obj[4, 5], 0)

      obj = @@klass.new(15, 15, 15)
      obj.resize(5, 6, 7.6)
      assert_equal(obj.xsize, 5)
      assert_equal(obj.ysize, 6)
      assert_equal(obj.zsize, 7)
      assert_equal(obj[0, 0, 0], 0)
      assert_equal(obj[4, 5, 6], 0)
    end

    def test_resize_shrink
      obj = @@klass.new(10)
      10.times {|i| obj[i] = i + 1000 }
      obj.resize(3)
      assert_equal(obj.xsize, 3)
      assert_equal(obj.ysize, 1)
      assert_equal(obj.zsize, 1)
      assert_equal(obj[0], 1000)
      assert_equal(obj[1], 1001)
      assert_equal(obj[2], 1002)

      obj = @@klass.new(10, 10)
      10.times do|i|
        10.times do|j|
          obj[i, j] = i + j * 10 + 1000
        end
      end
      obj.resize(3, 3)
      assert_equal(obj.xsize, 3)
      assert_equal(obj.ysize, 3)
      assert_equal(obj.zsize, 1)
      assert_equal(obj[0, 0], 1000)
      assert_equal(obj[1, 0], 1001)
      assert_equal(obj[2, 0], 1002)
      assert_equal(obj[0, 1], 1010)
      assert_equal(obj[1, 1], 1011)
      assert_equal(obj[2, 1], 1012)
      assert_equal(obj[0, 2], 1020)
      assert_equal(obj[1, 2], 1021)
      assert_equal(obj[2, 2], 1022)

      obj = @@klass.new(10, 10, 10)
      10.times do|i|
        10.times do|j|
          10.times do|k|
            obj[i, j, k] = i + j * 10 + k * 100 + 1000
          end
        end
      end
      obj.resize(2, 2, 2)
      assert_equal(obj.xsize, 2)
      assert_equal(obj.ysize, 2)
      assert_equal(obj.zsize, 2)
      assert_equal(obj[0, 0, 0], 1000)
      assert_equal(obj[1, 0, 0], 1001)
      assert_equal(obj[0, 1, 0], 1010)
      assert_equal(obj[1, 1, 0], 1011)
      assert_equal(obj[0, 0, 1], 1100)
      assert_equal(obj[1, 0, 1], 1101)
      assert_equal(obj[0, 1, 1], 1110)
      assert_equal(obj[1, 1, 1], 1111)
    end

    def test_resize_expand
      obj = @@klass.new(3)
      3.times {|i| obj[i] = i + 1000 }
      obj.resize(10)
      assert_equal(obj.xsize, 10)
      assert_equal(obj.ysize, 1)
      assert_equal(obj.zsize, 1)
      assert_equal(obj[0], 1000)
      assert_equal(obj[1], 1001)
      assert_equal(obj[2], 1002)
      assert_equal(obj[3], 0)

      obj = @@klass.new(3, 3)
      3.times do|i|
        3.times do|j|
          obj[i, j] = i + j * 10 + 1000
        end
      end
      obj.resize(10, 10)
      assert_equal(obj.xsize, 10)
      assert_equal(obj.ysize, 10)
      assert_equal(obj.zsize, 1)
      assert_equal(obj[0, 0], 1000)
      assert_equal(obj[1, 0], 1001)
      assert_equal(obj[2, 0], 1002)
      assert_equal(obj[3, 0], 0)
      assert_equal(obj[0, 1], 1010)
      assert_equal(obj[1, 1], 1011)
      assert_equal(obj[2, 1], 1012)
      assert_equal(obj[3, 1], 0)
      assert_equal(obj[0, 2], 1020)
      assert_equal(obj[1, 2], 1021)
      assert_equal(obj[2, 2], 1022)
      assert_equal(obj[3, 2], 0)
      assert_equal(obj[0, 3], 0)
      assert_equal(obj[1, 3], 0)
      assert_equal(obj[2, 3], 0)
      assert_equal(obj[3, 3], 0)

      obj = @@klass.new(2, 2, 2)
      2.times do|i|
        2.times do|j|
          2.times do|k|
            obj[i, j, k] = i + j * 10 + k * 100 + 1000
          end
        end
      end
      obj.resize(10, 10, 10)
      assert_equal(obj.xsize, 10)
      assert_equal(obj.ysize, 10)
      assert_equal(obj.zsize, 10)
      assert_equal(obj[0, 0, 0], 1000)
      assert_equal(obj[1, 0, 0], 1001)
      assert_equal(obj[2, 0, 0], 0)
      assert_equal(obj[0, 1, 0], 1010)
      assert_equal(obj[1, 1, 0], 1011)
      assert_equal(obj[2, 1, 0], 0)
      assert_equal(obj[0, 2, 0], 0)
      assert_equal(obj[1, 2, 0], 0)
      assert_equal(obj[2, 2, 0], 0)
      assert_equal(obj[0, 0, 1], 1100)
      assert_equal(obj[1, 0, 1], 1101)
      assert_equal(obj[2, 0, 1], 0)
      assert_equal(obj[0, 1, 1], 1110)
      assert_equal(obj[1, 1, 1], 1111)
      assert_equal(obj[2, 1, 1], 0)
      assert_equal(obj[0, 2, 1], 0)
      assert_equal(obj[1, 2, 1], 0)
      assert_equal(obj[2, 2, 1], 0)
      assert_equal(obj[0, 0, 2], 0)
      assert_equal(obj[1, 0, 2], 0)
      assert_equal(obj[2, 0, 2], 0)
      assert_equal(obj[0, 1, 2], 0)
      assert_equal(obj[1, 1, 2], 0)
      assert_equal(obj[2, 1, 2], 0)
      assert_equal(obj[0, 2, 2], 0)
      assert_equal(obj[1, 2, 2], 0)
      assert_equal(obj[2, 2, 2], 0)
    end

    def test_resize_expand_shrink
      obj = @@klass.new(3, 4)
      obj[2, 2] = 1022
      obj[2, 3] = 1032
      obj.resize(4, 3)
      assert_equal(obj[2, 2], 1022)
      assert_equal(obj[3, 2], 0)
      assert_equal(obj[2, 3], nil)
    end

    def test_resize_dimchange
      obj = @@klass.new(3)
      obj[0] = 1000
      obj[1] = 1001
      obj[2] = 1002
      obj.resize(2, 2, 2)
      assert_equal(obj[1, 0, 0], 1001)
      assert_equal(obj[1, 1, 1], 0)

      obj = @@klass.new(2, 2)
      obj[0, 0] = 1000
      obj[1, 0] = 1001
      obj[0, 1] = 1010
      obj[1, 1] = 1011
      obj.resize(3)
      assert_equal(obj[0], 1000)
      assert_equal(obj[1], 1001)
      assert_equal(obj[2], 0)
    end

    def test_resize_retval
      obj = @@klass.new(15)
      assert(obj.resize(10).equal?(obj))
    end

    def test_resize_large
      obj = @@klass.new(15)
      assert_raise(RangeError) { obj.resize(1 << 31) }
      assert_raise(RangeError) { obj.resize(-(1 << 31) - 1) }

      # # Runtime Error
      # obj = @@klass.new(15)
      # obj.resize((1 << 30) - 100)

      # # Runtime Error
      # # Note: 65536 * 65536 * 2 == 0 in int32_t
      # obj = @@klass.new(15, 15)
      # obj.resize(65536, 65536)
      # $stderr.puts obj[60000, 60000]
    end

    def test_resize_negative
      obj = @@klass.new(15)
      obj.resize(-12)
      assert_equal([obj.xsize, obj.ysize, obj.zsize], [0, 1, 1])

      obj = @@klass.new(15, 15)
      obj.resize(-12, 10)
      assert_equal([obj.xsize, obj.ysize, obj.zsize], [0, 10, 1])

      obj = @@klass.new(15, 15)
      obj.resize(12, -10)
      assert_equal([obj.xsize, obj.ysize, obj.zsize], [12, 0, 1])

      obj = @@klass.new(15, 15, 15)
      obj.resize(-12, 10, 8)
      assert_equal([obj.xsize, obj.ysize, obj.zsize], [0, 10, 8])

      obj = @@klass.new(15, 15, 15)
      obj.resize(12, -10, 8)
      assert_equal([obj.xsize, obj.ysize, obj.zsize], [12, 0, 8])

      obj = @@klass.new(15, 15, 15)
      obj.resize(12, 10, -8)
      assert_equal([obj.xsize, obj.ysize, obj.zsize], [12, 10, 0])
    end

    def test_resize_argerror
      obj = @@klass.new(15)
      assert_raise(ArgumentError) { obj.resize }
      assert_raise(ArgumentError) { obj.resize(1, 1, 1, 1) }
      assert_raise(ArgumentError) { obj.resize(1, 1, 1, 1, 1) }

      obj = @@klass.new(15, 15)
      assert_raise(ArgumentError) { obj.resize }
      assert_raise(ArgumentError) { obj.resize(1, 1, 1, 1) }
      assert_raise(ArgumentError) { obj.resize(1, 1, 1, 1, 1) }

      obj = @@klass.new(15, 15, 15)
      assert_raise(ArgumentError) { obj.resize }
      assert_raise(ArgumentError) { obj.resize(1, 1, 1, 1) }
      assert_raise(ArgumentError) { obj.resize(1, 1, 1, 1, 1) }
    end

    def test_resize_typeerror
      obj = @@klass.new(15)
      assert_raise(TypeError) { obj.resize("1") }
      obj = @@klass.new(15, 15)
      assert_raise(TypeError) { obj.resize("1", 1) }
      assert_raise(TypeError) { obj.resize(1, "1") }
      obj = @@klass.new(15, 15, 15)
      assert_raise(TypeError) { obj.resize("1", 1, 1) }
      assert_raise(TypeError) { obj.resize(1, "1", 1) }
      assert_raise(TypeError) { obj.resize(1, 1, "1") }
    end

    # def test_equal_1
    #   obj1 = @@klass.new(55, 77, 88, 111)
    #   obj2 = @@klass.new(55, 77, 88, 111)
    #   assert_equal(obj1 == obj2, true)
    #   assert_equal(obj1 === obj2, true)
    #   assert_equal(obj1.eql?(obj2), true)
    #   assert_equal(obj2 == obj1, true)
    #   assert_equal(obj2 === obj1, true)
    #   assert_equal(obj2.eql?(obj1), true)
    # end

    # def test_equal_large
    #   obj1 = @@klass.new((1 << 31) - 1, 0, 0, 0)
    #   obj2 = @@klass.new(-1, 0, 0, 0)
    #   assert_equal(obj1 == obj2, false)
    #   assert_equal(obj1 === obj2, false)
    #   assert_equal(obj1.eql?(obj2), false)

    #   obj1 = @@klass.new(0, (1 << 31) - 1, 0, 0)
    #   obj2 = @@klass.new(0, -1, 0, 0)
    #   assert_equal(obj1 == obj2, false)
    #   assert_equal(obj1 === obj2, false)
    #   assert_equal(obj1.eql?(obj2), false)

    #   obj1 = @@klass.new(0, 0, (1 << 31) - 1, 0)
    #   obj2 = @@klass.new(0, 0, -1, 0)
    #   assert_equal(obj1 == obj2, false)
    #   assert_equal(obj1 === obj2, false)
    #   assert_equal(obj1.eql?(obj2), false)

    #   obj1 = @@klass.new(0, 0, 0, (1 << 31) - 1)
    #   obj2 = @@klass.new(0, 0, 0, -1)
    #   assert_equal(obj1 == obj2, false)
    #   assert_equal(obj1 === obj2, false)
    #   assert_equal(obj1.eql?(obj2), false)
    # end

    # def test_equal_typeerror
    #   obj = @@klass.new(0, 0, 0, 0)
    #   if RGSS == 3
    #     assert_equal(obj == "hoge", false)
    #     assert_equal(obj === "hoge", false)
    #     assert_equal(obj.eql?("hoge"), false)
    #     assert_equal(obj == Color.new(0.0, 0.0, 0.0, 0.0), false)
    #     assert_equal(obj === Color.new(0.0, 0.0, 0.0, 0.0), false)
    #     assert_equal(obj.eql?(Color.new(0.0, 0.0, 0.0, 0.0)), false)
    #   else
    #     assert_raise(TypeError) { obj == @@klass }
    #     assert_raise(TypeError) { obj === @@klass }
    #     assert_raise(TypeError) { obj.eql?(@@klass) }
    #     assert_raise(TypeError) { obj == Color.new(0.0, 0.0, 0.0, 0.0) }
    #     assert_raise(TypeError) { obj === Color.new(0.0, 0.0, 0.0, 0.0) }
    #     assert_raise(TypeError) { obj.eql?(Color.new(0.0, 0.0, 0.0, 0.0)) }
    #   end
    #   assert_equal(:hoge == obj, false)
    #   assert_equal(:hoge === obj, false)
    #   assert_equal(:hoge.eql?(obj), false)
    # end

    # def test_dump_1
    #   obj = @@klass.new(55, 60, 65, 70)
    #   assert_equal(obj._dump(0), "\x37\x00\x00\x00\x3C\x00\x00\x00\x41\x00\x00\x00\x46\x00\x00\x00")

    #   obj = @@klass.new(-55, -60, -65, -70)
    #   expected = "\xC9\xFF\xFF\xFF\xC4\xFF\xFF\xFF\xBF\xFF\xFF\xFF\xBA\xFF\xFF\xFF"
    #   expected.force_encoding("ASCII-8BIT") rescue nil
    #   assert_equal(obj._dump(0), expected)
    # end

    # def test_dump_2
    #   obj = @@klass.new(55, 60, 65, 70)
    #   assert_equal(obj._dump(-1), "\x37\x00\x00\x00\x3C\x00\x00\x00\x41\x00\x00\x00\x46\x00\x00\x00")
    # end

    # def test_dump_3
    #   obj = @@klass.new(55, 60, 65, 70)
    #   assert_equal(obj._dump("hoge"), "\x37\x00\x00\x00\x3C\x00\x00\x00\x41\x00\x00\x00\x46\x00\x00\x00")
    # end
  end
end
