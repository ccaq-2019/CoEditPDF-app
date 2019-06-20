# frozen_string_literal: true

# Service to add collaborator to pdf
class RemovePdf
  class PdfNotRemoved < StandardError; end

  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account:, pdf_id:)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .delete("#{api_url}/pdfs/#{pdf_id}")

    raise PdfNotRemoved unless response.code == 200
  end
end
