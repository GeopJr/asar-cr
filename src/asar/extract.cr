require "json"

module Asar
  # Enables reading and extracting of files from the given archive with `#get`, `#get_bytes`, `#read_raw` and `#extract`.
  #
  # Files are cached automatically when using `#get` or `#get_bytes`; data is stored inside a `Hash`.
  # Please make sure that you have enough memory.
  #
  # Note: When reading from the archive, you have to use absolute paths.
  # The top level directory of the asar archive is the root. e.g.: `/hello.txt`. Paths are case-sensitive.
  class Extract
    property io : ::File
    property header : Header
    @file_index = {} of String => Asar::File
    @link_index = {} of String => Asar::Link
    @file_cache = {} of String => Bytes

    # Creates a new `Extract` for the given archive file.
    def initialize(asar : String)
      input = Path[asar].expand(home: true)
      @io = ::File.open input, "r"
      @header = Asar::Parser.parse @io
      build_index @header.data
    end

    private def build_index(directory : Archive | Asar::Directory, path : String = "")
      directory.files.each do |name, data|
        if data.is_a?(File)
          @file_index["#{path}/#{name}"] = data
        elsif data.is_a?(Link)
          @link_index["#{path}/#{name}"] = data
        end
        if data.is_a?(Directory)
          build_index data, "#{path}/#{name}"
        end
      end
    end

    # Return the `Asar::File`, if found.
    # Else raises `Nil`.
    def index_info(file : String) : Asar::File | Nil
      return unless @file_index[file]?

      @file_index[file]?
    end

    # Returns an `IO::Memory` created from the cached file if found.
    # Else `Nil`.
    def get(path : String) : IO::Memory | Nil
      return unless @file_index[path]?

      file_data = @file_cache[path]?
      if file_data
        io = IO::Memory.new file_data, writeable: false
      else
        file_data = read_raw path
        return if file_data.nil?
        cache_file path, file_data
        io = IO::Memory.new file_data, writeable: false
      end
      io
    end

    # Returns the cached file if found.
    # Else `Nil`.
    def get_bytes(path : String) : Bytes | Nil
      return unless @file_index[path]?

      file_data = @file_cache[path]?
      unless file_data
        file_data = read_raw path
        cache_file path, file_data
      end
      file_data
    end

    # Reads directly from the files `IO`, bypassing the cache if found.
    # Else `Nil`.
    def read_raw(path : String) : Bytes | Nil
      file = @file_index[path]?
      return unless file

      size = file.size
      offset = file.offset
      return if size.nil? || offset.nil?
      file_data = Bytes.new size
      @io.read_at @header.length + offset.to_i32, size do |data|
        data.read_fully file_data
      end
      file_data
    end

    # Extracts the archive to the provided folder.
    #
    # Returns `true` if successful.
    def extract(folder : String) : Bool
      path = Path[folder].expand(home: true)
      @file_index.each do |key, value|
        file_path = path.join(key)
        Dir.mkdir_p(file_path.parent)
        if value.is_a?(Asar::File)
          file = get(key)
          if !file.nil?
            ::File.write(file_path, file.gets_to_end)
          end
        end
      end
      @link_index.each do |key, value|
        file_path = path.join(key)
        Dir.mkdir_p(file_path.parent)
        if value.is_a?(Asar::Link)
          ::File.symlink(path.join(value.link).to_s, file_path.to_s)
        end
      end
      true
    end

    # Returns an `Array(String)` that contains all files (absolute paths) that are in the archive.
    def files
      @file_index.keys
    end

    # Returns an `Array(String)` of all files in the cache.
    def files_cached
      @file_cache.keys
    end

    private def cache_file(path : String, slice : Bytes?)
      if @file_cache[path]?
        raise "#{path} is already in cache."
      end
      return if slice.nil?
      @file_cache[path] = slice
    end
  end
end
