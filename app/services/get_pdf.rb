# frozen_string_literal: true

require 'http'
require 'base64'

# Returns all pdfs belonging to an account
class GetPdf
  def initialize(config)
    @config = config
  end

  def call(current_account, pdf_id)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/pdfs/#{pdf_id}")

    response.code == 200 ? response.parse['data'] : nil
  end
end
