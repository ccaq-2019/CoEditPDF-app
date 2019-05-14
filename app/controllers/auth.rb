# frozen_string_literal: true

require 'roda'
require_relative './app'

module CoEditPDF
  # Base class for CoEditPDF Web Application
  class App < Roda
    route('auth') do |routing|
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login
        end
      end

      routing.on 'logout' do
        # GET /auth/logout
        routing.get do
          routing.redirect @login_route
        end
      end
    end
  end
end
