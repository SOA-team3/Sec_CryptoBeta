# frozen_string_literal: true

# Specify Rack class to run
require './require_app'
require_app

run No2Date::Api.freeze.app
