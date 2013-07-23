require 'spec_helper'
require 'RMagick'
require_relative '../lib/utils.rb'

describe "Utils" do

    describe "FileHandling" do
        
        describe "get_image_pair_via_directories" do
            
            after do
                clean_assets_directories
            end
            
            it "get_image_pair_via_directories should raise when it can't find source image files" do
                expect {Utils::get_image_pair_via_directories({ source: '.' }, '.jpg')}.to raise_error(RuntimeError)
            end

            it "get_image_pair_via_directories should raise when it can't find destination image files" do
                source = "source"
                create_temp_file(source)
                expect {Utils::get_image_pair_via_directories({ source: "#{Dir.getwd}/spec/assets/#{source}", destination: '.' }, 'jpg')}.to raise_error(RuntimeError)
            end

            it "should not raise when both source and destination files are present" do
                source, destination = "source", "destination"
                create_temp_file(source)
                create_temp_file(destination)
                expect {Utils::get_image_pair_via_directories({ source: "#{Dir.getwd}/spec/assets/#{source}", destination: "#{Dir.getwd}/spec/assets/#{destination}" }, 'jpg')}.to_not raise_error(RuntimeError)
            end
            
        end
        
        describe "get_image_pair_via_image_pool" do
            
            it "should raise if it doesn't find two images" do
                expect{ Utils::get_image_pair_via_image_pool('jpg') }.to raise_error
            end
            
            it "should get two images if available" do
                expect{ Utils::get_image_pair_via_image_pool('jpg', "#{Dir.getwd}/spec/assets/images_pool") }.to_not raise_error
            end
            
        end
        
        describe 'swap_directories' do
            
            it "works with file paths" do
                a, b = "/some/path/to/first", "/some/path/to/second"
                c, d = Utils::swap_directories(a,b)
                c.should eq b
                d.should eq a
            end
            
            it "works with RMagick image objects" do
                a, b = Magick::Image.new(32,32), Magick::Image.new(16,16)
                c, d = a.dup, b.dup
                a, b = Utils::swap_directories(a,b)
                a.should eq d
                b.should eq c
            end
            
        end
        
        describe 'pretty_file_name' do
            
            it "pretty_file_name should not fail with a bad file" do
                expect {Utils::pretty_file_name(nil)}.to_not raise_error
                expect {Utils::pretty_file_name({filename: "blah"})}.to_not raise_error
            end

            it "pretty_file_name should prettify a proper jpg filename" do
                image_file = double("image", filename: "/some_dir/cool_image.jpg")
                Utils::pretty_file_name(image_file).should eql "cool_image"
            end

            it "pretty_file_name should prettify a proper tif filename" do
                image_file = double("image", filename: "/some_dir/cool_image.tif")
                Utils::pretty_file_name(image_file).should eql "cool_image"
            end
        end

        describe 'open_files_at_end' do
            
            it "should return false if suppress option is set" do
                Utils::open_files_at_end?(suppress: true).should be_false
            end

            it "should return true if force option is set" do
                Settings = double("directories", directories: { output_dir: '.' }, constant_values: { num_files_before_warn: 10 } )
                Utils::open_files_at_end?(force: true).should be_true
            end
            
        end

    end
    
end

