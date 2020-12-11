require 'rails_helper'

module AvPlayer
  describe Application do
    it 'is the Rails app' do
      expect(Rails.application).to be_a(AvPlayer::Application)
    end

    describe :initialize! do
      it 'uses a custom logger' do
        expect(Rails.logger).to be_a(UCBLIT::Logging::Logger)
      end
    end

  end
end
