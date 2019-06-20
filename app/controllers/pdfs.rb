# frozen_string_literal: true

require 'roda'
require 'base64'
require 'hexapdf'

module CoEditPDF
  # Web controller for CoEditPDF API
  class App < Roda
    route('pdfs') do |routing|
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @pdfs_route = '/pdfs'

        routing.on String do |pdf_id|
          @pdf_route = "#{@pdfs_route}/#{pdf_id}"

          # POST /pdfs/[pdf_id]/collaborators
          routing.post 'collaborators' do
            action = routing.params['action']
            collaborator_info = Form::CollaboratorEmail.call(routing.params)
            if collaborator_info.failure?
              flash[:error] = Form.validation_errors(collaborator_info)
              routing.halt
            end

            task_list = {
              'add' => { service: AddCollaborator,
                         message: 'Added new collaborator to pdf' },
              'remove' => { service: RemoveCollaborator,
                            message: 'Removed collaborator from pdf' }
            }

            task = task_list[action]
            task[:service].new(App.config).call(
              current_account: @current_account,
              collaborator: collaborator_info,
              pdf_id: pdf_id
            )
            flash[:notice] = task[:message]

          rescue StandardError
            flash[:error] = 'Could not find collaborator'
          ensure
            routing.redirect @pdfs_route
          end

          # GET /pdfs/[pdf_id]/file
          routing.get 'file' do
            @pdf_data = GetPdf.new(App.config).call(@current_account, pdf_id)
            pdf = Pdf.new(@pdf_data)
            response['Content-Type'] = 'application/pdf'
            pdf.content
          end

          # POST /pdfs/[pdf_id]/edit
          routing.post 'edit' do
            EditPdf.new(App.config).call(
              current_account: @current_account,
              pdf_id: pdf_id,
              edit_data: routing.params
            )

            { message: 'Text added' }.to_json
          rescue EditPdf::EditError
            flash[:error] = 'Fail to add text to the file'
            routing.halt 400
          end

          # GET /pdfs/[pdf_id]
          routing.get do
            @pdf_data = GetPdf.new(App.config).call(@current_account, pdf_id)
            pdf = Pdf.new(@pdf_data)
            File.open("#{pdf_id}.pdf", 'wb') { |file| file.write(pdf.content) }
            document = HexaPDF::Document.open("#{pdf_id}.pdf")
            page = document.pages[0]
            width = page.box.width.round
            height = page.box.height.round

            view :pdf_edit,
                 locals: { pdf_id: pdf_id, width: width, height: height }
          end

          # POST /pdfs/[pdf_id]
          routing.post do
            RemovePdf.new(App.config).call(
              current_account: @current_account,
              pdf_id: pdf_id
            )
            flash[:notice] = 'Pdf removed'
          rescue StandardError
            flash[:error] = 'Could not remove pdf'
          ensure
            routing.redirect @pdfs_route
          end
        end

        # GET /pdfs/
        routing.get do
          pdf_list = GetAllPdfs.new(App.config).call(@current_account)
          pdfs = Pdfs.new(pdf_list)

          view :pdfs_all,
               locals: { current_user: @current_account, pdfs: pdfs }
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

        rescue UploadPdf::UploadError
          flash[:error] = 'Failed to upload the file'
        ensure
          routing.redirect @pdfs_route
        end
      end
    end
  end
end
