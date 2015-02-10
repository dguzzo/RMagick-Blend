require 'spec_helper'
require 'rmagick-blend'

describe "rmagic-blend" do
	describe "load_settings" do
			
		it "has a Settings object" do
			expect(Settings).to_not be_nil
		end

		xit "uses one directory if either source or destination is not set" do
			Settings = double("directories", directories: { output: "some-output-dir", source: "some-source-dir" } )
		end
			
		xit "uses both directories if both are set" do
			Settings = double("directories", directories: { output: "some-output-dir", source: "some-source-dir", destination: "some-dest-dir" } )
		end

	end
end
