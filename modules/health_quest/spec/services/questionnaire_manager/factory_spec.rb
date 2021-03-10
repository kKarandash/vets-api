# frozen_string_literal: true

require 'rails_helper'

describe HealthQuest::QuestionnaireManager::Factory do
  include HealthQuest::QuestionnaireManager::FactoryTypes

  subject { described_class }

  let(:user) { double('User', icn: '1008596379V859838', account_uuid: 'abc123', uuid: '789defg') }
  let(:session_store) { double('SessionStore', token: '123abc') }
  let(:session_service) do
    double('HealthQuest::Lighthouse::Session', user: user, api: 'pgd_api', retrieve: session_store)
  end
  let(:client_reply) { double('FHIR::ClientReply') }
  let(:default_appointments) { { data: [] } }
  let(:default_location) { [double('FHIR::Location')] }
  let(:appointments) { { data: [{}, {}] } }

  before do
    allow(HealthQuest::Lighthouse::Session).to receive(:build).and_return(session_service)
  end

  describe 'included modules' do
    it 'includes FactoryTypes' do
      expect(subject.ancestors).to include(HealthQuest::QuestionnaireManager::FactoryTypes)
    end
  end

  describe 'constants' do
    it 'has a HEALTH_CARE_FORM_PREFIX' do
      expect(subject::HEALTH_CARE_FORM_PREFIX).to eq('HC-QSTNR')
    end

    it 'has an USE_CONTEXT_DELIMITER' do
      expect(subject::USE_CONTEXT_DELIMITER).to eq(',')
    end

    it 'has an ID_MATCHER' do
      expect(subject::ID_MATCHER).to eq(/([I2\-a-zA-Z0-9]+)\z/i)
    end
  end

  describe 'object initialization' do
    let(:factory) { described_class.manufacture(user) }

    it 'responds to attributes' do
      expect(factory.respond_to?(:appointments)).to eq(true)
      expect(factory.respond_to?(:lighthouse_appointments)).to eq(true)
      expect(factory.respond_to?(:locations)).to eq(true)
      expect(factory.respond_to?(:aggregated_data)).to eq(true)
      expect(factory.respond_to?(:patient)).to eq(true)
      expect(factory.respond_to?(:questionnaires)).to eq(true)
      expect(factory.respond_to?(:save_in_progress)).to eq(true)
      expect(factory.respond_to?(:appointment_service)).to eq(true)
      expect(factory.respond_to?(:lighthouse_appointment_service)).to eq(true)
      expect(factory.respond_to?(:location_service)).to eq(true)
      expect(factory.respond_to?(:patient_service)).to eq(true)
      expect(factory.respond_to?(:questionnaire_service)).to eq(true)
      expect(factory.respond_to?(:sip_model)).to eq(true)
      expect(factory.respond_to?(:transformer)).to eq(true)
      expect(factory.respond_to?(:user)).to eq(true)
    end
  end

  describe '.manufacture' do
    it 'returns an instance of the described class' do
      expect(described_class.manufacture(user)).to be_an_instance_of(described_class)
    end
  end

  describe '#all' do
    let(:fhir_data) { double('FHIR::Bundle', entry: [{}, {}]) }
    let(:questionnaire_response_client_reply) do
      double('FHIR::ClientReply', resource: fhir_questionnaire_response_bundle)
    end
    let(:fhir_questionnaire_response_bundle) { fhir_data }
    let(:questionnaire_client_reply) { double('FHIR::ClientReply', resource: fhir_questionnaire_bundle) }
    let(:appointments_client_reply) { double('FHIR::ClientReply', resource: fhir_data) }

    before do
      allow_any_instance_of(subject).to receive(:get_patient).and_return(client_reply)
      allow_any_instance_of(subject).to receive(:get_appointments).and_return(appointments)
      allow_any_instance_of(subject).to receive(:get_lighthouse_appointments).and_return(appointments_client_reply)
      allow_any_instance_of(subject).to receive(:get_locations).and_return(default_location)
      allow_any_instance_of(subject).to receive(:get_save_in_progress).and_return([{}])
      allow_any_instance_of(subject)
        .to receive(:get_questionnaire_responses).and_return(questionnaire_response_client_reply)
      allow_any_instance_of(subject).to receive(:get_questionnaires).and_return(questionnaire_client_reply)
    end

    context 'when appointment does not exist' do
      let(:questionnaire_response_client_reply) { nil }
      let(:questionnaire_client_reply) { nil }
      let(:fhir_questionnaire_response_bundle) { nil }

      before do
        allow_any_instance_of(subject).to receive(:get_appointments).and_return(default_appointments)
      end

      it 'returns a default hash' do
        hash = { data: [] }

        expect(described_class.manufacture(user).all).to eq(hash)
      end
    end

    context 'when appointments and questionnaires and questionnaire_responses and sip and no patient' do
      let(:client_reply) { double('FHIR::ClientReply', resource: nil) }
      let(:fhir_questionnaire_bundle) { fhir_data }

      it 'returns a default hash' do
        hash = { data: [] }

        expect(described_class.manufacture(user).all).to eq(hash)
      end

      it 'has a nil patient' do
        factory = described_class.manufacture(user)
        factory.all

        expect(factory.patient).to be_nil
      end
    end

    context 'when appointments and patient and questionnaire_responses and sip and no questionnaires' do
      let(:fhir_patient) { double('FHIR::Patient') }
      let(:client_reply) { double('FHIR::ClientReply', resource: fhir_patient) }
      let(:questionnaire_client_reply) { double('FHIR::ClientReply', resource: double('FHIR::ClientReply', entry: [])) }

      it 'returns a default hash' do
        hash = { data: [] }

        expect(described_class.manufacture(user).all).to eq(hash)
      end

      it 'has a FHIR::Patient patient' do
        factory = described_class.manufacture(user)
        factory.all

        expect(factory.patient).to eq(fhir_patient)
      end
    end
  end

  describe '#get_use_context' do
    let(:data) do
      [
        double('Appointments', facility_id: '123', clinic_id: '54679'),
        double('Appointments', facility_id: '789', clinic_id: '98741')
      ]
    end

    it 'returns a formatted use-context string' do
      allow_any_instance_of(described_class).to receive(:appointments).and_return(data)

      expect(described_class.manufacture(user).get_use_context).to eq('venue$123/54679,venue$789/98741')
    end
  end

  describe '#get_patient' do
    it 'returns a FHIR::ClientReply' do
      allow_any_instance_of(HealthQuest::Resource::Factory).to receive(:get).with(user.icn).and_return(client_reply)

      expect(described_class.manufacture(user).get_patient).to eq(client_reply)
    end
  end

  describe '#get_questionnaires' do
    let(:client_reply) { double('FHIR::ClientReply', resource: double('FHIR::Bundle', entry: [{}])) }

    it 'returns a FHIR::ClientReply' do
      allow_any_instance_of(HealthQuest::Resource::Factory).to receive(:search).with(anything).and_return(client_reply)
      allow_any_instance_of(described_class).to receive(:get_use_context).and_return('venue$583/12345')

      expect(described_class.manufacture(user).get_questionnaires).to eq(client_reply)
    end
  end

  describe '#get_questionnaire_responses' do
    let(:client_reply) { double('FHIR::ClientReply', resource: double('FHIR::Bundle', entry: [{}])) }

    it 'returns a FHIR::ClientReply' do
      allow_any_instance_of(HealthQuest::Resource::Factory).to receive(:search).with(anything).and_return(client_reply)

      expect(described_class.manufacture(user).get_questionnaire_responses).to eq(client_reply)
    end
  end

  describe '#get_lighthouse_appointments' do
    let(:client_reply) { double('FHIR::ClientReply', resource: double('FHIR::Bundle', entry: [{}])) }

    it 'returns a FHIR::ClientReply' do
      allow_any_instance_of(HealthQuest::Resource::Factory).to receive(:search).with(anything).and_return(client_reply)

      expect(described_class.manufacture(user).get_lighthouse_appointments).to eq(client_reply)
    end
  end

  describe '#get_locations' do
    let(:client_reply) { double('FHIR::ClientReply', resource: double('FHIR::Bundle', entry: [{}])) }
    let(:appointments) do
      [
        double('Object',
               resource: double('FHIR::Appointment',
                                participant: [
                                  double('Object', actor: double('Reference', reference: '/foo/I2-3JYDMXC'))
                                ]))
      ]
    end
    let(:location) { double('FHIR::Location', resource: OpenStruct.new) }

    before do
      allow_any_instance_of(subject).to receive(:lighthouse_appointments).and_return(appointments)
      allow_any_instance_of(HealthQuest::Resource::Factory).to receive(:get).with(anything).and_return(location)
    end

    it 'returns a FHIR::ClientReply' do
      expect(described_class.manufacture(user).get_locations).to eq([location])
    end
  end

  describe '#get_appointments' do
    it 'returns a FHIR::ClientReply' do
      allow_any_instance_of(HealthQuest::AppointmentService).to receive(:get_appointments).and_return(appointments)

      expect(described_class.manufacture(user).get_appointments).to eq(appointments)
    end
  end

  describe '#get_save_in_progress' do
    it 'returns an empty array when user does not exist' do
      expect(described_class.manufacture(user).get_save_in_progress).to eq([])
    end
  end

  describe '#create_questionnaire_response' do
    let(:data) do
      {
        appointment: {
          id: 'abc123'
        },
        questionnaire: {
          id: 'abcd-1234',
          title: 'test'
        },
        item: []
      }
    end

    it 'returns a ClientReply' do
      allow_any_instance_of(HealthQuest::Resource::Factory).to receive(:create).with(anything).and_return(client_reply)

      expect(described_class.new(user).create_questionnaire_response(data)).to eq(client_reply)
    end
  end
end
