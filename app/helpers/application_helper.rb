module ApplicationHelper
  def logout_link
    link_to 'CalNet Logout', logout_path if authenticated?
  end
end
