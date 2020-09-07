# asar-cr - Electron Archive format for Crystal

[![GitHub release](https://img.shields.io/github/release/GeopJr/asar-cr.svg?style=flat-square)](https://github.com/GeopJr/asar-cr/releases)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/GeopJr/asar-cr/blob/master/LICENSE)  

Read files from `.asar` archives with built-in caching.

Pack and Unpack to and from `.asar` archives.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  asar-cr:
    github: GeopJr/asar-cr
```

## Usage

#### Reading

```crystal
require "asar"

asar = Asar::Reader.new "path/to/your/archive.asar"
io = asar.get "/awesome/image.png"
slice = asar.get_bytes "/awesome/story.txt"

asar.files # Returns an Array(String) of all files in the archive.
asar.files_cached # Returns an Array(String) of all files in the cache.

```

#### Extract

```crystal
require "asar"

asar = Asar::Extract.new "path/to/your/archive.asar"

asar.extract "path/to/your/folder" # Returns true if completed successfully.

```

#### Pack

```crystal
require "asar"

asar = Asar::Pack.new "path/to/your/folder"

asar.pack "path/to/your/archive.asar" # Returns true if completed successfully.

```

## Benchmarks

```
> crystal run spec/benchmark_read.cr --release

      get   9.33M (107.18ns) (± 5.87%)   96.0B/op    3.23× slower
get_bytes  30.11M ( 33.22ns) (± 1.18%)    0.0B/op         fastest
 read_raw 280.96k (  3.56µs) (± 6.42%)  8.17kB/op  107.15× slower
```
> *Note: Benchmark was done on an SSD and the test [file](spec/test/archive/hello.txt) was small.*

The methods `get` and `get_bytes` cache a file at first read.  
- `get` returns an `IO::Memory` created from the cached file  
- `get_bytes` returns the cached file  
- `read_raw` reads directly from the files `IO`, bypassing the cache  

```
> crystal run spec/benchmark_extract.cr --release

extract   4.95k (201.90µs) (± 6.65%)  29.5kB/op  fastest
```
> *Note: Couldn't benchmark benchmark_pack.cr due to `Too many open files (File::Error)`.*

## What changed?

1. Updated to latest Crystal version
2. Use of [Path](https://crystal-lang.org/api/latest/Path.html), allowing cross-platform usage.
3. Added extract and pack functionality.

## Anyone using it?

1. [Crycord](https://github.com/GeopJr/Crycord): A Discord Client mod

## Contributing

1. Fork it ( https://github.com/GeopJr/asar-cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [GeopJr](https://github.com/GeopJr) Maintainer
- [petoem](https://github.com/petoem) Michael Petö - Original Creator
