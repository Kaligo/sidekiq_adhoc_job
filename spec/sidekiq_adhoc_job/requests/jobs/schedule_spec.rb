# frozen_string_literal: true

require 'rack/test'
require_relative '../../../../lib/sidekiq_adhoc_job/web/routes/jobs/schedule'
require_relative '../../../../lib/sidekiq_adhoc_job/services/schedule_adhoc_job'

RSpec.describe 'GET /adhoc_jobs/:name' do
  include Rack::Test::Methods
  include_context 'SidekiqAdhocJob setup'
  include_context 'request setup'

  let(:request_params) do
    {
      id: '46ed680d-9ac5-4652-a821-04c6bec66a02',
      overwrite: 'false',
      retry_job: 'true',
      retries: '10',
      interval: '5.5'
    }
  end

  let(:schedule_job_params) do
    {
      'id' => '46ed680d-9ac5-4652-a821-04c6bec66a02',
      'overwrite' => 'false',
      'retry_job' => 'true',
      'retries' => '10',
      'interval' => '5.5'
    }
  end

  let(:fake_schedule_job) { double(call: true) }

  before do
    disable_csrf
    allow(SidekiqAdhocJob::ScheduleAdhocJob)
      .to receive(:new)
      .with('sidekiq_adhoc_job_test_dummy_worker', schedule_job_params)
      .and_return(fake_schedule_job)
  end

  it 'runs ScheduleAdhocJob service' do
    post '/adhoc-jobs/sidekiq_adhoc_job_test_dummy_worker/schedule', request_params

    expect(fake_schedule_job).to have_received(:call)
    expect(last_response.status).to eq(302)
    expect(last_response.headers['Location']).to eq "#{last_request.base_url}/adhoc-jobs"
  end
end
