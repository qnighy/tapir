#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

require "fileutils"
require "zlib"

RGSS = ARGV[0].to_i
TEST_SRC = "../../src/test"

data_ext = ["rxdata", "rvdata", "rvdata2"][RGSS-1]
dll_path = ["RGSS104J.dll", "RGSS202J.dll", "System\\RGSS301.dll"][RGSS-1]

scripts = [
  "#{TEST_SRC}/prologue.rb"
]

scripts << "#{TEST_SRC}/test_general.rb"
scripts << "#{TEST_SRC}/test_rgsserror.rb"
scripts << "#{TEST_SRC}/test_rgssreset.rb"
scripts << "#{TEST_SRC}/test_bitmap.rb"
# scripts << "#{TEST_SRC}/test_sprite.rb"
# scripts << "#{TEST_SRC}/test_sprite_ordering.rb"
scripts << "#{TEST_SRC}/test_rpg.rb"
scripts << "#{TEST_SRC}/test_rpg_map.rb"
scripts << "#{TEST_SRC}/test_rpg_event.rb"
scripts << "#{TEST_SRC}/test_rpg_item.rb"
scripts << "#{TEST_SRC}/test_rpg_troop.rb"
scripts << "#{TEST_SRC}/test_rpg_animation.rb"
scripts << "#{TEST_SRC}/test_rpg_tileset.rb"
scripts << "#{TEST_SRC}/test_rpg_commonevent.rb"
scripts << "#{TEST_SRC}/test_rpg_system.rb"
scripts << "#{TEST_SRC}/test_rpg_audiofile.rb"
scripts << "#{TEST_SRC}/test_rpg_sprite.rb"
scripts << "#{TEST_SRC}/test_rpg_weather.rb"

scripts << "#{TEST_SRC}/epilogue.rb"

scripts_data = scripts.map {|script_path|
  zscript = Zlib::Deflate::deflate(File.read(script_path))
  [rand(100000000), script_path, zscript]
}

FileUtils.mkdir_p("Data")
File.open("Data/Scripts.#{data_ext}", "wb") do|file|
  Marshal.dump(scripts_data, file)
end

File.open("Game.ini", "wb:cp932") do|file|
  file.print "[Game]\r\n"
  file.print "Library=#{dll_path}\r\n"
  file.print "Scripts=Data\\Scripts.#{data_ext}\r\n"
  file.print "Title=RGSS#{RGSS} Test\r\n"
  if RGSS == 3
    file.print "RTP=RPGVXAce\r\n"
  elsif RGSS == 2
    file.print "RTP=RPGVX\r\n"
  else
    file.print "RTP1=Standard\r\n"
    file.print "RTP2\r\n"
    file.print "RTP3\r\n"
  end
end

begin
  system(ARGV[1]) or raise "#{ARGV[1]} failed: #$?"
ensure
  $stdout.print(File.read("stdout.txt"))
  $stderr.print(File.read("stderr.txt"))
end
