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
          if @current_account && @current_account["name"] == account_name
            view :account, locals: { current_account: @current_account }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
