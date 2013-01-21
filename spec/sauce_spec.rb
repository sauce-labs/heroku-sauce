require 'spec_helper'

describe Heroku::Command::Sauce do
  let(:command) { described_class.new }

  describe '#scoutup!' do
    context 'when configured' do
      before(:each) do
        @config = command.instance_variable_get(:@config)
        @config.stub(:configured? => true)
      end

      it 'should create a scout session' do
        api = command.instance_variable_get(:@sauceapi)
        api.should_receive(:create_scout_session)
        command.send(:scoutup!)
      end
    end
  end
end
