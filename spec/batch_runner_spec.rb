require 'spec_helper'
require 'rmagick-blend/batch_runner'

describe "Batch Runner" do
  describe "large_previous_batch?" do
    options = { directories: { output: BASE_DIR } }

    describe "without history file" do
      before { delete_history_file }

      it "still returns false with a 'y' as input" do
        stub_input_for_gets('y')
        RMagickBlend::BatchRunner::large_previous_batch?(options).should be_false
      end

      it "still returns false with a 'yes' as input" do
        stub_input_for_gets('yes')
        RMagickBlend::BatchRunner::large_previous_batch?(options).should be_false
      end
    end

    describe "with history file" do
      before :each do 
        create_history_file
        Settings = double("behavior", behavior: {  } )
      end

      after :each do delete_history_file; end

      it "returns false with empty input" do
        stub_input_for_gets('')
        RMagickBlend::BatchRunner::large_previous_batch?(options).should be_false
      end

      it "returns true with a 'y' as input" do
        stub_input_for_gets('y')
        RMagickBlend::BatchRunner::large_previous_batch?(options).should be_true
      end

      it "returns true with a 'yes' as input" do
        stub_input_for_gets('yes')
        RMagickBlend::BatchRunner::large_previous_batch?(options).should be_true
      end

      it "returns false otherwise" do
        stub_input_for_gets('n')
        RMagickBlend::BatchRunner::large_previous_batch?(options).should be_false

        stub_input_for_gets('no')
        RMagickBlend::BatchRunner::large_previous_batch?(options).should be_false

        stub_input_for_gets('noyes')
        RMagickBlend::BatchRunner::large_previous_batch?(options).should be_false
      end

    end
  end

  describe 'delete_last_batch' do
    it 'returns nil if no files found' do
      Settings = double("directories", directories: { output: '.' } )
      RMagickBlend::BatchRunner.delete_last_batch.should be_nil
    end

    it 'returns an integer if files are found and then deleted' do
      dir = "#{Dir.getwd}/spec/assets/source"
      Settings = double("directories", directories: { output: dir } )
      create_temp_file('source')
      RMagickBlend::BatchRunner.delete_last_batch.should be_a_kind_of(Fixnum)
      clean_assets_directory('source')
    end
  end

  describe 'open_files_at_end' do
    it "should return false if suppress option is set" do
      RMagickBlend::BatchRunner::open_files_at_end?(suppress: true).should be_false
    end

    it "should return true if force option is set" do
      Settings = double("directories", directories: { output: '.' }, constant_values: { num_files_before_warn: 10 } )
      RMagickBlend::BatchRunner::open_files_at_end?(force: true).should be_true
    end

    it "suppress option should override force option" do
      RMagickBlend::BatchRunner::open_files_at_end?(suppress: true, force: true).should be_false
    end
  end

  describe "history_file_exists?" do
    it "should return false if options hash is empty" do
      RMagickBlend::BatchRunner.send(:history_file_exists?, {}).should be_false
    end

    it "should return false if file does not exist" do
      RMagickBlend::BatchRunner.send(:history_file_exists?, { directories: {output: 'non-existent-directory'} }).should be_false
    end

    it "should return true if file exists" do
      create_history_file
      RMagickBlend::BatchRunner.send(:history_file_exists?, { directories: {output: "#{BASE_DIR}"} }).should be_true
      delete_history_file
      RMagickBlend::BatchRunner.send(:history_file_exists?, { directories: {output: "#{BASE_DIR}-#{BASE_DIR}"} }).should be_false
    end

  end
end
