# frozen_string_literal: true

module ActiveJob
  class Base; end
end

module SidekiqAdhocJob
  module ActiveJobTest
    class DummyActiveJob < ActiveJob::Base
    end
  end
end
