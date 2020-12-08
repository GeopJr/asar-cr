require "benchmark"
require "../src/asar-cr"

asar_extract = Asar::Extract.new "spec/test/archive.asar"

Benchmark.ips do |x|
  x.report("get") { asar_extract.get("/hello.txt") }
  x.report("get_bytes") { asar_extract.get_bytes("/hello.txt") }
  x.report("read_raw") { asar_extract.read_raw("/hello.txt") }
end
