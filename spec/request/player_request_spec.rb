require 'rails_helper'
require 'health/check'

describe PlayerController, type: :request do
  describe :health do
    it 'returns the health check result' do
      expected_status = 200
      expected_json = {
        'status' => 'pass',
        'details' => Health::Check.all_checks.keys.map do |c|
          [c, 'pass']
        end.to_h
      }

      check = instance_double(Health::Check)
      allow(check).to receive(:as_json).and_return(expected_json)
      allow(check).to receive(:http_status_code).and_return(expected_status)

      allow(Health::Check).to receive(:new).and_return(check)

      get health_path
      expect(response).to have_http_status(:ok)

      expect(JSON.parse(response.body)).to eq(expected_json)
    end
  end
end
