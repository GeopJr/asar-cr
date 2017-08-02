# asar - Electron Archive format for Crystal

[![GitHub release](https://img.shields.io/github/release/petoem/asar.svg?style=flat-square)](https://github.com/petoem/asar/releases)
[![Travis](https://img.shields.io/travis/petoem/asar.svg?style=flat-square)](https://travis-ci.org/petoem/asar)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/petoem/asar/blob/master/LICENSE)  

Read files from `.asar` archives with built-in caching.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  asar:
    github: petoem/asar
```

## Usage

```crystal
require "asar"

asar = Asar::Reader.new "path/to/your/archive.asar"
io = asar.get "/awesome/image.png"
slice = asar.get_bytes "/awesome/story.txt"

asar.files # Returns an Array(String) of all files in the archive. 
asar.files_cached # Returns an Array(String) of all files in the cache. 

```

## Benchmark

```
> crystal run spec/benchmark.cr --release

      get   3.21M (311.09ns) (±14.27%)   4.64× slower
get_bytes   14.9M ( 67.09ns) (± 1.47%)        fastest
 read_raw  69.21k ( 14.45µs) (±16.62%) 215.36× slower
```

The methods `get` and `get_bytes` cache a file at first read.  
- `get` returns an `IO::Memory` created from the cached file  
- `get_bytes` returns the cached file  
- `read_raw` reads directly from the files `IO`, bypassing the cache  

## TODO

- [x] Parse asar archive
- [x] Read files from archive
- [ ] Pack directory into archive?
- [ ] Transform support?

## Contributing

1. Fork it ( https://github.com/petoem/asar/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [petoem](https://github.com/petoem) Michael Petö - creator, maintainer
