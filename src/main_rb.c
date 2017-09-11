#include <ruby.h>
#include "main_rb.h"

VALUE main_rb(VALUE data) {
  (void) data;
  rb_eval_string(
      /* TODO: read from archive */
      "def load_data(path, &proc)\n"
      "  File.open(path.gsub(/\\\\/, \"/\")) do|file|\n"
      "    Marshal.load(file, &proc)\n"
      "  end\n"
      "end\n"
      "begin\n"
#if RGSS == 3
      "  load_data(\"Data\\\\Scripts.rvdata2\").each do|num,title,script|\n"
      "    s = Zlib::Inflate::inflate(script)\n"
      "    s.force_encoding(\"utf-8\")\n"
      "    eval(s, binding, title)\n"
      "  end\n"
#elif RGSS == 2
      "  load_data(\"Data\\\\Scripts.rvdata\").each do|num,title,script|\n"
      "    s = Zlib::Inflate::inflate(script)\n"
      "    eval(s, binding, title)\n"
      "  end\n"
#else
      "  load_data(\"Data\\\\Scripts.rxdata\").each do|num,title,script|\n"
      "    s = Zlib::Inflate::inflate(script)\n"
      "    eval(s, binding, title)\n"
      "  end\n"
#endif
      "rescue Exception => e\n"
      "  $stderr.print(\"#{e.class}: #{e.message}\\n\")\n"
      "  e.backtrace.each do|frame|\n"
      "    $stderr.print(\"\\tfrom #{frame}\\n\")\n"
      "  end\n"
      "end\n"
  );
  return Qnil;
}
