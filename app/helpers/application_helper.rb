module ApplicationHelper
  def calnet_link
    authenticated? ? logout_link : login_button
  end

  def logout_link(text = 'CalNet Logout')
    link_to(text, logout_path)
  end

  def calnet_omniauth_authorize_path
    '/auth/calnet'
  end

  def login_button(text = 'CalNet Login', form_class: 'calnet_auth')
    button_to(text, calnet_omniauth_authorize_path,
              params: { url: request.original_url },
              form_class:, data: { turbo: false })
  end

  def vpn_link
    link_to('use the bSecure VPN', 'https://www.lib.berkeley.edu/using-the-libraries/vpn')
  end
end
