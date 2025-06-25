# frozen_string_literal: true

class ApplicationJob; end

module SidekiqAdhocJob
  module RailsApplicationJobTest
    class DummyApplicationJob < ApplicationJob
    end
  end
end
