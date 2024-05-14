require 'sidekiq'

module SidekiqAdhocJob
  module Test
    class SimpleDummyWorker
      include Sidekiq::Worker

      sidekiq_options queue: 'dummy'

      def perform(id, retry_job = true, abc = 'afif', xyz = [], bce = { 'test' => 'test' }, no_of_retries = 5)
      end
    end
  end
end
