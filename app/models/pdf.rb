# frozen_string_literal: true

module CoEditPDF
  # Behaviors of the currently logged in account
  class Pdf
    attr_reader :id, :filename,
                :owner, :collaborators

    def initialize(pdf_info)
      process_attributes(pdf_info['attributes'])
      process_relationships(pdf_info['relationships'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @filename = attributes['filename']
    end

    def process_relationships(relationships)
      return unless relationships

      @owner = Account.new(relationships['owner'])
      @collaborators = process_collaborators(relationships['collaborators'])
    end

    def process_collaborators(collaborators)
      return nil unless collaborators

      collaborators.map { |account_info| Account.new(account_info) }
    end
  end
end
