# frozen_string_literal: true

module SidekiqAdhocJob
  module Strategies
    class ActiveJob
      include SidekiqAdhocJob::Strategy

      def worker_class?(klass)
        klass.superclass&.name == 'ActiveJob::Base'
      end

      def get_queue_name(klass_name)
        klass_name.queue_name
      end

      def perform_async(klass, *params, **kw_params)
        klass.perform_later(*params, **kw_params)
      end
    end
  end
end
