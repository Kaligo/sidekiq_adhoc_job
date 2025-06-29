# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq/web'

require 'sidekiq_adhoc_job/utils/string'
require 'sidekiq_adhoc_job/utils/class_inspector'
require 'sidekiq_adhoc_job/strategy'
require 'sidekiq_adhoc_job/worker_classes_loader'
require 'sidekiq_adhoc_job/web/job_presenter'
require 'sidekiq_adhoc_job/services/schedule_adhoc_job'
require 'sidekiq_adhoc_job/web'

module SidekiqAdhocJob
  StringUtil ||= Utils::String

  module Strategies
    autoload :Default, 'sidekiq_adhoc_job/strategies/default'
    autoload :ActiveJob, 'sidekiq_adhoc_job/strategies/active_job'
    autoload :RailsApplicationJob, 'sidekiq_adhoc_job/strategies/rails_application_job'
  end

  def self.configure
    @_config = Configuration.new
    yield @_config
  end

  def self.config
    @_config
  end

  def self.init
    SidekiqAdhocJob::WorkerClassesLoader.load(@_config.module_names, load_paths: @_config.load_paths,
                                                                     strategy: @_config.strategy)

    # Check if we're using Sidekiq 8+ which requires the new API
    if Gem::Version.new(Sidekiq::VERSION) >= Gem::Version.new('8.0.0')
      Sidekiq::Web.configure do |config|
        config.register_extension(SidekiqAdhocJob::Web, name: 'Adhoc Jobs', tab: 'adhoc_jobs', index: 'adhoc-jobs')
      end
    else
      # Legacy API for Sidekiq 7.x
      Sidekiq::Web.register(SidekiqAdhocJob::Web)
      Sidekiq::Web.tabs['adhoc_jobs'] = 'adhoc-jobs'
    end

    Sidekiq::Web.locales << File.expand_path('sidekiq_adhoc_job/web/locales', __dir__)

    assets_path = File.expand_path('sidekiq_adhoc_job/web/assets', __dir__)

    Sidekiq::Web.use Rack::Static, urls: ['/javascript'],
                                   root: assets_path,
                                   cascade: true,
                                   header_rules: [[:all, { 'cache-control' => 'private, max-age=86400' }]]
  end

  def self.strategies
    @strategies ||= []
  end

  class Configuration
    attr_accessor :load_paths,
                  :module_names,
                  :strategy_name,
                  :require_confirm_worker_names

    attr_reader :require_confirm_prompt_message

    def initialize
      @load_paths = []
      @module_names = []
      @strategy_name = :default
      @require_confirm_prompt_message = 'confirm'
    end

    def module_names
      Array(@module_names).map(&:to_s)
    end

    def require_confirm_proc
      @require_confirm_proc ||= \
        if @require_confirm_worker_names.respond_to?(:call)
          @require_confirm_worker_names
        else
          shortlisted_workers = Array(@require_confirm_worker_names).map(&:to_s)

          ->(worker_name) { shortlisted_workers.include?(worker_name) }
        end
    end

    def require_confirm_prompt_message=(message)
      raise 'require_confirm_prompt_message must be string' unless message.is_a? String

      @require_confirm_prompt_message = message
    end

    def require_confirmation?(worker_name)
      require_confirm_proc.call(worker_name)
    end

    def strategy
      @strategy ||= case strategy_name
                    when :default
                      SidekiqAdhocJob::Strategies::Default.new(module_names)
                    else
                      strategy_klass = SidekiqAdhocJob::Strategies.const_get(StringUtil.camelize(strategy_name.to_s).to_s)
                      raise InvalidConfigurationError, 'Invalid strategy name' unless strategy_klass

                      strategy_klass.new(module_names)
                    end
    end
  end
end
