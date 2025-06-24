# frozen_string_literal: true

require 'sidekiq'

module SidekiqAdhocJob
  module Test
    module Worker
      class NestedNamespacedWorker
        include Sidekiq::Worker

        sidekiq_options queue: 'dummy'

        def perform; end
      end
    end
  end
end
