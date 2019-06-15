# frozen_string_literal: true

require 'roda'
require 'base64'

module CoEditPDF
  # Web controller for CoEditPDF API
  class App < Roda
    route('pdfs') do |routing|
      routing.on do
        # GET /pdfs/[pdf_id]
        routing.on String do |pdf_id|
          @pdf_data = GetPdf.new(App.config).call(@current_account, pdf_id)
          pdf = Pdf.new(@pdf_data)

          routing.get 'file' do
            response['Content-Type'] = 'application/pdf'
            pdf.content
          end

          routing.get do
            view :pdf_edit, locals: { pdf_id: pdf_id }
          end
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

        # POST /pdfs/
        routing.post do
          filename = routing.params['pdf_file'][:filename]
          file = routing.params['pdf_file'][:tempfile]
          content = file.read

          UploadPdf.new(App.config)
                   .call(current_account: @current_account,
                         filename: filename,
                         content: content)

          routing.redirect '/pdfs'
        end
      end
    end
  end
end
