$stdout.reopen("stdout.txt", "w")
$stderr.reopen("stderr.txt", "w")

module RGSSTest
  if File.exist?("Data/Scripts.rxdata")
    RGSS = 1
  elsif File.exist?("Data/Scripts.rvdata")
    RGSS = 2
  elsif File.exist?("Data/Scripts.rvdata2")
    RGSS = 3
  else
    raise "Could not determine RGSS version"
  end

  class AssertionFailedError < StandardError
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
        raise AssertionFailedError, message
      end
    end
  end

  def assert_raise_with_message(exception, expected, msg = nil, &b)
    begin
      b.call
    rescue
      if $!.kind_of?(exception) && $!.message == expected then
        return
      end
    end
    raise AssertionFailedError, msg
  end

  def assert(boolean, message = nil)
    if !boolean then
      raise AssertionFailedError, message
    end
  end

  def assert_equal(expected, actual, message = nil)
    if expected != actual then
      raise AssertionFailedError, message
    end
  end

  def assert_not_equal(expected, actual, message = nil)
    if expected == actual then
      raise AssertionFailedError, message
    end
  end

  def assert_same(expected, actual, message = nil)
    if !expected.equal?(actual) then
      raise AssertionFailedError, message
    end
  end

  def assert_not_same(expected, actual, message = nil)
    if expected.equal?(actual) then
      raise AssertionFailedError, message
    end
  end

  def self.run_test(klass)
    puts "Running tests #{klass.name}..."
    i = klass.new
    allcnt = 0
    successcnt = 0
    i.methods.grep(/\Atest_/).each do|method_name|
      ok = true
      message = ""
      begin
        i.send(method_name)
      rescue
        ok = false
        message = "#{$!.class}: #{$!.message}"
      end
      if ok
        puts "  #{method_name}: OK"
        successcnt += 1
      else
        puts "  #{method_name}: Failed: #{message}"
      end
      allcnt += 1
    end
    puts "Summary: #{successcnt} / #{allcnt}"
    puts ""
  end
end
