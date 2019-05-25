# frozen_string_literal: true

module CoEditPDF
  # Behaviors of the currently logged in account
  class Pdf
    attr_reader :id, :filename

    def initialize(pdf_info)
      @id = pdf_info['attributes']['id']
      @filename = pdf_info['attributes']['filename']
    end
  end
end
