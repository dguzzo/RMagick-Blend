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
        
    end
    
end

