require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Eye do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ eye }).should.be.instance_of Command::Eye
      end
    end
  end
end

