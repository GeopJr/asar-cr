require "./spec_helper"
require "yaml"

describe Asar do
  describe "read" do
    it "get hello.txt" do
      asar = Asar::Extract.new "spec/test/archive.asar"
      asar.get("/hello.txt").not_nil!.gets_to_end.should eq "Hello Asar!\n"
    end

    it "get_bytes image.png" do
      asar = Asar::Extract.new "spec/test/archive.asar"
      asar.get_bytes("/assets/image.png").not_nil!.size.should eq 2632
    end

    it "read_raw random.css" do
      asar = Asar::Extract.new "spec/test/archive.asar"
      String.new(asar.read_raw("/assets/random.css").not_nil!).should eq `cat spec/test/archive/assets/random.css`
    end
  end

  describe "unpack" do
    it "is true when successful" do
      asar = Asar::Extract.new "spec/test/archive.asar"
      asar.extract("./archive_test").should be_true
    end
  end

  describe "pack" do
    it "is true when successful" do
      asar = Asar::Pack.new "spec/test/archive"
      asar.pack("./archive_test.asar").should be_true
    end
  end

  describe "version" do
    it "is the same as in shard.yml when successful" do
      Asar::VERSION.should eq YAML.parse(File.read("./shard.yml"))["version"]
    end
  end
end
