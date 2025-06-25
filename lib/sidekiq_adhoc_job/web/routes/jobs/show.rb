# frozen_string_literal: true

module SidekiqAdhocJob
  module Web
    module Jobs
      class Show
        def self.register(app)
          app.get '/adhoc-jobs/:name' do
            @csrf_token = env['rack.session'][:csrf]

            # Use Sidekiq 8's new API if available, fallback to legacy for Sidekiq 7
            name = if Gem::Version.new(Sidekiq::VERSION) >= Gem::Version.new('8.0.0')
                     route_params(:name)
                   else
                     params['name']
                   end

            @presented_job = SidekiqAdhocJob::Web::JobPresenter.find(name)
            if @presented_job
              erb File.read(File.join(VIEW_PATH, 'jobs/show.html.erb'))
            else
              redirect "#{root_path}adhoc-jobs"
            end
          end
        end
      end
    end
  end
end
