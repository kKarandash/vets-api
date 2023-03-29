# frozen_string_literal: true

require 'common/client/base'
require 'find'
require 'openssl'
require 'date'

class ExpiryScanner
  REMAINING_DAYS = 60
  URGENT_REMAINING_DAYS = 30
  API_PATH = 'https://slack.com/api/chat.postMessage'

  def self.scan_certs
    messages = []
    cert_paths = Dir.glob(directories)
    cert_paths.each do |cert_path|
      if File.extname(cert_path) == '.pem' || File.extname(cert_path) == '.crt'
        messages << define_expiry_urgency(cert_path)
      end
    rescue
      Rails.logger.debug { "ERROR: Could not parse certificate #{cert_path}" }
    end
    Faraday.post(API_PATH, request_body(messages.join("\n")), request_headers) if messages.any?
  end

  def self.define_expiry_urgency(cert_path)
    result = ''
    now = DateTime.now
    cert = OpenSSL::X509::Certificate.new(File.read(cert_path))
    expiry = cert.not_after.to_datetime
    if now + URGENT_REMAINING_DAYS > expiry
      return "URGENT: #{cert_path} expires in less than #{URGENT_REMAINING_DAYS} days: #{expiry}"
    elsif now + REMAINING_DAYS > expiry
      return "ATTENTION: #{cert_path} expires in less than #{REMAINING_DAYS} days: #{expiry}"
    end

    result
  end

  def self.request_body(message)
    {
      text: message,
      channel: Settings.expiry_scanner.slack.channel_id
    }.to_json
  end

  def self.request_headers
    {
      'Content-type' => 'application/json; charset=utf-8',
      'Authorization' => "Bearer #{Settings.argocd.slack.api_key}"
    }
  end

  def self.directories
    Settings.expiry_scanner.directories
  end
end
