# frozen_string_literal: true

# set up all the configurations information for need
# forzen_string_literal: true

require 'roda'
require 'figaro'
require 'logger'
require 'sequel'
require_app('lib')

module No2Date
  # Configuration for the No2Date API
  class Api < Roda
    plugin :environments

    # rubocop:disable Lint/ConstantDefinitionInBlock
    configure do

      # Load config secrets into local environment variables (ENV)
      Figaro.application = Figaro::Application.new(
        environment: environment, # rubocop:disable Style/HashSyntax
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load

      # Make the environment variables accessible to other classes
      def self.config = Figaro.env

      # Set timezone
      ENV['TZ'] = 'Asia/Taipei'

      # Database setup
      db_url = ENV.delete('DATABASE_URL')
      DB = Sequel.connect("#{db_url}?encoding=utf8")
      def self.DB = DB # rubocop:disable Naming/MethodName

      # HTTP Request logging
      configure :development, :production do
        plugin :common_logger, $stdout
      end

      # Custom events logging
      LOGGER = Logger.new($stderr)
      def self.logger = LOGGER

      # Load crypto keys
      SecureDB.setup(ENV.delete('DB_KEY')) # Load crypto key
      AuthToken.setup(ENV.fetch('MSG_KEY')) # Load crypto key
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock

    configure :development, :test do
      require 'pry'
      logger.level = Logger::ERROR
    end
  end
end
