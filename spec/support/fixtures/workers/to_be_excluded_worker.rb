# frozen_string_literal: true

require 'sidekiq'

module SidekiqAdhocJob
  class ToBeExcludedWorker
    include Sidekiq::Worker

    sidekiq_options queue: 'dummy'

    def perform; end
  end
end
