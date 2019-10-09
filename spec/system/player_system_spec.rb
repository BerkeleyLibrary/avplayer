require 'rails_helper'

describe PlayerController, type: :system do

  attr_reader :marc_lookup

  before(:each) do
    @marc_lookup = Tind::MarcLookup.new(field: '901m', value: 'b23305522')
  end

  describe 'success' do
    attr_reader :tind_record

    before(:each) do

      marc_xml = File.read('spec/data/record-21178.xml')
      @tind_record = Tind.record_factory.create_record_from_xml(marc_xml)

      allow(Tind::Record).to receive(:find_any).with([marc_lookup]).and_return(tind_record)

      visit root_url + 'Pacifica/PRA_NHPRC1_AZ1084_00_000_00.mp3?901m=b23305522'
    end

    it 'displays the metadata' do
      page_body = page.body

      aggregate_failures('fields') do
        tind_record.fields.each do |f|
          expect(page).to have_content(f.label)
          if f.respond_to?(:links)
            f.links.each { |link| expect(page).to have_link(link.body, href: link.url) }
          elsif f.respond_to?(:lines)
            f.lines.each do |line|
              escaped_line = ERB::Util.html_escape(line)
              # page.has_text? chokes on long lines for some reason
              expect(page_body).to include(escaped_line)
            end
          end
        end
      end
    end
  end

  describe 'failure' do
    before(:each) do
      allow(Tind::Record).to receive(:find_any).with([marc_lookup]).and_raise(ActiveRecord::RecordNotFound)
      visit root_url + 'Pacifica/PRA_NHPRC1_AZ1084_00_000_00.mp3?901m=b23305522'
    end

    it 'displays an error page' do
      expect(page).to have_content('Record not found')
      expect(page).to have_content('901m')
      expect(page).to have_content('b23305522')
    end
  end

end
