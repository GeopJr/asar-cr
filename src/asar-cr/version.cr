require "yaml"

module Asar
  VERSION = YAML.parse(::File.read("./shard.yml"))["version"]
end
