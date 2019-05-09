# frozen_string_literal: true

require 'roda'
require 'slim'

module CoEditPDF
  # Base class for CoEditPDF Web Application
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :public, root: 'app/presentation/public'
    plugin :multi_route

    route do |routing|
      @current_account = {
        'username': 'fake_user',
        'password': '1234'
      }
      routing.public
      routing.assets
      # routing.multi_route

      # GET /
      routing.root do
        view 'home', locals: { current_account: @current_account }
      end
    end
  end
end
