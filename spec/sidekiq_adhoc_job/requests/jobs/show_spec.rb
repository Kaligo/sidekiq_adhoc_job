# frozen_string_literal: true

require 'rack/test'
require_relative '../../../../lib/sidekiq_adhoc_job/web/routes/jobs/show'

RSpec.describe 'GET /adhoc_jobs/:name' do
  include Rack::Test::Methods
  include_context 'SidekiqAdhocJob setup'
  include_context 'request setup'

  context 'has arguments' do
    it 'generates form for running job' do
      get '/adhoc-jobs/sidekiq_adhoc_job_test_dummy_worker'

      expect(last_response.status).to eq 200

      response_body = compact_html(last_response.body)

      expect(response_body).to include(
        compact_html(
          '<form method="POST" action="/adhoc-jobs/sidekiq_adhoc_job_test_dummy_worker/schedule" id="adhoc-jobs-submit-form">'
        )
      )

      %w[id overwrite retry_job retries interval name options type dryrun].each do |field|
        expect(response_body).to include('<input class="form-control"')
        expect(response_body).to include("name=\"#{field}\"")
        expect(response_body).to include("id=\"#{field}\"")
      end
    end
  end

  context 'has rest args' do
    it 'generates form for running job' do
      get '/adhoc-jobs/sidekiq_adhoc_job_test_dummy_rest_args_worker'

      expect(last_response.status).to eq 200

      response_body = compact_html(last_response.body)

      expect(response_body).to include(
        compact_html(
          <<~HTML
            <form method="POST" action="/adhoc-jobs/sidekiq_adhoc_job_test_dummy_rest_args_worker/schedule" id="adhoc-jobs-submit-form">
          HTML
        )
      )

      expect(response_body).to include(
        compact_html(
          <<~HTML
            <div class="form-group row">
              <label class="col-sm-2 col-form-label" for="id">*id:</label>
              <div class="col-sm-4">
                <input class="form-control" type="text" name="id" id="id" required/>
              </div>
            </div>
          HTML
        )
      )

      expect(response_body).to include(
        compact_html(
          <<~HTML
            <div class="form-group row">
              <label class="col-sm-2 col-form-label" for="rest_args">Rest arguments (please provide a json string representing the arguments):</label>
              <div class="col-sm-4">
                <input class="form-control" type="text" name="rest_args" id="rest_args"/>
              </div>
            </div>
          HTML
        )
      )
    end
  end

  context 'no argument' do
    it 'generates form for running job' do
      get '/adhoc-jobs/sidekiq_adhoc_job_test_dummy_no_arg_worker'

      expect(last_response.status).to eq 200

      response_body = compact_html(last_response.body)

      expect(response_body).to include(
        compact_html(
          <<~HTML
            <form method="POST" action="/adhoc-jobs/sidekiq_adhoc_job_test_dummy_no_arg_worker/schedule" id="adhoc-jobs-submit-form">
          HTML
        )
      )

      expect(response_body).to include('<p>No job arguments</p>')
    end
  end

  context 'job not found' do
    it 'redirects to index page' do
      get '/adhoc-jobs/invalid_worker'

      expect(last_response.status).to eq 302
      expect(last_response.headers['Location']).to eq "#{last_request.base_url}/adhoc-jobs"
    end
  end
end
