describe Fastlane::Actions::UploadToSimplemdmAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The simplemdm plugin is working!")

      Fastlane::Actions::UploadToSimplemdmAction.run
    end
  end
end
