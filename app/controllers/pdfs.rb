# frozen_string_literal: true

require 'roda'

module CoEditPDF
  # Web controller for CoEditPDF API
  class App < Roda
    route('pdfs') do |routing|
      routing.on do
        # GET /pdfs/edit
        routing.get 'edit' do
          view :pdf_edit
        end

        # GET /pdfs/
        routing.get do
          if @current_account.logged_in?
            pdf_list = GetAllPdfs.new(App.config).call(@current_account)

            pdfs = Pdfs.new(pdf_list)

            view :pdfs_all,
                 locals: { current_user: @current_account, pdfs: pdfs }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
