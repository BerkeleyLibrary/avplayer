require 'av/core'

module Error
  class RecordNotAvailable < ApplicationError
    # TODO: use Rails i18n
    MSG_FMT_CALNET_ONLY = 'Record %s is for UC Berkeley faculty, staff, and students only'.freeze
    MSG_FMT_UCB_ACCESS = 'Record %s is UCB access only'.freeze

    attr_reader :record

    def initialize(arg)
      if arg.is_a?(AV::Record)
        super(message_for(arg))
        @record = arg
      else
        super(arg.to_s)
      end
    end

    class << self
      def exception(arg)
        return self if arg.nil? || equal?(arg)

        RecordNotAvailable.new(arg)
      end
    end

    private

    def message_for(record)
      rec_id = record.record_id
      return format(MSG_FMT_CALNET_ONLY, rec_id) if record.calnet_only?
      return format(MSG_FMT_UCB_ACCESS, rec_id) if record.ucb_access?
    end
  end
end
