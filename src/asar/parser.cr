module Asar
  # Is responsible for reading and parsing the archive header.
  class Parser
    # Expects a readable `IO::FileDescriptor` to read the archive header from.
    #
    # Returns a new `Header` populated with the archives header.
    def self.parse(io : IO::FileDescriptor) : Header
      raise "Can't parse, not enough data!" if io.stat.size < 16
      io.rewind

      payload_size = Int32.from_io io, IO::ByteFormat::LittleEndian
      payload_offset = 8 - payload_size

      io.pos = payload_offset
      header_length = Int32.from_io io, IO::ByteFormat::LittleEndian

      io.pos = 8
      header_payload_size = Int32.from_io io, IO::ByteFormat::LittleEndian
      header_payload_offset = header_length - header_payload_size

      io.pos = 8 + header_payload_offset
      data_table_size = Int32.from_io io, IO::ByteFormat::LittleEndian

      io.pos = 16
      header_data = Bytes.new(data_table_size)
      io.read header_data

      asar_data_offset = 8 + header_length

      begin
        header = Archive.from_json String.new(header_data)
      rescue exception
        raise "#{exception.class} #{exception}"
      end

      Header.new header, asar_data_offset
    end
  end
end
