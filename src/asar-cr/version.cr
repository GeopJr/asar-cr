require "yaml"

module Asar
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
end
