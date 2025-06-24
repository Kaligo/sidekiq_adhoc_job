# frozen_string_literal: true

require 'sidekiq'

module SidekiqAdhocJob
  module Test
    class DummyNoArgWorker
      include Sidekiq::Worker

      sidekiq_options queue: 'dummy'

      def perform; end
    end
  end
end
