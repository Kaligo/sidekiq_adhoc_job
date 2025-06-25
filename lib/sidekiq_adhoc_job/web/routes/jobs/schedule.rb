# frozen_string_literal: true

module SidekiqAdhocJob
  module Web
    module Jobs
      class Schedule
        def self.register(app)
          app.post '/adhoc-jobs/:name/schedule' do
            # Use Sidekiq 8's new API if available, fallback to legacy for Sidekiq 7
            if Gem::Version.new(Sidekiq::VERSION) >= Gem::Version.new('8.0.0')
              name = route_params(:name)
            else
              name = params['name']
            end

            # For form parameters, try the new API first, then fallback to request.params
            form_params = if Gem::Version.new(Sidekiq::VERSION) >= Gem::Version.new('8.0.0')
              url_params('all') || params
            else
              params
            end

            SidekiqAdhocJob::ScheduleAdhocJob.new(name, form_params).call
            redirect "#{root_path}adhoc-jobs"
          end
        end
      end
    end
  end
end
