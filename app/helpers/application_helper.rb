module ApplicationHelper
  def logout_link
    link_to 'CalNet Logout', logout_path if authenticated?
  end

  def login_link
    link_to('log in with Calnet', login_path(url: request.fullpath))
  end

  def vpn_link
    link_to('use the bSecure VPN', 'https://www.lib.berkeley.edu/using-the-libraries/vpn')
  end
end
