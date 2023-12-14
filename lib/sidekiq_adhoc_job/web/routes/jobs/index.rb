module SidekiqAdhocJob
  module Web
    module Jobs
      class Index
        def self.register(app)
          app.get '/adhoc-jobs' do
            @presented_jobs = SidekiqAdhocJob::Web::JobPresenter.build_collection.sort_by { |j| j.name.to_s }

            erb File.read(File.join(VIEW_PATH, 'jobs/index.html.erb'))
          end

          app.get '/adhoc-jobs-v2' do
            SidekiqAdhocJob.config.strategy_name = :default
            SidekiqAdhocJob::WorkerClassesLoader.load(
              SidekiqAdhocJob.config.module_names,
              load_paths: SidekiqAdhocJob.config.load_paths,
              strategy: SidekiqAdhocJob.config.strategy
            )

            @presented_jobs = SidekiqAdhocJob::Web::JobPresenter.build_collection.sort_by { |j| j.name.to_s }

            erb File.read(File.join(VIEW_PATH, 'jobs/index_v2.html.erb'))
          end
        end
      end
    end
  end
end
