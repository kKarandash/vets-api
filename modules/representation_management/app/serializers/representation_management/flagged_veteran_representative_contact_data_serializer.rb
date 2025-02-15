# frozen_string_literal: true

module RepresentationManagement
  class FlaggedVeteranRepresentativeContactDataSerializer < ActiveModel::Serializer
    attributes :ip_address, :representative_id, :flag_type, :flagged_value
  end
end
