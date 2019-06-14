# frozen_string_literal: true

require 'http'

module CoEditPDF
  # Creates an account
  class UploadPdf
    class UploadError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(current_account:, filename:, content:)
      content = Base64.strict_encode64(content)
      message = { filename: filename, content: content }

      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post("#{@config.API_URL}/pdfs/", json: message)

      raise UploadError unless response.code == 201
    end
  end
end
