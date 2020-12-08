require "json"

module Asar
  # :nodoc:
  alias Archive = Directory

  # A directory contains other `Directory`, `File` or `Link` objects.
  class Directory
    include JSON::Serializable

    property files : Hash(String, Directory | File | Link)
  end

  # A `File` contains the size, offset and executable flag stored inside the archive header.
  class File
    include JSON::Serializable

    property size : Int32
    property offset : String
    property executable : Bool?
  end

  # A `Link` contains the link flag stored inside the archive header.
  class Link
    include JSON::Serializable

    property link : String
  end

  # `Header` contains the asar archive header data and length.
  struct Header
    # Header length needed for offset calculation.
    getter length : Int32
    # Archive that contains `File` and `Directory` information.
    getter data : Archive

    def initialize(@data : Archive, @length : Int32)
    end
  end
end
