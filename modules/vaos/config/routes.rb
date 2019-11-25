# frozen_string_literal: true

VAOS::Engine.routes.draw do
  defaults format: :json do
    resources :appointments, only: :index do
      put 'cancel', on: :collection
    end
    resources :appointment_requests, only: %i[index create update] do
      resources :messages, only: :index
    end
    resources :systems, only: :index
    resources :facilities, only: :index do
      resources :clinics, only: :index
      resources :cancel_reasons, only: :index
    end
    resources :preferences, only: :index
    get 'api', to: 'apidocs#index'
  end
end
