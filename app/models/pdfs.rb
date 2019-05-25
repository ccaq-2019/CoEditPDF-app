# frozen_string_literal: true

require_relative 'pdf'

module CoEditPDF
  # Behaviors of the currently logged in account
  class Pdfs
    attr_reader :all

    def initialize(pdfs_list)
      @all = pdfs_list.map do |pdf|
        Pdf.new(pdf)
      end
    end
  end
end
