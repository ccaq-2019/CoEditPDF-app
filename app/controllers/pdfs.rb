# frozen_string_literal: true

require 'roda'

module CoEditPDF
  # Web controller for CoEditPDF API
  class App < Roda
    route('pdfs') do |routing|
      @pdfs_route = '/pdfs'
      routing.on do
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
          routing.redirect '/auth/login' unless @current_account.logged_in?

          @filename = routing.params['file'][:filename]
          file = routing.params['file'][:tempfile]

          File.open("./files/#{@filename}", 'wb') do |f|
            f.write(file.read)
          end

          routing.redirect @pdfs_route
        end
      end
    end
  end
end
