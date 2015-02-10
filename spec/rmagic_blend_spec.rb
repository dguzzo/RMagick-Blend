require 'spec_helper'
require 'rmagick-blend'

describe "rmagic-blend" do
	describe "Blend object" do

		it "can be created" do
			expect(RMagickBlend::Blend.new).to_not be_nil
		end
	end

	describe "configure_options" do
		blend = nil

		before :each do
			blend = RMagickBlend::Blend.new
			blend.send(:load_settings_from_file)
		end	

		it "uses one directory if only source is set" do
			Settings.directories[:destination] = ""
			Settings.directories[:source] = "some-source-dir"
			blend.send(:configure_options)
			expect(blend.options[:directories][:destination]).to eq(blend.options[:directories][:source])
		end

		it "uses one directory if only destination is set" do
			Settings.directories[:source] = ""
			Settings.directories[:destination] = "some-dest-dir"
			blend.send(:configure_options)
			expect(blend.options[:directories][:source]).to eq(blend.options[:directories][:destination])
		end
			
		it "uses both directories if both are set" do
			blend.send(:configure_options)
			expect(blend.options[:directories][:source]).to eq("assets/images/source")
			expect(blend.options[:directories][:destination]).to eq("assets/images/destination")
		end
	end

	describe "load_settings_from_file" do
		it "has a configured Settings object" do
			expect(Settings).to_not be_nil
		end
	end
end
