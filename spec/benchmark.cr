require "benchmark"
require "../src/asar"

asar = Asar::Reader.new "spec/test/archive.asar"
puts asar.get("/hello.txt").gets_to_end

Benchmark.ips do |x|
  x.report("get") { asar.get("/hello.txt") }
  x.report("get_bytes") { asar.get_bytes("/hello.txt") }
  x.report("read_raw") { asar.read_raw("/hello.txt") }
end
