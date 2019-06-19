# frozen_string_literal: true

# Service to add collaborator to pdf
class AddCollaborator
  class CollaboratorNotAdded < StandardError; end

  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account:, collaborator:, pdf_id:)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .put("#{api_url}/pdfs/#{pdf_id}/collaborators",
                        json: { collaborator_email:
                                collaborator[:collaborator_email] })

    raise CollaboratorNotAdded unless response.code == 200
  end
end
