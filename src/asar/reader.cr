require "json"

module Asar
  # Enables reading of files from the given archive with `#get`, `#get_bytes` and `#read_raw`.
  # 
  # Files are cached automatically when using `#get` or `#get_bytes`; data is stored inside a `Hash`.  
  # Please make sure that you have enough memory.
  #
  # Note: When reading from the archive, you have to use absolute paths.
  # The top level directory of the asar archive is the root. e.g.: `/hello.txt`. Paths are case-sensitive.
  class Reader
    property io : ::File
    property header : Header
    @file_index = {} of String => Asar::File
    @file_cache = {} of String => Bytes

    # Creates a new `Reader` for the given archive file.
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

    # Returns an `IO::Memory` created from the cached file.
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

    # Returns the cached file.
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

    # Reads directly from the files `IO`, bypassing the cache.
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

    # Returns an `Array(String)` that contains all files (absolute paths) that are in the archive.
    def files
      @file_index.keys
    end

    # Returns an `Array(String)` of all files in the cache.
    def files_cached
      @file_cache.keys
    end

    private def cache_file(path : String, slice : Bytes)
      if @file_cache[path]?
        raise "#{path} is already in cache."
      end
      @file_cache[path] = slice
    end
  end
end
