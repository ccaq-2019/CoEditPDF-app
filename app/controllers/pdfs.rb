# frozen_string_literal: true

require 'roda'

module CoEditPDF
  # Web controller for CoEditPDF API
  class App < Roda
    route('pdfs') do |routing|
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @pdfs_route = '/pdfs'

        routing.on(String) do |pdf_id|
          @pdf_route = "#{@pdfs_route}/#{pdf_id}"

          # POST /pdfs/[pdf_id]/collaborators
          routing.post('collaborators') do
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
        end

        # GET /pdfs/
        routing.get do
          pdf_list = GetAllPdfs.new(App.config).call(@current_account)
          pdfs = Pdfs.new(pdf_list)

          view :pdfs_all,
               locals: { current_user: @current_account, pdfs: pdfs }
        end
      end
    end
  end
end
