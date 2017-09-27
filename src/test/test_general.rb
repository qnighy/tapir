module RGSSTest
  class TestGeneral
    include RGSSTest

    def test_global_variables
      if RGSSTest::RGSS == 3
        assert_equal(global_variables.sort, [
          :$!, :$", :$$, :"$&", :"$'", :$*, :"$+", :$,, :$-0, :$-F, :$-I, :$-K,
          :$-W, :$-d, :$-i, :$-v, :$-w, :$., :$/, :$0, :"$1", :"$2", :"$3",
          :"$4", :"$5", :"$6", :"$7", :"$8", :"$9", :$:, :$;, :$<, :$=, :$>,
          :$?, :$@, :$BTEST, :$DEBUG, :$FILENAME, :$KCODE, :$LOADED_FEATURES,
          :$LOAD_PATH, :$PROGRAM_NAME, :$RGSS_SCRIPTS, :$SAFE, :$TEST,
          :$VERBOSE, :$\, :$_, :"$`", :$stderr, :$stdin, :$stdout, :$~])
      else
        assert_equal(global_variables.sort, [
          "$!", "$\"", "$$", "$&", "$'", "$*", "$+", "$,", "$-0", "$-F", "$-I",
          "$-K", "$-a", "$-d", "$-i", "$-l", "$-p", "$-v", "$-w", "$.", "$/",
          "$0", "$:", "$;", "$<", "$=", "$>", "$?", "$@", "$BTEST", "$DEBUG",
          "$FILENAME", "$KCODE", "$LOAD_PATH", "$RGSS_SCRIPTS", "$SAFE",
          "$TEST", "$VERBOSE", "$\\", "$_", "$`", "$deferr", "$defout",
          "$stderr", "$stdin", "$stdout", "$~"])
      end
      if RGSSTest::RGSS >= 2
        assert_equal($TEST, false)
      end
      assert_equal($DEBUG, false)
      assert_equal($BTEST, false)
      if RGSSTest::RGSS == 3
        assert_equal($KCODE, nil)
      else
        assert_equal($KCODE, "UTF8")
      end
      assert_equal(
        Zlib::Inflate::inflate($RGSS_SCRIPTS[0][2])[0,10],
        "# PROLOGUE")
    end

    def test_global_namespaces
      if RGSSTest::RGSS == 3
        assert_equal(Object.constants.sort, [
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
      elsif RGSSTest::RGSS == 2
        assert_equal(Object.constants.sort, [
          "ARGF", "ARGV", "ArgumentError", "Array", "Audio", "Bignum",
          "Binding", "Bitmap", "Class", "Color", "Comparable", "Continuation",
          "Data", "Dir", "ENV", "EOFError", "Enumerable", "Errno", "Exception",
          "FALSE", "FalseClass", "File", "FileTest", "Fixnum", "Float",
          "FloatDomainError", "Font", "GC", "Graphics", "Hash", "IO",
          "IOError", "IndexError", "Input", "Integer", "Interrupt", "Kernel",
          "LoadError", "LocalJumpError", "Marshal", "MatchData",
          "MatchingData", "Math", "Method", "Module", "NIL", "NKF",
          "NameError", "NilClass", "NoMemoryError", "NoMethodError",
          "NotImplementedError", "Numeric", "Object", "ObjectSpace",
          "PLATFORM", "Plane", "Precision", "Proc", "Process", "RELEASE_DATE",
          "RGSSError", "RGSSTest", "RPG", "RUBY_PLATFORM", "RUBY_RELEASE_DATE",
          "RUBY_VERSION", "Range", "RangeError", "Rect", "Regexp",
          "RegexpError", "RuntimeError", "STDERR", "STDIN", "STDOUT",
          "ScriptError", "SecurityError", "Signal", "SignalException",
          "Sprite", "StandardError", "String", "Struct", "Symbol",
          "SyntaxError", "SystemCallError", "SystemExit", "SystemStackError",
          "TOPLEVEL_BINDING", "TRUE", "Table", "Thread", "ThreadError",
          "ThreadGroup", "Tilemap", "Time", "Tone", "TrueClass", "TypeError",
          "UnboundMethod", "VERSION", "Viewport", "Win32API", "Window",
          "ZeroDivisionError", "Zlib"])
      else
        assert_equal(Object.constants.sort, [
          "ARGF", "ARGV", "ArgumentError", "Array", "Audio", "Bignum",
          "Binding", "Bitmap", "Class", "Color", "Comparable", "Continuation",
          "Data", "Dir", "ENV", "EOFError", "Enumerable", "Errno", "Exception",
          "FALSE", "FalseClass", "File", "FileTest", "Fixnum", "Float",
          "FloatDomainError", "Font", "GC", "Graphics", "Hangup", "Hash", "IO",
          "IOError", "IndexError", "Input", "Integer", "Interrupt", "Kernel",
          "LoadError", "LocalJumpError", "Marshal", "MatchData",
          "MatchingData", "Math", "Method", "Module", "NIL", "NameError",
          "NilClass", "NoMemoryError", "NoMethodError", "NotImplementedError",
          "Numeric", "Object", "ObjectSpace", "PLATFORM", "Plane", "Precision",
          "Proc", "Process", "RELEASE_DATE", "RGSSError", "RGSSTest", "RPG",
          "RUBY_PLATFORM", "RUBY_RELEASE_DATE", "RUBY_VERSION", "Range",
          "RangeError", "Rect", "Regexp", "RegexpError", "RuntimeError",
          "STDERR", "STDIN", "STDOUT", "ScriptError", "SecurityError",
          "Signal", "SignalException", "Sprite", "StandardError", "String",
          "Struct", "Symbol", "SyntaxError", "SystemCallError", "SystemExit",
          "SystemStackError", "TOPLEVEL_BINDING", "TRUE", "Table", "Thread",
          "ThreadError", "ThreadGroup", "Tilemap", "TilemapAutotiles", "Time",
          "Tone", "TrueClass", "TypeError", "UnboundMethod", "VERSION",
          "Viewport", "Win32API", "Window", "ZeroDivisionError", "Zlib"])
      end
    end
  end

  run_test(TestGeneral)
end
