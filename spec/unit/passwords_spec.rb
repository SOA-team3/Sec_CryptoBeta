# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Password Digestion' do
  it 'SECURITY: create password digests safely, hiding raw password' do
    password = 'secret password of Brian stored in db'
    digest = No2Date::StoredPassword.digest(password)

    _(digest.to_s.match?(password)).must_equal false
  end

  it 'SECURITY: successfully checks correct password from stored digest' do
    password = 'secret password of Brian stored in db'
    digest_s = No2Date::StoredPassword.digest(password).to_s

    stored_password = No2Date::StoredPassword.from_digest(digest_s)
    _(stored_password.validate?(password)).must_equal true
  end

  it 'SECURITY: successfully detects incorrect password from stored digest' do
    password1 = 'secret password of Brian stored in db'
    password2 = 'Ifyouwishtomakeapplepieyoumustfirstinventtheuniverse'
    digest_s1 = No2Date::StoredPassword.digest(password1).to_s

    true_password1 = No2Date::StoredPassword.from_digest(digest_s1)
    _(true_password1.validate?(password2)).must_equal false
  end
end
