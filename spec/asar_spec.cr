require "./spec_helper"

describe Asar do
  it "get hello.txt" do
    asar = Asar::Reader.new "spec/test/archive.asar"
    asar.get("/hello.txt").gets_to_end.should eq "Hello Asar!\n"
  end

  it "get_bytes image.png" do
    asar = Asar::Reader.new "spec/test/archive.asar"
    asar.get_bytes("/assets/image.png").size.should eq 2632
  end

  it "read_raw random.css" do
    asar = Asar::Reader.new "spec/test/archive.asar"
    String.new(asar.read_raw("/assets/random.css")).should eq `cat spec/test/archive/assets/random.css`
  end
end
