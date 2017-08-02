require "json"

module Asar
    class Archive
        JSON.mapping(
            files: Hash(String, Dir | File)
        )
    end
    class Dir
        JSON.mapping(
            files: Hash(String, Dir | File)
        )
    end
    class File
        JSON.mapping(
            size: Int32,
            offset: String,
            executable: Bool?
        )
    end
    struct Header
        getter length : Int32
        getter data : Archive
        def initialize(@data : Archive, @length : Int32)            
        end
    end
end
