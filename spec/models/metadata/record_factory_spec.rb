require 'rails_helper'
require 'marc'
require 'json'

module Metadata
  describe RecordFactory do
    attr_reader :factory

    before(:all) do
      json_document = File.read('spec/data/tind_html_metadata_da.json')
      json = JSON.parse(json_document)
      @factory = RecordFactory.from_json(json)
    end

    describe :from_json do

      it 'reads JSON' do
        expect(factory).to be_a(RecordFactory)
      end

      # rubocop:disable Metrics/LineLength
      it 'parses the fields' do
        expected_fields = [
          { order: 1, tag: '245', ind_1: nil, ind_2: nil, subfield: nil, label: 'Title', subfields_separator: ' ', subfield_order: ['a'] },
          { order: 2, tag: '520', ind_1: nil, ind_2: nil, subfield: nil, label: 'Description', subfields_separator: ' ', subfield_order: ['a'] },
          { order: 2, tag: '700', ind_1: nil, ind_2: nil, subfield: nil, label: 'Creator', subfields_separator: ' ', subfield_order: nil },
          { order: 2, tag: '710', ind_1: nil, ind_2: nil, subfield: nil, label: 'Creator', subfields_separator: ' ', subfield_order: nil },
          { order: 3, tag: '720', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Contributor', subfields_separator: ' ', subfield_order: nil },
          { order: 4, tag: '711', ind_1: nil, ind_2: nil, subfield: nil, label: 'Meeting Name', subfields_separator: ', ', subfield_order: %w[a n d c] },
          { order: 6, tag: '246', ind_1: nil, ind_2: nil, subfield: nil, label: 'Variant Title', subfields_separator: ', ', subfield_order: nil },
          { order: 9, tag: '260', ind_1: nil, ind_2: nil, subfield: nil, label: 'Published', subfields_separator: ', ', subfield_order: nil },
          { order: 10, tag: '250', ind_1: nil, ind_2: nil, subfield: nil, label: 'Edition', subfields_separator: ', ', subfield_order: nil },
          { order: 11, tag: '856', ind_1: '4', ind_2: '1', subfield: nil, label: 'Linked Resources', subfields_separator: ' ', subfield_order: nil },
          { order: 14, tag: '982', ind_1: nil, ind_2: nil, subfield: 'b', label: 'Full Collection Name', subfields_separator: ', ', subfield_order: nil },
          { order: 15, tag: '490', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Series', subfields_separator: ', ', subfield_order: nil },
          { order: 16, tag: '020', ind_1: nil, ind_2: nil, subfield: nil, label: 'ISBN', subfields_separator: ' ', subfield_order: nil },
          { order: 17, tag: '022', ind_1: nil, ind_2: nil, subfield: nil, label: 'ISSN', subfields_separator: ' ', subfield_order: nil },
          { order: 20, tag: '024', ind_1: '8', ind_2: '0', subfield: 'a', label: 'Other Identifiers', subfields_separator: ' ', subfield_order: nil },
          { order: 21, tag: '600', ind_1: nil, ind_2: nil, subfield: nil, label: 'Subject (Person)', subfields_separator: ' ', subfield_order: nil },
          { order: 22, tag: '610', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Subject (Corporate)', subfields_separator: ' ', subfield_order: nil },
          { order: 23, tag: '650', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Subject (Topic)', subfields_separator: ' ', subfield_order: nil },
          { order: 24, tag: '611', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Subject (Meeting Name)', subfields_separator: ' ', subfield_order: nil },
          { order: 25, tag: '630', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Subject (Uniform Title)', subfields_separator: ' ', subfield_order: nil },
          { order: 27, tag: '651', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Geographic Coverage', subfields_separator: ' ', subfield_order: nil },
          { order: 28, tag: '508', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Credits', subfields_separator: ', ', subfield_order: nil },
          { order: 29, tag: '255', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Scale', subfields_separator: ', ', subfield_order: nil },
          { order: 30, tag: '255', ind_1: nil, ind_2: nil, subfield: 'b', label: 'Projection', subfields_separator: ', ', subfield_order: nil },
          { order: 31, tag: '255', ind_1: nil, ind_2: nil, subfield: 'c', label: 'Coordinates', subfields_separator: ', ', subfield_order: nil },
          { order: 32, tag: '392', ind_1: nil, ind_2: nil, subfield: 'c', label: 'Sheet Name', subfields_separator: ', ', subfield_order: nil },
          { order: 33, tag: '392', ind_1: nil, ind_2: nil, subfield: 'd', label: 'Sheet Number', subfields_separator: ', ', subfield_order: nil },
          { order: 34, tag: '336', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Type', subfields_separator: ', ', subfield_order: nil },
          { order: 35, tag: '655', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Format', subfields_separator: ' ', subfield_order: nil },
          { order: 36, tag: '300', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Extent', subfields_separator: ' ', subfield_order: nil },
          { order: 37, tag: '300', ind_1: nil, ind_2: nil, subfield: 'b', label: 'Other Physical Details', subfields_separator: ' ', subfield_order: nil },
          { order: 38, tag: '300', ind_1: nil, ind_2: nil, subfield: 'c', label: 'Dimensions', subfields_separator: ' ', subfield_order: nil },
          { order: 39, tag: '306', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Duration', subfields_separator: ', ', subfield_order: nil },
          { order: 40, tag: '340', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Physical Medium', subfields_separator: ' ', subfield_order: nil },
          { order: 41, tag: '340', ind_1: nil, ind_2: nil, subfield: 'g', label: 'Colour/ B&W', subfields_separator: ' ', subfield_order: nil },
          { order: 42, tag: '340', ind_1: nil, ind_2: nil, subfield: 'i', label: 'Technical Specifications', subfields_separator: ' ', subfield_order: nil },
          { order: 43, tag: '546', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Language', subfields_separator: ' ', subfield_order: nil },
          { order: 45, tag: '533', ind_1: nil, ind_2: nil, subfield: 'c', label: 'Repository', subfields_separator: ' ', subfield_order: nil },
          { order: 46, tag: '773', ind_1: nil, ind_2: nil, subfield: nil, label: 'In', subfields_separator: ', ', subfield_order: nil },
          { order: 47, tag: '773', ind_1: nil, ind_2: '8', subfield: 'i', label: 'Digital Collection', subfields_separator: ' ', subfield_order: nil },
          { order: 48, tag: '363', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Volume', subfields_separator: ' ', subfield_order: nil },
          { order: 49, tag: '363', ind_1: nil, ind_2: nil, subfield: 'b', label: 'Issue', subfields_separator: ' ', subfield_order: nil },
          { order: 51, tag: '787', ind_1: nil, ind_2: '8', subfield: 'i', label: 'Digital Exhibit', subfields_separator: ' ', subfield_order: nil },
          { order: 52, tag: '786', ind_1: nil, ind_2: '8', subfield: 'i', label: 'Collection in Repository', subfields_separator: ' ', subfield_order: nil },
          { order: 53, tag: '740', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Text on Picture', subfields_separator: ', ', subfield_order: nil },
          { order: 54, tag: '751', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Mentioned Place', subfields_separator: ', ', subfield_order: nil },
          { order: 56, tag: '789', ind_1: nil, ind_2: nil, subfield: nil, label: 'Related Resource', subfields_separator: ' ', subfield_order: nil },
          { order: 57, tag: '790', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Contributing Institution', subfields_separator: ' ', subfield_order: nil },
          { order: 58, tag: '852', ind_1: nil, ind_2: nil, subfield: nil, label: 'Archive', subfields_separator: '; ', subfield_order: %w[a b c h] },
          { order: 60, tag: '500', ind_1: nil, ind_2: nil, subfield: nil, label: 'Note', subfields_separator: ', ', subfield_order: nil },
          { order: 61, tag: '502', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Dissertation/Thesis Note', subfields_separator: ', ', subfield_order: nil },
          { order: 63, tag: '522', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Coverage', subfields_separator: ', ', subfield_order: nil },
          { order: 64, tag: '524', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Preferred Citation', subfields_separator: ', ', subfield_order: nil },
          { order: 65, tag: '533', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Reproduction Note', subfields_separator: ', ', subfield_order: nil },
          { order: 66, tag: '536', ind_1: nil, ind_2: nil, subfield: nil, label: 'Grant Information', subfields_separator: ' ', subfield_order: %w[a o m n] },
          { order: 67, tag: '541', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Provenance', subfields_separator: ', ', subfield_order: nil },
          { order: 68, tag: '541', ind_1: nil, ind_2: nil, subfield: 'c', label: 'Acquisition Method', subfields_separator: ', ', subfield_order: nil },
          { order: 69, tag: '541', ind_1: nil, ind_2: nil, subfield: 'd', label: 'Year of Admission', subfields_separator: ', ', subfield_order: nil },
          { order: 70, tag: '541', ind_1: nil, ind_2: nil, subfield: 'f', label: 'Owner', subfields_separator: ', ', subfield_order: nil },
          { order: 71, tag: '542', ind_1: nil, ind_2: nil, subfield: 'f', label: 'Standard Rights Statement', subfields_separator: ' ', subfield_order: nil },
          { order: 72, tag: '545', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Note', subfields_separator: ', ', subfield_order: nil },
          { order: 73, tag: '542', ind_1: nil, ind_2: nil, subfield: 'u', label: 'Standard Rights Statement', subfields_separator: ' ', subfield_order: nil },
          { order: 85, tag: '540', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Usage Statement', subfields_separator: ', ', subfield_order: nil },
          { order: 86, tag: '991', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Access', subfields_separator: ', ', subfield_order: nil },
          { order: 89, tag: '982', ind_1: nil, ind_2: nil, subfield: 'a', label: 'Collection', subfields_separator: ' ', subfield_order: nil }
        ]
        factories = factory.field_factories
        expect(factories.size).to eq(expected_fields.size)
        factories.each_with_index do |factory, index|
          exp = expected_fields[index]
          %i[order tag ind_1 ind_2 subfield label subfields_separator subfield_order].each do |attr|
            actual = factory.send(attr)
            expected = exp[attr]

            msg_actual = actual.is_a?(String) ? "'#{actual}'" : (actual || 'nil')
            msg_expected = expected.is_a?(String) ? "'#{expected}'" : (expected || 'nil')

            expect(actual).to eq(expected), "expected #{attr} #{msg_expected} at index #{index}, got #{msg_actual}"
          end
        end
      end
      # rubocop:enable Metrics/LineLength

      it 'filters out duplicate fields' do
        all_542u = factory.field_factories.find_all { |f| f.tag == '542' && f.subfield == 'u' }
        expect(all_542u.size).to eq(1)
      end
    end

    describe :from_marc do
      attr_reader :metadata_record

      before(:all) do
        marc_xml = File.read('spec/data/record-21178.xml')
        input = StringIO.new(marc_xml)
        marc_record = MARC::XMLReader.new(input).first
        @metadata_record = factory.from_marc(marc_record)
      end

      it 'creates a record' do
        expect(metadata_record).not_to be_nil
        expect(metadata_record.title).to eq('Wanda Coleman')
      end

      # rubocop:disable Metrics/LineLength
      it 'parses the fields' do
        expected = [
          'Title (245): Wanda Coleman',
          'Description (520): Poet Opal Palmer Adisa interviews writer/poet Wanda Coleman, author of Mad Dog, Black Lady, African Sleeping Sickness and Hand Dance, among other books. Coleman discusses when she found her poetic voice, talks about the function of poetry, her personal encounters with anti-Black discrimination, and about the reluctance of white liberals to discuss issues that affect the Black community. She also talks about the plight of the African American community in South Central Los Angeles. The poems Coleman reads are A civilized plague, David Polion, Notes of a cultural terrorist and Jazz wazz.',
          'Creator (700): Coleman, Wanda. interviewee. Adisa, Opal Palmer. interviewer.',
          'Creator (710): Pacifica Radio Archive. KPFA (Radio station : Berkeley, Calif.).',
          'Published (260): Los Angeles , Pacifica Radio Archives, 1993.',
          'Linked Resources (856): [View library catalog record.](http://oskicat.berkeley.edu/record=b23305522)',
          'Full Collection Name (982): Pacifica Radio Archives Social Activism Sound Recording Project',
          'Type (336): Audio',
          'Extent (300): 1 online resource.',
          'Archive (852): The Library',
          "Grant Information (536): Sponsored by the National Historical Publications and Records Commission at the National Archives and Records Administration as part of Pacifica's American Women Making History and Culture: 1963-1982 grant preservation project.",
          'Usage Statement (540): RESTRICTED.  Permissions, licensing requests, and all other inquiries should be directed in writing to: Director of the Archives, Pacifica Radio Archives, 3729 Cahuenga Blvd. West, North Hollywood, CA 91604, 800-735-0230 x 263, fax 818-506-1084, info@pacificaradioarchives.org, http://www.pacificaradioarchives.org',
          'Collection (982): Pacifica Radio Archives'
        ]
        fields = metadata_record.fields
        expect(fields.size).to eq(expected.size)
        fields.each_with_index do |f, i|
          expect(f.to_s.gsub('|', '')).to eq(expected[i])
        end
      end
      # rubocop:enable Metrics/LineLength

    end

    describe :restrictions do
      attr_reader :expected

      before(:each) do
        @expected = {
          'b22139658' => Restrictions::PUBLIC,
          'b23305516' => Restrictions::PUBLIC,
          'b23305522' => Restrictions::PUBLIC,
          'b18538031' => Restrictions::UCB_IP,
          'b24071548' => Restrictions::UCB_IP
        }
      end

      it 'determines restrictions correctly for Millennium records' do
        aggregate_failures 'Millennium records' do
          expected.each do |bib, r_expected|
            marc_url = Millennium.marc_url_for(bib)
            record_html = "spec/data/#{bib}.html"
            stub_request(:get, marc_url).to_return(status: 200, body: File.read(record_html))
            record = Record.find_millennium(bib)
            r_actual = record.restrictions
            expect(r_actual).to eq(r_expected), "#{bib}: expected #{r_actual}, got #{r_expected}"
          end
        end
      end

      it 'determines restrictions correctly for TIND records' do
        tind_ids = {
          # Note we don't have a TIND record for b22139658
          'b18538031' => 4188,
          'b23305516' => 19_816,
          'b23305522' => 21_178,
          'b24071548' => 4959
        }
        aggregate_failures 'TIND records' do
          tind_ids.each do |bib, tind_id|
            record_xml = "spec/data/record-#{tind_id}.xml"
            marc_url = Tind.marc_url_for(tind_id)
            stub_request(:get, marc_url).to_return(status: 200, body: File.read(record_xml))
            record = Record.find_tind(tind_id)
            r_actual = record.restrictions
            r_expected = expected[bib]
            expect(r_actual).to eq(r_expected), "#{bib}: expected #{r_actual}, got #{r_expected}"
          end
        end
      end
    end
  end
end
