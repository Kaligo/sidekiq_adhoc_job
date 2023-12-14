module SidekiqAdhocJob
  module Web
    module Jobs
      class Schedule

        def self.register(app)
          app.post '/adhoc-jobs/:name/schedule' do
            SidekiqAdhocJob::ScheduleAdhocJob.new(params[:name], request.params).call
            redirect "#{root_path}adhoc-jobs"
          end

          app.post '/adhoc-jobs-v2/:name/schedule' do
            SidekiqAdhocJob.config.strategy_name = :default
            SidekiqAdhocJob::WorkerClassesLoader.load(
              SidekiqAdhocJob.config.module_names,
              load_paths: SidekiqAdhocJob.config.load_paths,
              strategy: SidekiqAdhocJob.config.strategy
            )

            SidekiqAdhocJob::ScheduleAdhocJob.new(params[:name], request.params).call
            redirect "#{root_path}adhoc-jobs-v2"
          end
        end

      end
    end
  end
end
