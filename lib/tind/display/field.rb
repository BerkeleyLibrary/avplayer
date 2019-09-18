module TIND
  module Display
    class Field

      TAG_SUFFIX_RE = /_([0-9]{3}[a-z0-9%]{2})/

      def initialize(label:, marc_query:, subfields_separator: ' ', order:)

      end

      class << self
        def from_json(json_field)
          params = json_field['params']
          return unless params

          labels = json_field['labels']
          return unless labels

          label_en = labels['en']
          return unless label_en

          marc_tag = find_marc_tag(json_field)
          return unless marc_tag

          marc_query = TIND::Field.new(
              marc_tag: marc_tag,
              subfield_order: params['subfield_order']
          )

          order = json_field['order']

          Field.new(
              label: label_en,
              marc_query: marc_query,
              subfields_separator: params['subfields_separator'],
              order: order
          )
        end

        def find_marc_tag(json)
          params = json['params']

          if (tag = params['tag'])
            return tag unless tag.blank?
          end

          if (fields = params['fields'])
            return fields unless fields.blank?
          end

          if (tag = params['tag_1'])
            return tag unless tag.blank?
          end

          if (tag = params['tag_2'])
            return tag unless tag.blank?
          end

          if (input_tag = params['input_tag'])
            return "#{input_tag}#{params['input_subfield']}"
          end

          nil
        end

        def default_fields
          [
              Field.new(label: 'Creator', marc_query: TIND::Field.new(marc_tag: '700%%'), order: 2),
              Field.new(label: 'Creator', marc_query: TIND::Field.new(marc_tag: '710%%'), order: 2),
              Field.new(label: 'Linked Resources', marc_query: TIND::Field.new(marc_tag: '85641'), order: 11),
          ]
        end
      end
    end

  end
end
