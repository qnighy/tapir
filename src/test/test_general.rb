# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

module RGSSTest
  class TestGeneral < Test
    def test_global_variables
      if RGSSTest::RGSS == 3
        assert_symset_equal(global_variables, [
          :$!, :$", :$$, :"$&", :"$'", :$*, :"$+", :$,, :$-0, :$-F, :$-I, :$-K,
          :$-W, :$-d, :$-i, :$-v, :$-w, :$., :$/, :$0, :"$1", :"$2", :"$3",
          :"$4", :"$5", :"$6", :"$7", :"$8", :"$9", :$:, :$;, :$<, :$=, :$>,
          :$?, :$@, :$BTEST, :$DEBUG, :$FILENAME, :$KCODE, :$LOADED_FEATURES,
          :$LOAD_PATH, :$PROGRAM_NAME, :$RGSS_SCRIPTS, :$SAFE, :$TEST,
          :$VERBOSE, :$\, :$_, :"$`", :$stderr, :$stdin, :$stdout, :$~])
      else
        assert_symset_equal(global_variables, [
          :$!, :$", :$$, :"$&", :"$'", :$*, :"$+", :$,, :$-0, :$-F, :$-I, :$-K,
          :$-a, :$-d, :$-i, :$-l, :$-p, :$-v, :$-w, :$., :$/, :$0, :$:, :$;,
          :$<, :$=, :$>, :$?, :$@, :$BTEST, :$DEBUG, :$FILENAME, :$KCODE,
          :$LOAD_PATH, :$RGSS_SCRIPTS, :$SAFE, :$TEST, :$VERBOSE, :$\, :$_,
          :"$`", :$deferr, :$defout, :$stderr, :$stdin, :$stdout, :$~])
      end
      if RGSSTest::RGSS >= 2
        assert_equal($TEST, false)
      end
      assert_equal($DEBUG, false)
      assert_equal($BTEST, false)
      if RGSSTest::RGSS <= 2
        assert_equal($KCODE, "UTF8")
      end
      assert_equal(
        Zlib::Inflate::inflate($RGSS_SCRIPTS[0][2])[0,10],
        "# PROLOGUE")
      assert_equal(
        $RGSS_SCRIPTS[0][3][0,10],
        "# PROLOGUE")
    end

    def test_global_namespaces
      if RGSSTest::RGSS == 3
        assert_symset_equal(Object.constants, [
          :ARGF, :ARGV, :ArgumentError, :Array, :Audio, :BasicObject, :Bignum,
          :Binding, :Bitmap, :Class, :Color, :Comparable, :Complex, :DL, :Data,
          :Dir, :ENV, :EOFError, :Encoding, :EncodingError, :Enumerable,
          :Enumerator, :Errno, :Exception, :FALSE, :FalseClass, :Fiber,
          :FiberError, :File, :FileTest, :Fixnum, :Float, :FloatDomainError,
          :Font, :GC, :Graphics, :Hash, :IO, :IOError, :IndexError, :Input,
          :Integer, :Interrupt, :Kernel, :KeyError, :LoadError,
          :LocalJumpError, :Marshal, :MatchData, :Math, :Method, :Module,
          :Mutex, :NIL, :NameError, :NilClass, :NoMemoryError, :NoMethodError,
          :NotImplementedError, :Numeric, :Object, :ObjectSpace, :Plane, :Proc,
          :Process, :RGSSError, :RGSSReset, :RGSSTest, :RGSS_VERSION, :RPG,
          :RUBY_COPYRIGHT, :RUBY_DESCRIPTION, :RUBY_ENGINE, :RUBY_PATCHLEVEL,
          :RUBY_PLATFORM, :RUBY_RELEASE_DATE, :RUBY_REVISION, :RUBY_VERSION,
          :Random, :Range, :RangeError, :Rational, :Rect, :Regexp,
          :RegexpError, :RubyVM, :RuntimeError, :STDERR, :STDIN, :STDOUT,
          :ScriptError, :SecurityError, :Signal, :SignalException, :Sprite,
          :StandardError, :StopIteration, :String, :Struct, :Symbol,
          :SyntaxError, :SystemCallError, :SystemExit, :SystemStackError,
          :TOPLEVEL_BINDING, :TRUE, :Table, :Thread, :ThreadError,
          :ThreadGroup, :Tilemap, :Time, :Tone, :TrueClass, :TypeError,
          :UnboundMethod, :Viewport, :Win32API, :Window, :ZeroDivisionError,
          :Zlib])
      else
        expected_globals = [
          :ARGF, :ARGV, :ArgumentError, :Array, :Audio, :Bignum, :Binding,
          :Bitmap, :Class, :Color, :Comparable, :Continuation, :Data, :Dir,
          :ENV, :EOFError, :Enumerable, :Errno, :Exception, :FALSE,
          :FalseClass, :File, :FileTest, :Fixnum, :Float, :FloatDomainError,
          :Font, :GC, :Graphics, :Hash, :IO, :IOError, :IndexError, :Input,
          :Integer, :Interrupt, :Kernel, :LoadError, :LocalJumpError,
          :Marshal, :MatchData, :MatchingData, :Math, :Method, :Module, :NIL,
          :NameError, :NilClass, :NoMemoryError, :NoMethodError,
          :NotImplementedError, :Numeric, :Object, :ObjectSpace, :PLATFORM,
          :Plane, :Precision, :Proc, :Process, :RELEASE_DATE, :RGSSError,
          :RGSSTest, :RPG, :RUBY_PLATFORM, :RUBY_RELEASE_DATE, :RUBY_VERSION,
          :Range, :RangeError, :Rect, :Regexp, :RegexpError, :RuntimeError,
          :STDERR, :STDIN, :STDOUT, :ScriptError, :SecurityError, :Signal,
          :SignalException, :Sprite, :StandardError, :String, :Struct, :Symbol,
          :SyntaxError, :SystemCallError, :SystemExit, :SystemStackError,
          :TOPLEVEL_BINDING, :TRUE, :Table, :Thread, :ThreadError,
          :ThreadGroup, :Tilemap, :Time, :Tone, :TrueClass, :TypeError,
          :UnboundMethod, :VERSION, :Viewport, :Win32API, :Window,
          :ZeroDivisionError, :Zlib]
        if RGSSTest::RGSS == 2
          expected_globals += [:NKF]
        else
          expected_globals += [:Hangup, :TilemapAutotiles]
        end
        assert_symset_equal(Object.constants, expected_globals)
      end
    end

    if RGSS == 3
    def test_transcode
      assert_equal(
        "ほげ".encode("Shift_JIS"),
        "\x82\xD9\x82\xB0".force_encoding("Shift_JIS"))
    end
    end # if RGSS == 3

    def test_regex
      assert_nothing_raised(RegexpError) { Regexp.compile('\\s*+\\s*') }
    end

    def test_load_data_noent
      assert_raise(Errno::ENOENT) { load_data("Data/nonexistent.dat") }
    end
  end
end
