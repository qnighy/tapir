#include <ruby.h>
#include "main_rb.h"

#if RGSS == 3
#define RGSS_RESET "RGSSReset"
#define TERMS "Terms"
#define SCRIPT_PATH "\"Data\\\\Scripts.rvdata2\""
#elif RGSS == 2
#define RGSS_RESET "Reset"
#define TERMS "Terms"
#define SCRIPT_PATH "\"Data\\\\Scripts.rvdata\""
#else
#define RGSS_RESET "Reset"
#define TERMS "Words"
#define SCRIPT_PATH "\"Data\\\\Scripts.rxdata\""
#endif

VALUE main_rb(VALUE data) {
  (void) data;
  rb_eval_string(
#if RGSS < 3
      "$KCODE = \"u\"\n"
#endif
      "class Bitmap\n"
      /* TODO: Bitmap#initialize */
      "  def initialize(width, height)\n"
      "  end\n"
      "end\n"
      "class Color\n"
      /* TODO: Color#initialize */
      "  def initialize(red, green, blue, alpha)\n"
      "  end\n"
      /* TODO: Color._load */
      "  def self._load(str)\n"
      "    Color.new(0, 0, 0, 0)\n"
      "  end\n"
      "end\n"
      "class Font\n"
      /* TODO: Font.exist? */
      "  def self.exist?(name)\n"
      "    true\n"
      "  end\n"
      "end\n"
      "class Graphics\n"
      /* TODO: Graphics.freeze */
      "  def self.freeze\n"
      "  end\n"
      "end\n"
      "class Rect\n"
      /* TODO: Rect._load */
      "  def self._load(str)\n"
      "    Rect.new\n"
      "  end\n"
      "end\n"
      "class Sprite\n"
      "end\n"
      "class Table\n"
      /* TODO: Table._load */
      "  def self._load(str)\n"
      "    Table.new\n"
      "  end\n"
      "end\n"
      "class Tone\n"
      /* TODO: Tone#initialize */
      "  def initialize(red, green, blue, gray)\n"
      "  end\n"
      /* TODO: Tone._load */
      "  def self._load(str)\n"
      "    Tone.new(0, 0, 0, 0)\n"
      "  end\n"
      "end\n"
      "class Window\n"
      "end\n"
      "class "RGSS_RESET" < Exception\n"
      "end\n"
      "\n"
      "module RPG\n"
      "  class Actor\n"
      "  end\n"
#if RGSS == 1
      "  class AudioFile\n"
      "  end\n"
#endif
      "  class Animation\n"
      "    class Frame\n"
      "    end\n"
      "    class Timing\n"
      "    end\n"
      "  end\n"
#if RGSS == 2
      "  class Area\n"
      "  end\n"
#endif
      "  class Armor\n"
      "  end\n"
#if RGSS >= 2
      "  class BGM\n"
      "  end\n"
#endif
#if RGSS == 3
      "  module BaseItem\n"
      "    class Feature\n"
      "    end\n"
      "  end\n"
#endif
#if RGSS == 1
      "  module Cache\n"
      "  end\n"
#endif
      "  class Class\n"
      "    class Learning\n"
      "    end\n"
      "  end\n"
      "  class CommonEvent\n"
      "  end\n"
      "  class Enemy\n"
      "    class Action\n"
      "    end\n"
#if RGSS >= 2
      "    class DropItem\n"
      "    end\n"
#endif
      "  end\n"
      "  class EventCommand\n"
      "  end\n"
      "  class Item\n"
      "  end\n"
#if RGSS >= 2
      "  class ME\n"
      "  end\n"
#endif
#if RGSS == 3
      "  class MapInfo\n"
      "  end\n"
#endif
#if RGSS >= 2
      "  class MoveCommand\n"
      "  end\n"
      "  class MoveRoute\n"
      "  end\n"
      "  class SE\n"
      "  end\n"
#endif
      "  class Skill\n"
      "  end\n"
#if RGSS == 1
      "  class Sprite\n"
      "  end\n"
#endif
      "  class State\n"
      "  end\n"
      "  class System\n"
      "    class "TERMS"\n"
      "    end\n"
      "    class TestBattler\n"
      "    end\n"
#if RGSS >= 2
      "    class Vehicle\n"
      "    end\n"
#endif
      "  end\n"
#if RGSS == 1 || RGSS == 3
      "  class Tileset\n"
      "  end\n"
#endif
      "  class Troop\n"
      "    class Member\n"
      "    end\n"
      "    class Page\n"
      "      class Condition\n"
      "      end\n"
      "    end\n"
      "  end\n"
#if RGSS == 3
      "  module UsableItem\n"
      "    class Effect\n"
      "    end\n"
      "    class Damage\n"
      "    end\n"
      "  end\n"
#endif
      "  class Weapon\n"
      "  end\n"
      "end\n"
      "\n"
      "def rgss_main\n"
      "  yield\n"
      "rescue "RGSS_RESET"\n"
      "  GC.start\n"
      "  retry\n"
      "end\n"
      /* TODO: read from archive */
      "def load_data(path, &proc)\n"
      "  File.open(path.gsub(/\\\\/, \"/\")) do|file|\n"
      "    Marshal.load(file, &proc)\n"
      "  end\n"
      "end\n"
      "begin\n"
      /* TODO: determine script path from Game.ini */
      "  load_data("SCRIPT_PATH").each do|num,title,script|\n"
      "    s = Zlib::Inflate::inflate(script)\n"
#if RGSS == 3
      "    s.force_encoding(\"utf-8\")\n"
#endif
      "    eval(s, binding, title)\n"
      "  end\n"
      "rescue Exception => e\n"
      "  $stderr.print(\"#{e.class}: #{e.message}\\n\")\n"
      "  e.backtrace.each do|frame|\n"
      "    $stderr.print(\"\\tfrom #{frame}\\n\")\n"
      "  end\n"
      "end\n"
  );
  return Qnil;
}
