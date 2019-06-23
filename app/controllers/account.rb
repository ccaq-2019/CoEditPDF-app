# frozen_string_literal: true

require 'roda'
require_relative './app'

module CoEditPDF
  # Base class for CoEditPDF Web Application
  class App < Roda
    route('account') do |routing|
      routing.on do
        # GET /account/[account_name]
        routing.get String do |account_name|
          account = GetAccountDetails.new(App.config).call(
            @current_account, account_name
          )

          view :account, locals: { account: account }
        rescue GetAccountDetails::InvalidAccount => e
          flash[:error] = e.message
          routing.redirect '/auth/login'
        end

        # POST /account/<token>
        routing.post String do |registration_token|
          password_check = Form::Passwords.call(routing.params)

          if password_check.failure?
            flash[:error] = Form.message_values(password_check)
            routing.redirect("/auth/register/#{registration_token}")
          end

          new_account = SecureMessage.decrypt(registration_token)
          CreateAccount.new(App.config).call(
            name: new_account['name'],
            email: new_account['email'],
            password: routing.params['password']
          )
          flash[:notice] = 'Account created! Please login'
          routing.redirect '/auth/login'
        rescue CreateAccount::InvalidAccountError => e
          flash[:error] = e.message
          routing.redirect '/auth/register'
        rescue StandardError => e
          flash[:error] = e.message
          routing.redirect("/auth/register/#{registration_token}")
        end
      end
    end
  end
end
