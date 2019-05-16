# frozen_string_literal: true

require 'roda'
require_relative './app'

module CoEditPDF
  # Base class for CoEditPDF Web Application
  class App < Roda
    route('auth') do |routing|
      @login_route = '/auth/login'
      routing.on 'login' do
        # GET /auth/login
        routing.get do
          view :login
        end

        # POST /auth/login
        routing.post do
          account_data = JsonRequestBody.symbolize(routing.params)
          account = AuthenticateAccount.new(App.config).call(account_data)

          SecureSession.new(session).set(:current_account, account)
          flash[:notice] = "Welcome back #{account['name']}!"
          routing.redirect '/'
        rescue AuthenticateAccount::UnauthorizedError
          flash[:error] = 'Username and password did not match our records'
          response.status = 403
          routing.redirect @login_route
        rescue StandardError => e
          puts "LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end

      @logout_route = '/auth/logout'
      routing.is 'logout' do
        # GET /auth/logout
        routing.get do
          SecureSession.new(session).delete(:current_account)
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      routing.is 'register' do
        # GET /auth/register
        routing.get do
          view :register
        end

        # POST /auth/register
        routing.post do
          account_data = JsonRequestBody.symbolize(routing.params)
          CreateAccount.new(App.config).call(account_data)

          flash[:notice] = 'Please login with your new account'
          routing.redirect '/auth/login'
        rescue StandardError => e
          puts "ERROR CREATING ACCOUNT: #{e.inspect}"
          puts e.backtrace
          flash[:error] = 'Could not create account'
          routing.redirect @register_route
        end
      end
    end
  end
end
