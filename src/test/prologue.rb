# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  if TEST_NAME
    if TEST_NAME[0..0] == '/' && TEST_NAME[-1..-1] == '/'
      FILTER = Regexp.new(TEST_NAME[1..-2])
    else
      FILTER = TEST_NAME
    end
  else
    FILTER = nil
  end

  class Assertion < Exception
  end

  class Skip < Assertion
  end

  class AssertionFailedError < Assertion
  end

  module Assertions
    def skip
      raise Skip
    end

    def skip_default
      skip if FILTER.nil?
    end

    def assert_block(message = "assert_block failed.", &b)
      if !b.call then
        raise AssertionFailedError, message
      end
    end

    def assert_raise(*args, &b)
      message = nil
      if String === args.last then
        message = args.pop
      end
      begin
        b.call
      rescue
        if args.any? {|k| $!.kind_of?(k) } then
          return
        end
      end
      message = "#{args.inspect} is not raised" if message.nil?
      raise AssertionFailedError, message
    end

    def assert_nothing_raised(*args, &b)
      message = nil
      if String === args.last then
        message = args.pop
      end
      begin
        b.call
      rescue
        if args.any? {|k| $!.kind_of?(k) } then
          message = "#{args.inspect} is raised" if message.nil?
          raise AssertionFailedError, message
        end
      end
    end

    def assert_raise_with_message(exception, expected, message = nil, &b)
      begin
        b.call
      rescue
        if $!.kind_of?(exception) && $!.message.include?(expected) then
          return
        end
        raise
      end
      message = "#{exception.inspect} is not raised with message #{expected.inspect}" if message.nil?
      raise AssertionFailedError, msg
    end

    def assert(boolean, message = nil)
      if !boolean then
        raise AssertionFailedError, message
      end
    end

    def assert_equal(expected, actual, message = nil)
      if expected != actual then
        message = "#{expected.inspect} != #{actual.inspect}" if message.nil?
        raise AssertionFailedError, message
      end
    end

    def assert_not_equal(expected, actual, message = nil)
      if expected == actual then
        message = "#{expected.inspect} == #{actual.inspect}" if message.nil?
        raise AssertionFailedError, message
      end
    end

    def assert_symset_equal(expected, actual, message = nil)
      expected = expected.map {|s| s.to_s}.sort
      actual = actual.map {|s| s.to_s}.sort
      if expected != actual then
        expected_have = (expected - actual).map {|s| s.to_sym}
        actual_have = (actual - expected).map {|s| s.to_sym}
        expected = expected.map {|s| s.to_sym}
        actual = actual.map {|s| s.to_sym}
        message = \
          "#{expected.inspect} != #{actual.inspect} " +
          "(Only in lhs: #{expected_have.inspect}, " +
          "Only in rhs: #{actual_have.inspect})" if message.nil?
        raise AssertionFailedError, message
      end
    end

    def assert_same(expected, actual, message = nil)
      if !expected.equal?(actual) then
        message = "!#{expected.inspect}.equal?(#{actual.inspect})" if message.nil?
        raise AssertionFailedError, message
      end
    end

    def assert_not_same(expected, actual, message = nil)
      if expected.equal?(actual) then
        message = "#{expected.inspect}.equal?(#{actual.inspect})" if message.nil?
        raise AssertionFailedError, message
      end
    end

    def owned_instance_methods(klass)
      klass.instance_methods.select {|m|
        method = klass.instance_method(m)
        if method.respond_to?(:owner)
          method.owner == klass
        else
          method.inspect !~ /\(/
        end
      }
    end
  end

  module BitmapUtil
    @@imgdir = "../../src/test/Graphics"

    def assert_bitmap_equal(expected, actual, message = nil)
      comparison = compare_bitmap(expected, actual)
      unless comparison < 0.01
        message = \
          "#{expected.inspect} != #{actual.inspect} " +
          "(difference: #{comparison})" if message.nil?
        save_bitmap(actual, "actual.png") rescue nil
        save_bitmap(expected, "expected.png") rescue nil
        raise AssertionFailedError, message
      end
    end

    def assert_bitmap_equal2(name, actual, save = false, message = nil)
      if save
        $stderr.puts "assert_bitmap_equal2: saving to #@@imgdir/#{name}.png..."
        save_bitmap(actual, "#@@imgdir/#{name}.png")
        return
      end
      expected = Bitmap.new("#@@imgdir/#{name}.png")
      comparison = compare_bitmap(expected, actual)
      unless comparison < 0.01
        save_bitmap(actual, "#{name}_actual.png") rescue nil
        save_bitmap(expected, "#{name}_expected.png") rescue nil
        message = \
          "#{name}_expected.png != #{name}_actual.png " +
          "(difference: #{comparison})" if message.nil?
        raise AssertionFailedError, message
      end
    end

    def compare_bitmap(bitmap0, bitmap1)
      (bitmap0.width == bitmap1.width && bitmap0.height == bitmap1.height) or
        return 1.0 / 0.0

      width = bitmap0.width
      height = bitmap0.height
      sum = 0.0
      height.times do|y|
        width.times do|x|
          c0 = bitmap0.get_pixel(x, y)
          c1 = bitmap1.get_pixel(x, y)
          sum += (c0.red - c1.red) ** 2
          sum += (c0.green - c1.green) ** 2
          sum += (c0.blue - c1.blue) ** 2
          sum += (c0.alpha - c1.alpha) ** 2
        end
      end
      sum /= 255.0 * 255.0 * width * height * 4
      Math.sqrt(sum)
    end

    def save_bitmap(bitmap, path)
      width = bitmap.width
      height = bitmap.height
      bit_depth = 8
      color_type = (2 | 4)  # 2 = color, 4 = alpha
      compression = 0  # zlib
      filter_method = 0
      interlace = 0  # no interlace

      raw_data = Zlib::Deflate.new
      height.times do|y|
        raw_data << "\0"
        width.times do|x|
          pixel = bitmap.get_pixel(x, y)
          raw_data << [
            pixel.red, pixel.green, pixel.blue, pixel.alpha].pack("C4")
        end
      end
      raw_data = raw_data.finish

      File.open(path, "wb") do|file|
        file.print("\x89PNG\r\n\x1a\n")
        write_chunk = proc {|type, data|
          file.print([(data.bytesize rescue data.size)].pack("N"))
          file.print(type)
          file.print(data)
          file.print([Zlib.crc32(data, Zlib.crc32(type))].pack("N"))
        }
        ihdr = [
          width, height, bit_depth, color_type, compression, filter_method,
          interlace].pack("NNCCCCC")
        write_chunk.call("IHDR", ihdr)
        write_chunk.call("IDAT", raw_data)
        write_chunk.call("IEND", "")
      end
    end
  end

  module WithClean
    def register(obj)
      @objects << obj
      obj
    end

    def cleaned(&b)
      begin
        @objects = []
        b.call
      ensure
        @objects.each do|obj|
          obj.dispose
        end
      end
    end
  end

  class Test
    include Assertions
    include BitmapUtil

    attr_accessor :name
    attr_reader :failure

    def setup; end

    def teardown; end

    def run
      begin
        setup
        send(name)
      rescue Skip
        @skipped = true
      rescue Exception
        @failure = $!
      ensure
        teardown
      end
    end

    def passed?
      !@failure
    end

    def result_code
      if passed?
        @skipped ? 'S' : '.'
      elsif AssertionFailedError === @failure
        'F'
      else
        'E'
      end
    end

    @@tests = []

    def self.tests
      @@tests
    end

    def self.inherited(klass)
      @@tests << klass
    end
  end

  def self.run
    run_tests = []
    Test.tests.each do|klass|
      klass.instance_methods.grep(/\Atest_/).each do|method_name|
        if FILTER.nil? || \
            FILTER === "#{method_name}" || FILTER === "#{klass}##{method_name}"
          obj = klass.new
          obj.name = method_name.to_s
          obj.run
          $stdout.print(obj.result_code)
          $stdout.flush
          run_tests << obj
        end
      end
    end
    puts ""
    run_tests.select {|test| !test.passed?}.each do|test|
      failure = test.failure
      backtrace = \
        failure.kind_of?(AssertionFailedError) ?
          failure.backtrace[1] : failure.backtrace[0]
      message = "#{failure.class}: #{failure.message} (at #{backtrace})"
      puts "#{test.class}\##{test.name}: Failed: #{message}"
    end
    successcnt = run_tests.select {|test| test.passed?}.size
    allcnt = run_tests.size
    puts ""
    puts "Summary: #{successcnt} / #{allcnt}"
    puts ""
  end
end
