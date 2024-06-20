# frozen_string_literal: true

require 'http'

module No2Date
  ## Send email verfification email
  # params:
  #   - registration: hash with keys :username :email :verification_url
  class VerifyRegistration
    # Error for invalid registration details
    class InvalidRegistration < StandardError; end
    class EmailProviderError < StandardError; end

    def initialize(registration)
      @registration = registration
    end

    def from_email = ENV.fetch('SENDGRID_FROM_EMAIL', nil)
    def mail_api_key = ENV.fetch('SENDGRID_API_KEY', nil)
    def mail_url = ENV.fetch('SENDGRID_API_URL', nil)

    def call
      puts "verify_registration.rb: call #{@registration[:username]}, #{@registration[:email]}"
      raise(InvalidRegistration, 'Username exists') unless username_available?
      raise(InvalidRegistration, 'Email already used') unless email_available?

      send_email_verification
    end

    def username_available?
      puts 'username_check'
      puts "username_check: #{Account.first(username: @registration[:username]).inspect}"
      Account.first(username: @registration[:username]).nil?
    end

    def email_available?
      puts 'email_check'
      puts "email_check: #{Account.first(email: @registration[:email]).inspect}"
      Account.first(email: @registration[:email]).nil?
    end

    def html_email
      <<~END_EMAIL
        <H1>No2Date App Registration Received</H1>
        <p>Please <a href="#{@registration[:verification_url]}">click here</a>
        to validate your email.
        You will be asked to set a password to activate your account.</p>
      END_EMAIL
    end

    def mail_json # rubocop:disable Metrics/MethodLength
      {
        personalizations: [{
          to: [{ 'email' => @registration[:email] }]
        }],
        from: { 'email' => from_email },
        subject: 'No2Date Registration Verification',
        content: [
          { type: 'text/html',
            value: html_email }
        ]
      }
    end

    def send_email_verification
      puts "verify_registration.rb: send #{mail_api_key}, #{mail_url}, #{mail_json}"
      res = HTTP.auth("Bearer #{mail_api_key}").post(mail_url, json: mail_json)
      raise EmailProviderError if res.status >= 300
    rescue StandardError
      raise(InvalidRegistration,
            'Could not send verification email; please check email address')
    end
  end
end
