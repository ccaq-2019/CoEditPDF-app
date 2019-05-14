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

        # POST /auth/login
        routing.post do
          account = AuthenticateAccount.new(App.config).call(
            name: routing.params['username'],
            password: routing.params['password']
          )

          session[:current_account] = account
          routing.redirect '/'
        rescue StandardError
          routing.redirect @login_route
        end
      end

      routing.on 'logout' do
        # GET /auth/logout
        routing.get do
          session[:current_account] = nil
          routing.redirect @login_route
        end
      end
    end
  end
end
