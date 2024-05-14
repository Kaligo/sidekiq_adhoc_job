require_relative "../../../lib/sidekiq_adhoc_job/utils/class_inspector"

RSpec.describe SidekiqAdhocJob::Utils::ClassInspector do
  subject(:inspector) { described_class.new(klass) }

  let(:klass) { SidekiqAdhocJob::Test::DummyWorker }

  describe "#parameters" do
    it do
      expect(inspector.parameters(:perform)).to eq({
        key: [{ key: :dryrun, default: nil }],
        keyreq: [{ key: :type, default: nil }],
        opt: [
          { key: :retry_job, default: nil },
          { key: :retries, default: nil },
          { key: :interval, default: nil },
          { key: :name, default: nil },
          { key: :options, default: nil }
        ],
        req: [
          { key: :id, default: nil },
          { key: :overwrite, default: nil }
        ]
      })
    end
  end

  context "with a method that has been prepended" do
    let(:klass) { SidekiqAdhocJob::Test::PrependedWorker }

    describe "#parameters" do
      it "returns the parameters of the original method" do
        expect(inspector.parameters(:perform)).to eq({
          opt: [:retry_job, :retries, :interval],
          req: [:id, :overwrite]
        })
      end
    end
  end

  context "with a method that is both prepended and inherited" do
    let(:klass) { SidekiqAdhocJob::Test::PrependedAndInheritedWorker }

    describe "#parameters" do
      it "returns the parameters of the method on the target class" do
        expect(inspector.parameters(:perform)).to eq({
          opt: [:retry_job, :retries, :interval],
          req: [:id, :overwrite]
        })
      end
    end
  end
end
