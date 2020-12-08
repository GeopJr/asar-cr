require "benchmark"
require "../src/asar-cr"

asar_extract = Asar::Extract.new "spec/test/archive.asar"

Benchmark.ips do |x|
  x.report("extract") { asar_extract.extract("./archive_test") }
end
