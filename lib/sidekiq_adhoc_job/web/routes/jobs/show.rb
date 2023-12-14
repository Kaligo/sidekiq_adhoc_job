module SidekiqAdhocJob
  module Web
    module Jobs
      class Show

        def self.register(app)
          app.get '/adhoc-jobs/:name' do
            @csrf_token = env['rack.session'][:csrf]
            @presented_job = SidekiqAdhocJob::Web::JobPresenter.find(params[:name])
            if @presented_job
              erb File.read(File.join(VIEW_PATH, 'jobs/show.html.erb'))
            else
              redirect "#{root_path}adhoc-jobs"
            end
          end

          app.get '/adhoc-jobs-v2/:name' do
            SidekiqAdhocJob.config.strategy_name = :default
            SidekiqAdhocJob::WorkerClassesLoader.load(
              SidekiqAdhocJob.config.module_names,
              load_paths: SidekiqAdhocJob.config.load_paths,
              strategy: SidekiqAdhocJob.config.strategy
            )

            @csrf_token = env['rack.session'][:csrf]
            @presented_job = SidekiqAdhocJob::Web::JobPresenter.find(params[:name])
            if @presented_job
              erb File.read(File.join(VIEW_PATH, 'jobs/show_v2.html.erb'))
            else
              redirect "#{root_path}adhoc-jobs-v2"
            end
          end
        end
      end
    end
  end
end
