require 'spec_helper'
require_relative '../lib/utils.rb'

describe "Utils" do

    describe "FileHandling" do
        
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
        
        describe 'pretty_file_name' do
            
            it "pretty_file_name should not fail with a bad file" do
                expect {Utils::pretty_file_name(nil)}.to_not raise_error
                expect {Utils::pretty_file_name({filename: "blah"})}.to_not raise_error
            end

            it "pretty_file_name should prettify a proper jpg filename" do
                image_file = double("image", :filename => "/some_dir/cool_image.jpg")
                Utils::pretty_file_name(image_file).should eql "cool_image"
            end

            it "pretty_file_name should prettify a proper tif filename" do
                image_file = double("image", :filename => "/some_dir/cool_image.tif")
                Utils::pretty_file_name(image_file).should eql "cool_image"
            end
        end
        
    end
    
end

