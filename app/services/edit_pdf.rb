# frozen_string_literal: true

require 'http'

module CoEditPDF
  # Edit the PDF
  class EditPdf
    class EditError < StandardError; end

    def initialize(config)
      @api_url = config.API_URL
    end

    def call(current_account:, pdf_id:, edit_data:)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
        .put("#{@api_url}/pdfs/#{pdf_id}/edit",
             json: { edit_data: edit_data })

      raise EditError unless response.code == 200
    end
  end
end
