module ApplicationHelper
  def calnet_link
    authenticated? ? logout_link : login_link
  end

  def logout_link(text = 'CalNet Logout')
    link_to(text, logout_path)
  end

  def login_link(text = 'CalNet Login')
    link_to(text, login_path(url: request.original_url))
  end

  def vpn_link
    link_to('use the bSecure VPN', 'https://www.lib.berkeley.edu/using-the-libraries/vpn')
  end
end
