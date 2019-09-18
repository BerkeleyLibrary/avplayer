
module TIND::Display
  class Config
    class << self
      def from_json(json)
        fields = Field.default_fields
        json['config'].each do |json_field|
          next unless json_field['visible']
          fields << Field.from_json(json_field)
        end
      end
    end
  end

end
