# frozen_string_literal: true

require_relative '../../../serializers/covid_vaccine/v0/expanded_registration_serializer'

module CovidVaccine
  module V0
    class ExpandedRegistrationController < CovidVaccine::ApplicationController
      skip_before_action :validate_session
      before_action :validate_raw_form_data, only: :create
      wrap_parameters :registration

      def create
        raw_form_data = params[:registration]
        record = CovidVaccine::V0::ExpandedRegistrationSubmission.create!({ submission_uuid: SecureRandom.uuid,
                                                                            raw_form_data: raw_form_data })

        CovidVaccine::ExpandedRegistrationEmailJob.perform_async(record.id)
        render json: record, serializer: CovidVaccine::V0::ExpandedRegistrationSerializer, status: :created
      end

      private

      def validate_raw_form_data
        form_data = CovidVaccine::V0::RawExpandedFormData.new(params[:registration] || {})
        raise Common::Exceptions::ValidationErrors, form_data unless form_data.valid?
      end

      def check_flipper
        routing_error unless Flipper.enabled?(:covid_vaccine_registration_expanded)
      end
    end
  end
end
