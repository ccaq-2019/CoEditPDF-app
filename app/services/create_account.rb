# frozen_string_literal: true

require 'http'

module CoEditPDF
  # Creates an account
  class CreateAccount
    class InvalidAccountError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(name:, email:, password:)
      message = { name: name, email: email, password: password }

      response = HTTP.post("#{@config.API_URL}/accounts/", json: message)

      raise InvalidAccountError unless response.code == 201
    end
  end
end
