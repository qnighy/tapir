# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

# Win32API usage from http://torigoya.hatenadiary.jp/entry/20120612/volume

module RGSSTest
  class TestExt1 < Test
    def test_get_audiovol
      ini_filename = "./Game_test_get_audiovol.ini"
      begin
        File.open(ini_filename, "wb") do|file|
          file.print "[Game]\r\n"
          file.print "Library=System\\RGSS301.dll\r\n"
          file.print "Scripts=Data\Scripts.rvdata2\r\n"
          file.print "Title=RGSS3 Test\r\n"
          file.print "RTP=RPGVXAce\r\n"
          file.print "\r\n"
          file.print "[AudioVol]\r\n"
          file.print "BGS=54\r\n"
          file.print "ME=0\r\n"
          file.print "SE=77\r\n"
        end
        @GetPrivateProfileInt = Win32API.new('kernel32', 'GetPrivateProfileInt', %w(p p i p), 'i')
        assert_equal(
          @GetPrivateProfileInt.call('AudioVol', 'BGM', 100, ini_filename),
          100)
        assert_equal(
          @GetPrivateProfileInt.call('AudioVol', 'BGS', 100, ini_filename),
          54)
        assert_equal(
          @GetPrivateProfileInt.call('AudioVol', 'SE', 100, ini_filename),
          77)
        assert_equal(
          @GetPrivateProfileInt.call('AudioVol', 'ME', 100, ini_filename),
          0)
      ensure
        File.delete(ini_filename) rescue nil
      end
    end

    def test_set_audiovol
      ini_filename = "./Game_test_set_audiovol.ini"
      begin
        @GetPrivateProfileInt = Win32API.new('kernel32', 'GetPrivateProfileInt', %w(p p i p), 'i')
        @WritePrivateProfileString = Win32API.new('kernel32', 'WritePrivateProfileString', %w(p p p p), 'i')

        @WritePrivateProfileString.call('AudioVol', 'SE', "3", ini_filename)
        @WritePrivateProfileString.call('AudioVol', 'ME', "35", ini_filename)
        @WritePrivateProfileString.call('AudioVol', 'BGM', "95", ini_filename)
        @WritePrivateProfileString.call('AudioVol', 'BGS', "72", ini_filename)
        assert_equal(
          @GetPrivateProfileInt.call('AudioVol', 'BGM', 100, ini_filename),
          95)
        assert_equal(
          @GetPrivateProfileInt.call('AudioVol', 'BGS', 100, ini_filename),
          72)
        assert_equal(
          @GetPrivateProfileInt.call('AudioVol', 'SE', 100, ini_filename),
          3)
        assert_equal(
          @GetPrivateProfileInt.call('AudioVol', 'ME', 100, ini_filename),
          35)
      ensure
        File.delete(ini_filename) rescue nil
      end
    end

    def test_set_audiovol_2
      ini_filename = "./Game_test_set_audiovol_2.ini"
      begin
        File.open(ini_filename, "wb") do|file|
          file.print "[AudioVol]\r\n"
          file.print "BGS=54\r\n"
          file.print "ME=0\r\n"
          file.print "SE=77\r\n"
          file.print "\r\n"
          file.print "[Game]\r\n"
          # "Title=テスト 表示 \\\r\n".encode("cp932")
          file.print "Title=\x83\x65\x83\x58\x83\x67 \x95\x5C\x8E\xA6 \\\r\n"
        end
        @GetPrivateProfileInt = Win32API.new('kernel32', 'GetPrivateProfileInt', %w(p p i p), 'i')
        @WritePrivateProfileString = Win32API.new('kernel32', 'WritePrivateProfileString', %w(p p p p), 'i')

        @WritePrivateProfileString.call('AudioVol', 'SE', "3", ini_filename)
        @WritePrivateProfileString.call('AudioVol', 'ME', "35", ini_filename)
        @WritePrivateProfileString.call('AudioVol', 'BGM', "95", ini_filename)
        @WritePrivateProfileString.call('AudioVol', 'BGS', "72", ini_filename)
        assert_equal(
          @GetPrivateProfileInt.call('AudioVol', 'BGM', 100, ini_filename),
          95)
        assert_equal(
          @GetPrivateProfileInt.call('AudioVol', 'BGS', 100, ini_filename),
          72)
        assert_equal(
          @GetPrivateProfileInt.call('AudioVol', 'SE', 100, ini_filename),
          3)
        assert_equal(
          @GetPrivateProfileInt.call('AudioVol', 'ME', 100, ini_filename),
          35)
        File.open(ini_filename, "rb") do|file|
          ini_contents = file.readlines
          expected = "Title=\x83\x65\x83\x58\x83\x67 \x95\x5C\x8E\xA6 \\\r\n"
          expected.force_encoding("ASCII-8BIT") rescue nil
          assert(ini_contents.index(expected))
        end
      ensure
        File.delete(ini_filename) rescue nil
      end
    end
  end
end
