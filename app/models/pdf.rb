# frozen_string_literal: true

require 'base64'

module CoEditPDF
  # Behaviors of the currently logged in account
  class Pdf
    attr_reader :id, :filename, :content

    def initialize(pdf_data)
      @id = pdf_data['attributes']['id']
      @filename = pdf_data['attributes']['filename']
      return unless pdf_data['attributes']['content']

      @content = Base64.strict_decode64(pdf_data['attributes']['content'])
    end
  end
end
