# frozen_string_literal: true

require 'base64'
require_relative '../lib/key_stretch'

module No2Date
  # Digests and checks passwords using salt and password-appropriate hash
  class StoredPassword
    extend KeyStretch

    def initialize(salt, digest)
      @salt = salt
      @digest = digest
    end

    # Comparing digest assuming using the same password
    def validate?(password)
      new_digest = StoredPassword.password_hash(@salt, password)
      @digest == new_digest
    end

    def to_json(options = {})
      JSON({ salt: Base64.strict_encode64(@salt),
             hash: Base64.strict_encode64(@digest) },
           options)
    end

    alias to_s to_json

    def self.digest(password)
      salt = new_salt
      hash = password_hash(salt, password)
      new(salt, hash)
    end

    # Extract and recover the salt, password and set that to create a new password object
    def self.from_digest(digest)
      digested = JSON.parse(digest)
      salt = Base64.strict_decode64(digested['salt'])
      hash = Base64.strict_decode64(digested['hash'])
      new(salt, hash)
    end
  end
end
