class ApplicationController < ActionController::Base

  # ------------------------------
  # Authentication/Authorization

  # # Require that the current user be authenticated
  # #
  # # @return [void]
  # # @raise [Error::UnauthorizedError] If the user is not
  # #   authenticated
  # def authenticate!
  #   raise Error::UnauthorizedError, "Endpoint #{controller_name}/#{action_name} requires authentication" unless authenticated?
  #
  #   yield current_user if block_given?
  # end

  # Return whether the current user is authenticated
  #
  # @return [Boolean]
  def authenticated?
    current_user.authenticated?
  end
  helper_method :authenticated?

  # Return whether the current user is authorized
  #
  # @return [Boolean]
  def authorized?
    current_user.authorized?
  end
  helper_method :authorized?

  # Return the current user
  #
  # This always returns a user object, even if the user isn't authenticated.
  # Call {User#authenticated?} to determine if they were actually auth'd, or
  # use the shortcut {#authenticated?} to see if the current user is auth'd.
  #
  # @return [User]
  def current_user
    @current_user ||= User.from_session(session)
  end
  helper_method :current_user

  # Sign in the user by storing their data in the session
  #
  # @param [User]
  # @return [void]
  def sign_in(user)
    session[:user] = user
  end

  # Sign out the current user by clearing all session data
  #
  # @return [void]
  def sign_out
    reset_session
  end

  def ucb_request?
    UcbIpService.ucb_request?(request)
  end
  helper_method :ucb_request?

  def external_request?
    !ucb_request?
  end
end
