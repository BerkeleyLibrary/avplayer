require 'rails_helper'

describe Restrictions do
  describe :inspect do
    it 'returns the constant form' do
      Restrictions.each do |r|
        expected = "#{Restrictions}::#{r.key}"
        expect(r.inspect).to eq(expected)
      end
    end
  end
end
