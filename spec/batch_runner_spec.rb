require 'spec_helper'
require 'rmagick-blend/batch_runner'

describe "Batch Runner" do
  before {load_test_config}

  options = { directories: { output: BASE_DIR } }
  
  describe "large_previous_batch?" do
    
    describe "without history file" do
      before { delete_history_file }

      it "still returns false with a 'y' as input" do
        stub_input_for_gets('y')
        expect(RMagickBlend::BatchRunner::large_previous_batch?(options)).to be false
      end

      it "still returns false with a 'yes' as input" do
        stub_input_for_gets('yes')
        expect(RMagickBlend::BatchRunner::large_previous_batch?(options)).to be false
      end
    end

    describe "with history file" do
      before :each do create_history_file; end
      after :each do delete_history_file; end

      it "returns false with empty input" do
        stub_input_for_gets('')
        expect(RMagickBlend::BatchRunner::large_previous_batch?(options)).to be false
      end

      it "returns true with a 'y' as input" do
        stub_input_for_gets('y')
        expect(RMagickBlend::BatchRunner::large_previous_batch?(options)).to be true
      end

      it "returns true with a 'yes' as input" do
        stub_input_for_gets('yes')
        expect(RMagickBlend::BatchRunner::large_previous_batch?(options)).to be true
      end

      it "returns false otherwise" do
        stub_input_for_gets('n')
        expect(RMagickBlend::BatchRunner::large_previous_batch?(options)).to be false

        stub_input_for_gets('no')
        expect(RMagickBlend::BatchRunner::large_previous_batch?(options)).to be false

        stub_input_for_gets('noyes')
        expect(RMagickBlend::BatchRunner::large_previous_batch?(options)).to be false
      end

    end
  end

  describe 'delete_last_batch' do
    it 'returns nil if no files found' do
      Settings.directories[:output] = '.'
      expect(RMagickBlend::BatchRunner.delete_last_batch).to be nil
    end

    it 'returns an integer if files are found and then deleted' do
      dir = "#{Dir.getwd}/spec/assets/source"
      Settings.directories[:output] = dir
      create_temp_file('source')
      expect(RMagickBlend::BatchRunner.delete_last_batch).to be_a_kind_of(Fixnum)
      clean_assets_directory('source')
    end
  end

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

  describe "history_file_exists?" do
    it "should return false if options hash is empty" do
      expect(RMagickBlend::BatchRunner.send(:history_file_exists?, {})).to be false
    end

    it "should return false if file does not exist" do
      expect(RMagickBlend::BatchRunner.send(:history_file_exists?, { directories: {output: 'non-existent-directory'} })).to be false
    end

    it "should return true if file exists" do
      create_history_file
      expect(RMagickBlend::BatchRunner.send(:history_file_exists?, { directories: {output: "#{BASE_DIR}"} })).to be true
      delete_history_file
      expect(RMagickBlend::BatchRunner.send(:history_file_exists?, { directories: {output: "#{BASE_DIR}-#{BASE_DIR}"} })).to be false
    end

  end

  def load_test_config
    test_settings_path = File.expand_path('config/test_config.yml', File.dirname(__FILE__))
    Settings.load!(test_settings_path)
  end

end
