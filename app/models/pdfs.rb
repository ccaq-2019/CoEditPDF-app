# frozen_string_literal: true

require_relative 'pdf'

module CoEditPDF
  # Behaviors of the currently logged in account
  class Pdfs
    attr_reader :owned_pdfs, :collaborate_pdfs,
                :owned_pdf_policy, :collaborate_pdf_policy

    def initialize(pdfs_list)
      # owned
      @owned_pdfs = pdfs_list['owned']['pdfs'].map do |pdf|
        Pdf.new(pdf)
      end
      @owned_pdf_policy = OpenStruct.new(pdfs_list['owned']['policy'])

      # collaborate
      @collaborate_pdfs = pdfs_list['collaborate']['pdfs'].map do |pdf|
        Pdf.new(pdf)
      end
      @collaborate_pdf_policy = OpenStruct.new(pdfs_list['collaborate']\
                                                        ['policy'])
    end
  end
end
