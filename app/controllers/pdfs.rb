# frozen_string_literal: true

require 'roda'
require 'base64'

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

          # GET /pdfs/[pdf_id]
          routing.get do
            view :pdf_edit, locals: { pdf_id: pdf_id }
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

          routing.redirect '/pdfs'
        end
      end
    end
  end
end
