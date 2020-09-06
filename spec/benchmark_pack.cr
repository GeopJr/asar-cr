require "benchmark"
require "../src/asar"

asar_pack = Asar::Pack.new "spec/test/archive"

Benchmark.ips do |x|
  x.report("pack") { asar_pack.pack("./archive_test.asar") }
end
