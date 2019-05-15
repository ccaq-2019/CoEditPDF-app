# frozen_string_literal: true

require 'roda'
require 'econfig'
require 'rack/ssl-enforcer'
require_relative '../require_app'

module CoEditPDF
  # Configuration for the API
  class App < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    configure :production do
      use Rack::SslEnforcer, hsts: true
    end

    configure :development, :test do
      require 'pry'

      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./specs/test_load_all'
      end
    end
  end
end
