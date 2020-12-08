module Asar
  # Enables packing of files from the given archive with `#pack`.
  class Pack
    # A recursive hash used to generate the header
    alias HeaderData = Hash(String, HeaderData) | String | UInt64
    @offset = 0_u64
    @packed_files = ""
    @path : Path
    @base : String

    # Creates a new `Pack` from the given folder.
    def initialize(folder : String)
      raise ArgumentError.new("Dir not found") unless Dir.exists?(folder)
      @path = Path[folder].expand(home: true)
      @base = @path.parent.to_s
    end

    private def header_builder(path : Path) : HeaderData
      current = Hash(String, HeaderData).new
      current["files"] = Hash(String, HeaderData).new
      Dir.open(path.to_s).each_child do |file|
        path = path.join(file)
        temp = current["files"]
        raise "Error while creating header" unless temp.is_a?(Hash)
        if Dir.exists?(path)
          nested_files = header_builder(path)
          temp[file] = Hash(String, HeaderData).new
          temp[file] = nested_files
        elsif ::File.symlink?(path)
          link = Path[::File.readlink(path.to_s)].expand(home: true).to_s.lchop(@path.to_s)
          temp[file] = Hash(String, HeaderData).new
          temp2 = temp[file]
          if temp2.is_a?(Hash)
            temp2["link"] = link
          end
        else
          @packed_files += ::File.read(path)
          temp[file] = Hash(String, HeaderData).new
          temp2 = temp[file]
          if temp2.is_a?(Hash)
            size = ::File.info(path).size
            temp2["size"] = size
            temp2["offset"] = @offset.to_s
            @offset += size
          end
        end
        # Return to an upper level
        # Doesn't matter if on root, because paths get joined
        path = path.parent
      end
      current
    end

    private def round_up(i, m)
      return (i + m - 1) & ~(m - 1)
    end

    # Packs the folder into the provided archive.
    #
    # Returns `true` if successful.
    def pack(asar : String) : Bool
      header = header_builder(@path).to_json
      header_string_size = header.size
      data_size = 4_u32
      aligned_size = round_up(header_string_size, data_size)
      header_size = aligned_size + 8
      header_object_size = aligned_size + data_size
      diff = aligned_size - header_string_size
      header = diff > 0 ? header + "0" * diff : header
      num = [data_size, header_size, header_object_size, header_string_size]
      io = IO::Memory.new
      num.each do |n|
        io.write_bytes n.to_i32, IO::ByteFormat::LittleEndian
      end
      io << header
      io << @packed_files
      io.rewind
      path = Path[asar].expand(home: true).to_s
      ::File.write(path + (path.ends_with?(".asar") ? "" : ".asar"), io, mode: "wb")
      true
    end
  end
end
