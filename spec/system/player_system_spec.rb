require 'rails_helper'

describe PlayerController, type: :system do

  attr_reader :marc_lookup

  before(:each) do
    @marc_lookup = Metadata::Key.new(field: '901m', value: 'b23305522')
  end

  describe 'success' do
    attr_reader :metadata_record

    before(:each) do

      marc_xml = File.read('spec/data/record-21178.xml')
      input = StringIO.new(marc_xml)
      marc_record = MARC::XMLReader.new(input).first
      @metadata_record = Metadata::Record.factory.from_marc(marc_record)

      allow(Metadata::Record).to receive(:find_any).with([marc_lookup]).and_return(metadata_record)

      visit root_url + 'Pacifica/PRA_NHPRC1_AZ1084_00_000_00.mp3?901m=b23305522'
    end

    it 'displays the metadata' do
      page_body = page.body

      aggregate_failures('fields') do
        metadata_record.fields.each do |f|
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

    it 'displays the player' do
      wowza_base_url = Rails.application.config.wowza_base_url
      collection = 'Pacifica'
      path = 'PRA_NHPRC1_AZ1084_00_000_00.mp3'
      expected_url = "#{wowza_base_url}#{collection}/mp3:#{path}/playlist.m3u8"

      source = find(:xpath, '//source[@src="' + expected_url + '"]')
      expect(source).not_to be_nil
    end
  end

  describe 'failure' do
    it 'displays the "Record not found" page when records aren\'t found' do
      allow(Metadata::Record).to receive(:find_any).with([marc_lookup]).and_raise(ActiveRecord::RecordNotFound)
      visit root_url + 'Pacifica/PRA_NHPRC1_AZ1084_00_000_00.mp3?901m=b23305522'
      expect(page).to have_content('Record not found')
      expect(page).to have_content('901m')
      expect(page).to have_content('b23305522')
    end

    it 'displays the "Record not found" page for UCB-only records' do
      marc_lookup = Metadata::Key.new(field: '901m', value: 'b18538031')

      metadata_record = instance_double(Metadata::Record)
      allow(metadata_record).to receive(:restrictions).and_return(Restrictions::UCB_IP)
      allow(Metadata::Record).to receive(:find_any).with([marc_lookup]).and_return(metadata_record)

      visit root_url + 'City/CA01476a.mp3%3BCA01476b.mp3?901m=b18538031'

      expect(page).to have_content('Record not found')
      expect(page).to have_content('901m')
      expect(page).to have_content('b18538031')
    end

    it 'displays the "Record not found" page for an invalid path' do
      visit root_url + 'City/CA01476b.qt?901m=b18538031'

      # TODO: include paths in error response
      expect(page).to have_content('Record not found')
      expect(page).to have_content('901m')
      expect(page).to have_content('b18538031')
    end

    it 'displays the "Record not found" page when one of several paths is invalid' do
      visit root_url + 'City/CA01476a.mp3%3BCA01476b.qt?901m=b18538031'

      # TODO: include paths in error response
      expect(page).to have_content('Record not found')
      expect(page).to have_content('901m')
      expect(page).to have_content('b18538031')
    end
  end
end
