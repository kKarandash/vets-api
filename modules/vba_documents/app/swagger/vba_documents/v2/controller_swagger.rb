# frozen_string_literal: true

module VBADocuments
  module V2
    class ControllerSwagger
      include Swagger::Blocks
      VBA_TAG = ['VBA Documents'].freeze
      WEBHOOK_EXAMPLE_PATH = VBADocuments::Engine.root.join('app', 'swagger', 'vba_documents', 'document_upload', 'v2', 'webhook_example.json')
      swagger_path '/services/vba_documents/v2/uploads' do
        operation :post, tags: VBA_TAG do
          extend VBADocuments::Responses::ForbiddenError
          extend VBADocuments::Responses::TooManyRequestsError
          extend VBADocuments::Responses::InternalServerError
          extend VBADocuments::Responses::UnexpectedError
          extend VBADocuments::Responses::UnauthorizedError
          key :summary, 'Get a location for subsequent document upload PUT request'
          key :operationId, 'postBenefitsDocumentUpload'
          security do
            key :apikey, []
          end
          key :tags, [
            VBA_TAG
          ]

          response 202 do
            key :description, 'Accepted. Location generated'
            content 'application/json' do
              schema do
                key :type, :object
                key :required, %i[data]
                property :data do
                  key :$ref, :DocumentUploadPath
                end
              end
            end
          end
        end
      end

      swagger_path '/v1/webhooks/register' do
        operation :post, tags: VBA_TAG do
          extend VBADocuments::Responses::ForbiddenError
          extend VBADocuments::Responses::TooManyRequestsError
          extend VBADocuments::Responses::InternalServerError
          extend VBADocuments::Responses::UnexpectedError
          extend VBADocuments::Responses::UnauthorizedError
          key :summary, 'Register callback url(s) for notifications'
          key :operationId, 'postBenefitsWebhooksRegister'
          key :description, File.read(VBADocuments::Engine.root.join('app', 'swagger', 'vba_documents', 'document_upload', 'v2', 'webhook_description.md'))
          security do
            key :apikey, []
          end
          request_body do
            key :description, 'Pass a webhook object for notifications'
            key :in, :formData
            key :example, JSON.parse(File.read(WEBHOOK_EXAMPLE_PATH))
            content 'application/json' do
              schema do
                key :$ref, :Webhook
              end
            end
          end

          key :tags, [
            VBA_TAG
          ]

          response 202 do
            key :description, 'Accepted'
            content 'application/json' do
              schema do
                key :type, :object
                key :required, %i[data]
                property :data do
                  key :$ref, :WebhookResponse
                end
              end
            end
          end
        end
      end

      swagger_path '/v1/webhooks/list' do
        operation :get, tags: VBA_TAG do
          extend VBADocuments::Responses::ForbiddenError
          extend VBADocuments::Responses::TooManyRequestsError
          extend VBADocuments::Responses::InternalServerError
          extend VBADocuments::Responses::UnexpectedError
          extend VBADocuments::Responses::UnauthorizedError
          key :summary, 'Get a list of all current subscriptions'
          key :operationId, 'postBenefitsWebhooksList'
          # key :description, File.read(VBADocuments::Engine.root.join('app', 'swagger', 'vba_documents', 'document_upload', 'v2', 'webhook_description.md'))
          security do
            key :apikey, []
          end

          key :tags, [
            VBA_TAG
          ]

          response 200 do
            key :description, 'Ok'
            content 'application/json' do
              schema do
                key :type, :object
                property :data do
                  key :$ref, :WebhookResponse
                end
              end
            end
          end
        end
      end

      swagger_path '/{location from step 3 response}' do
        operation :put, tags: VBA_TAG do
          extend VBADocuments::Responses::InternalServerError
          extend VBADocuments::Responses::UnauthorizedError
          extend VBADocuments::Responses::TooManyRequestsError
          extend VBADocuments::Responses::UnexpectedError
          key :summary, 'Accepts document upload.'
          key :description, File.read(VBADocuments::Engine.root.join('app', 'swagger', 'vba_documents', 'document_upload', 'put_description.md'))
          key :operationId, 'putBenefitsDocumentUpload'

          key :tags, [
            VBA_TAG
          ]

          parameter do
            key :name, 'Content-MD5'
            key :in, 'header'
            key :description, 'Base64-encoded 128-bit MD5 digest of the message. Use for integrity control'
            key :required, false
            schema do
              key :type, :string
              key :format, :md5
            end
          end

          response 200 do
            key :description, 'Document upload staged'
          end

          response 403 do
            key :description, 'Forbidden'
            content 'application/xml' do
              schema do
                key :$ref, :DocumentUploadFailure
              end
            end
          end
        end
      end

      swagger_path '/services/vba_documents/v2/uploads/{id}' do
        operation :get, tags: VBA_TAG do
          extend VBADocuments::Responses::NotFoundError
          extend VBADocuments::Responses::TooManyRequestsError
          extend VBADocuments::Responses::InternalServerError
          extend VBADocuments::Responses::UnauthorizedError
          extend VBADocuments::Responses::ForbiddenError
          key :summary, 'Get status for a previous benefits document upload'
          key :operationId, 'getBenefitsDocumentUploadStatus'

          key :tags, [
            VBA_TAG
          ]

          security do
            key :apikey, []
          end

          parameter do
            key :name, 'id'
            key :in, :path
            key :description, 'ID as returned by a previous create upload request'
            key :required, true
            key :example, '6d8433c1-cd55-4c24-affd-f592287a7572'
            schema do
              key :type, :string
              key :format, :uuid
            end
          end

          response 200 do
            key :description, 'Upload status retrieved successfully'
            content 'application/json' do
              schema do
                key :required, %i[data]
                property :data do
                  key :$ref, :DocumentUploadStatus
                end
              end
            end
          end
        end
      end

      swagger_path '/services/vba_documents/v2/uploads/{id}/download' do
        operation :get, tags: VBA_TAG do
          extend VBADocuments::Responses::UnauthorizedError
          extend VBADocuments::Responses::TooManyRequestsError
          extend VBADocuments::Responses::ForbiddenError
          extend VBADocuments::Responses::NotFoundError
          extend VBADocuments::Responses::InternalServerError
          key :summary, 'Download zip of "what the server sees"'
          key :description, 'An endpoint that will allow you to see exactly what the server sees. We split apart all submitted docs and metadata and zip the file to make it available to you to help with debugging purposes. Files are deleted after 10 days. Only available in testing environments, not production.'
          key :operationId, 'getBenefitsDocumentUploadDownload'

          key :tags, [VBA_TAG]

          security do
            key :apikey, []
          end

          parameter do
            key :name, 'id'
            key :in, :path
            key :description, 'ID as returned by a previous create upload request'
            key :required, true
            key :example, '6d8433c1-cd55-4c24-affd-f592287a7572'
            schema do
              key :type, :string
              key :format, :uuid
            end
          end

          response 200 do
            key :description, 'Zip file with the contents of your payload as parsed by our server'
            content 'application/zip' do
              schema do
                key :type, :string
                key :format, :binary
                key :example, 'Binary File'
              end
            end
          end
        end
      end

      swagger_path '/services/vba_documents/v2/uploads/report' do
        operation :post, tags: VBA_TAG do
          extend VBADocuments::Responses::UnauthorizedError
          extend VBADocuments::Responses::TooManyRequestsError
          extend VBADocuments::Responses::ForbiddenError
          extend VBADocuments::Responses::UnexpectedError
          extend VBADocuments::Responses::InternalServerError
          key :tags, [VBA_TAG]

          key :summary, 'Get a bulk status report for a list of previous uploads'
          key :operationId, 'getBenefitsDocumentUploadStatusReport'

          security do
            key :apikey, []
          end

          request_body do
            key :description, 'List of GUIDs for which to retrieve current status'
            key :required, true

            content 'application/json' do
              schema do
                key :$ref, :DocumentUploadStatusGuidList
              end
            end
          end
          response 200 do
            key :description, 'Upload status report retrieved successfully'
            content 'application/json' do
              schema do
                key :type, :object
                key :required, %i[data]

                property :data do
                  key :$ref, :DocumentUploadStatusReport
                end
              end
            end
          end

          response 400 do
            key :description, 'Bad Request - invalid or missing list of guids'
          end
        end
      end
    end
  end
end
