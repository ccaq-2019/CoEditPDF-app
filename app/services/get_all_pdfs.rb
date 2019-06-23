# frozen_string_literal: true

require 'http'

# Returns all pdfs belonging to an account
class GetAllPdfs
  def initialize(config)
    @config = config
  end

  def call(current_account)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
      .get("#{@config.API_URL}/pdfs")

    response.code == 200 ? response.parse['data'] : nil
  end
end
