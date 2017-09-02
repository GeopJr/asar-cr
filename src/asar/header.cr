require "json"

module Asar
  # The same as `Dir` but it represents the top level directory of the asar archive.
  class Archive
    JSON.mapping(
      files: Hash(String, Dir | File)
    )
  end

  # A directory contains other `Dir` or `File` objects.
  class Dir
    JSON.mapping(
      files: Hash(String, Dir | File)
    )
  end

  # A `File` contains the size, offset and executable flag stored inside the archive header.
  class File
    JSON.mapping(
      size: Int32,
      offset: String,
      executable: Bool?
    )
  end

  # `Header` contains the asar archive header data and length.
  struct Header
    # Header length needed for offset calculation.
    getter length : Int32
    # Archive that contains `File` and `Dir` information.
    getter data : Archive

    def initialize(@data : Archive, @length : Int32)
    end
  end
end
