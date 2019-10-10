class ApplicationController < ActionController::Base
  def log
    Rails.logger
  end
end
