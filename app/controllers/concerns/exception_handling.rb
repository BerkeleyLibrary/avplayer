# TODO: use a dynamic error controller so we can rescue from things like RoutingError
#       see http://web.archive.org/web/20141231234828/http://wearestac.com/blog/dynamic-error-pages-in-rails
module ExceptionHandling
  extend ActiveSupport::Concern

  included do
    # Order exceptions from most generic to most specific.

    rescue_from Error::ForbiddenError do |error|
      logger.error(error)
      render :forbidden, status: :forbidden, locals: { exception: error }
    end

    rescue_from Error::UnauthorizedError do |error|
      # this isn't really an error condition, it just means the user's
      # not logged in, so we don't need the full stack trace etc.
      logger.info(error.to_s)
      redirect_to login_path(url: request.fullpath)
    end
  end

end
