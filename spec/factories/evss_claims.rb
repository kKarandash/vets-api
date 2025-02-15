# frozen_string_literal: true

FactoryBot.define do
  factory :evss_claim do
    user_uuid { '1234' }
    evss_id   { 1 }
    data      do
      fixture_file_name = ::Rails.root.join(*'/spec/fixtures/evss_claim/claim-detail.json'.split('/')).to_s
      File.open(fixture_file_name, 'rb') do |f|
        raw_claim = f.read
        JSON.parse(raw_claim).deep_transform_keys!(&:underscore)
      end
    end
    list_data do
      fixture_file_name = ::Rails.root.join(*'/spec/fixtures/evss_claim/claim-list.json'.split('/')).to_s
      File.open(fixture_file_name, 'rb') do |f|
        raw_claim = f.read
        JSON.parse(raw_claim).deep_transform_keys!(&:underscore)
      end
    end
  end
end
