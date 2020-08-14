require 'rails_helper'

require 'health/status'

module Health

  describe Status do
    # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    describe '&' do
      it 'handles nil' do
        expect(Status::PASS & nil).to eq(Status::PASS)
      end

      it 'handles self' do
        expect(Status::PASS & Status::PASS).to eq(Status::PASS)
        expect(Status::WARN & Status::WARN).to eq(Status::WARN)
      end

      it 'respects order' do
        expect(Status::WARN & Status::PASS).to eq(Status::WARN)
        expect(Status::PASS & Status::WARN).to eq(Status::WARN)
      end

      it 'supports &=' do
        status = Status::PASS
        status &= Status::WARN
        expect(status).to eq(Status::WARN)
      end
    end
    # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

    describe :http_status_code do
      it 'returns a unique, ascending int status' do
        last_status = 0
        Status.each do |s|
          status = s.http_status_code
          expect(status).to be_a(Integer)
          expect(status).to be > last_status
          last_status = status
        end
      end
    end
  end
end
