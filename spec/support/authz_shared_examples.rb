RSpec.shared_examples 'the record is available' do |collection, record_id|
  before(:each) do
    stub_request(:head, /playlist.m3u8$/).to_return(status: 200)
  end

  it 'displays the player' do
    visit player_path(collection: collection, record_id: record_id)

    player_sections = page.find_all('section.player')
    expect(player_sections).not_to be_empty

    player_sections.each do |player_section|
      expect(player_section).to have_selector('source')
    end
  end
end

RSpec.shared_examples 'the record is not available' do |collection, record_id|
  it 'displays the "Record not available" page' do
    show_path = player_path(collection: collection, record_id: record_id)
    visit show_path

    expect(page).not_to have_selector('section.player')
    expect(page).not_to have_selector('source')

    expect(page).to have_content('Record not available')
    expect(page).to have_content(collection)
    expect(page).to have_content(record_id)

    expected_link = login_path(url: show_path)
    expect(page).to have_link(href: expected_link)
  end
end
