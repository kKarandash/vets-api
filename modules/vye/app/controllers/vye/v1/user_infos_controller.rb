# frozen_string_literal: true

module Vye
  module V1
    class UserInfosController < Vye::V1::ApplicationController
      include Pundit::Authorization
      include Vye::Ivr

      service_tag 'verify-your-enrollment'

      def show
        authorize user_info, policy_class: Vye::UserInfoPolicy

        render json: user_info,
               serializer: Vye::UserInfoSerializer,
               key_transform: :camel_lower,
               adapter: :json,
               include: %i[address_changes pending_documents verifications pending_verifications].freeze
      end

      private

      def load_user_info
        return super(scoped: Vye::UserProfile.with_assos) unless api_key?

        @user_info = user_info_for_ivr(scoped: Vye::UserProfile.with_assos)
      end

      def transformed_params
        @transform_params ||= params.deep_transform_keys!(&:underscore)
      end
    end
  end
end
