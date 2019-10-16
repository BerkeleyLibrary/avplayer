require 'rails_helper'

describe PlayerController, type: :system do

  describe 'audio' do
    attr_reader :metadata_key
    attr_reader :metadata_record

    before(:each) do
      @metadata_key = Metadata::Key.new(source: Metadata::Source::TIND, bib_number: 'b23305522')

      marc_xml = File.read('spec/data/record-21178.xml')
      input = StringIO.new(marc_xml)
      marc_record = MARC::XMLReader.new(input).first
      @metadata_record = Metadata::Record.factory.from_marc(marc_record)

      allow(Metadata::Record).to receive(:find).with(metadata_key).and_return(metadata_record)

      visit root_url + 'Pacifica/PRA_NHPRC1_AZ1084_00_000_00.mp3/show?record_id=tind:b23305522'
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

  describe 'video' do
    attr_reader :metadata_key
    attr_reader :metadata_record

    before(:each) do
      @metadata_key = Metadata::Key.new(source: Metadata::Source::MILLENNIUM, bib_number: 'b22139658')

      marc_html = File.read('spec/data/b22139658.html')
      marc_record = Millennium::MarcExtractor.new(marc_html).extract_marc_record
      @metadata_record = Metadata::Record.factory.from_marc(marc_record)

      allow(Metadata::Record).to receive(:find).with(metadata_key).and_return(metadata_record)

      visit root_url + 'MRC/mrc/6927.mp4/show?record_id=millennium:b22139658'
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
      video_base_url = Rails.application.config.video_base_url
      path = 'mrc/6927.mp4'
      expected_url = "#{video_base_url}#{path}"

      source = find(:xpath, '//source[@src="' + expected_url + '"]')
      expect(source).not_to be_nil
    end
  end

  describe 'bad request' do
    it 'displays the "Bad request" page when no record ID is provided' do
      visit root_url + 'Pacifica/PRA_NHPRC1_AZ1084_00_000_00.mp3/show'
      expect(page).to have_content('Bad request')
    end

    it 'displays the "Bad request" page for a record ID with no source' do
      visit root_url + 'Pacifica/PRA_NHPRC1_AZ1084_00_000_00.mp3/show?record_id=b23305522'
      expect(page).to have_content('Bad request')
    end

    it 'displays the "Bad request" page for an invalid metadata source' do
      visit root_url + 'Pacifica/PRA_NHPRC1_AZ1084_00_000_00.mp3/show?record_id=oclc:b23305522'
      expect(page).to have_content('Bad request')
    end

    it 'displays the "Bad request" page for an invalid bib number' do
      visit root_url + 'Pacifica/PRA_NHPRC1_AZ1084_00_000_00.mp3/show?record_id=tind'
      expect(page).to have_content('Bad request')
    end
  end

  describe 'record not found' do
    attr_reader :metadata_key

    before(:each) do
      @metadata_key = Metadata::Key.new(source: Metadata::Source::TIND, bib_number: 'b23305522')
    end

    it 'displays the "Record not found" page when records aren\'t found' do
      allow(Metadata::Record).to receive(:find).with(metadata_key).and_raise(ActiveRecord::RecordNotFound)
      visit root_url + 'Pacifica/PRA_NHPRC1_AZ1084_00_000_00.mp3/show?record_id=tind:b23305522'
      expect(page).to have_content('Record not found')
      expect(page).to have_content('tind')
      expect(page).to have_content('b23305522')
    end

    it 'displays the "Record not found" page for UCB-only records' do
      metadata_key = Metadata::Key.new(source: Metadata::Source::TIND, bib_number: 'b18538031')

      metadata_record = instance_double(Metadata::Record)
      allow(metadata_record).to receive(:restrictions).and_return(Restrictions::UCB_IP)
      allow(Metadata::Record).to receive(:find).with(metadata_key).and_return(metadata_record)

      visit root_url + 'City/CA01476a.mp3%3BCA01476b.mp3/show?record_id=tind:b18538031'

      expect(page).to have_content('Record not found')
      expect(page).to have_content('City')
      expect(page).to have_content('CA01476a.mp3')
      expect(page).to have_content('CA01476b.mp3')
      expect(page).to have_content('tind:b18538031')
    end

    it 'displays the "Record not found" page for an invalid path' do
      visit root_url + 'City/CA01476b.qt/show?record_id=millennium:b18538031'

      expect(page).to have_content('Record not found')
      expect(page).to have_content('City')
      expect(page).to have_content('CA01476b.qt')
      expect(page).to have_content('millennium:b18538031')
    end

    it 'displays the "Record not found" page when one of several paths is invalid' do
      visit root_url + 'City/CA01476a.mp3%3BCA01476b.qt/show?record_id=tind:b18538031'

      expect(page).to have_content('Record not found')
      expect(page).to have_content('City')
      %w[CA01476a.mp3 CA01476b.qt].each do |path|
        expect(page).to have_content(path)
      end

      expect(page).to have_content('tind:b18538031')
    end
  end
end
