module SidekiqAdhocJob
  module Web
    module Jobs
      class Schedule

                def self.register(app)
          app.post '/adhoc-jobs/:name/schedule' do
            # Use Sidekiq 8's new API if available, fallback to legacy for Sidekiq 7
            name = if respond_to?(:route_params)
              route_params(:name)
            else
              params[:name]
            end

            # For form parameters, try the new API first, then fallback to request.params
            form_params = if respond_to?(:url_params)
              begin
                url_params
              rescue ArgumentError
                request.params
              end
            else
              request.params
            end

            SidekiqAdhocJob::ScheduleAdhocJob.new(name, form_params).call
            redirect "#{root_path}adhoc-jobs"
          end
        end

      end
    end
  end
end
