RSpec.shared_examples 'the record is available' do |collection, record_id|
  before do
    stub_request(:head, /playlist.m3u8$/).to_return(status: 200)
  end

  it 'displays the player' do
    visit player_path(collection:, record_id:)

    player_sections = page.find_all('section.player')
    expect(player_sections).not_to be_empty

    player_sections.each do |player_section|
      expect(player_section).to have_selector('source')
    end
  end
end

RSpec.shared_examples 'access to the record is restricted' do |collection, record_id|
  it 'displays the "Access restricted" page' do
    show_path = player_path(collection:, record_id:)
    visit show_path

    expect(page).not_to have_selector('section.player')
    expect(page).not_to have_selector('source')

    expect(page).to have_content('Access to this record is restricted')
    expect(page).to have_content(collection)
    expect(page).to have_content(record_id)

    show_url = player_url(collection:, record_id:)
    expect(page).to have_link(href: login_path(url: show_url))
  end
end

RSpec.shared_examples 'available from UCB IPs' do |collection, record_id|
  it 'displays the VPN link' do
    visit player_path(collection:, record_id:)

    expected_link = 'https://www.lib.berkeley.edu/using-the-libraries/vpn'
    expect(page).to have_link(href: expected_link)
  end
end

RSpec.shared_examples 'CalNet only'  do |collection, record_id|
  it 'does not display the VPN link' do
    visit player_path(collection:, record_id:)

    expected_link = 'https://www.lib.berkeley.edu/using-the-libraries/vpn'
    expect(page).not_to have_link(href: expected_link)
  end
end
