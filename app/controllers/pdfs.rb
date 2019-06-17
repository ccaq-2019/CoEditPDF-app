# frozen_string_literal: true

require 'roda'

module CoEditPDF
  # Web controller for CoEditPDF API
  class App < Roda
    route('pdfs') do |routing|
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?

        # GET /pdfs/
        routing.get do
          pdf_list = GetAllPdfs.new(App.config).call(@current_account)
          pdfs = Pdfs.new(pdf_list)

          view :pdfs_all,
               locals: { current_user: @current_account,
                         pdfs: pdfs }
        end
      end
    end
  end
end
