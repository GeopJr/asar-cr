require "json"

module Asar
  # The same as `Dir` but it represents the top level directory of the asar archive.
  alias Archive = Directory

  # A directory contains other `Dir` or `File` objects.
  class Directory
    JSON.mapping(
      files: Hash(String, Directory | File | Link)
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

  # A `Link` contains the link flag stored inside the archive header.
  class Link
    JSON.mapping(
      link: String
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
