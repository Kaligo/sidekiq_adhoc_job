# frozen_string_literal: true

module SharedWorker
  def logger
    Sidekiq.logger
  end
end
