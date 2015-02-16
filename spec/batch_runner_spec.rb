require 'spec_helper'
require 'rmagick-blend/batch_runner'

describe "Batch Runner" do
  before {load_test_config}

  options = { directories: { output: BASE_DIR } }
  
  describe 'open_files_at_end' do
    it "should return false if suppress option is set" do
      expect(RMagickBlend::BatchRunner::open_files_at_end?(suppress: true)).to be false
    end

    it "should return true if force option is set" do
      Settings.directories[:output] = '.'
      Settings.constant_values[:num_files_before_warn] = 10
      expect(RMagickBlend::BatchRunner::open_files_at_end?(force: true)).to be true
    end

    it "suppress option should override force option" do
      expect(RMagickBlend::BatchRunner::open_files_at_end?(suppress: true, force: true)).to be false
    end
  end

  def load_test_config
    test_settings_path = File.expand_path('config/test_config.yml', File.dirname(__FILE__))
    Settings.load!(test_settings_path)
  end

end
