require "json"

module Asar
  class Reader
    property io : ::File
    property header : Header
    @file_index = {} of String => Asar::File
    @file_cache = {} of String => Bytes

    def initialize(@path : String)
      @io = ::File.open @path, "r"
      @header = Asar::Parser.parse @io
      build_index @header.data
    end

    private def build_index(directory : Archive | Asar::Dir, path : String = "")
      directory.files.each do |name, data|
        if data.is_a?(File)
          @file_index["#{path}/#{name}"] = data
        end
        if data.is_a?(Dir)
          build_index data, "#{path}/#{name}"
        end
      end
    end

    def get(path : String) : IO::Memory
      unless @file_index[path]?
        raise "#{path} Not found!"
      end
      file_data = @file_cache[path]?
      if file_data
        io = IO::Memory.new file_data, writeable: false
      else
        file_data = read_raw path
        cache_file path, file_data
        io = IO::Memory.new file_data, writeable: false
      end
      io
    end

    def get_bytes(path : String) : Bytes
      unless @file_index[path]?
        raise "#{path} Not found!"
      end
      file_data = @file_cache[path]?
      unless file_data
        file_data = read_raw path
        cache_file path, file_data
      end
      file_data
    end

    def read_raw(path : String) : Bytes
      file = @file_index[path]?
      unless file
        raise "#{path} Not found!"
      end
      file_data = Bytes.new file.size
      @io.read_at @header.length + file.offset.to_i32, file.size do |data|
        data.read_fully file_data
      end
      file_data
    end

    private def cache_file(path : String, slice : Bytes)
      if @file_cache[path]?
        raise "#{path} is already in cache."
      end
      @file_cache[path] = slice
    end
  end
end
