require File.expand_path('../spec_helper', __FILE__)

# rubocop:disable Metrics/LineLength

MESSAGES = {
  with_period: 'This subject line ends in a period.',
  long: 'This is a really long subject line and should result in an error',
  no_empty: "This subject line is fine\nBut then I forgot the empty line separating the subject and the body.",
  valid:  "This is a valid message\n\nYou can tell because it meets all the criteria and the linter does not complain."
}.freeze

# rubocop:enable Metrics/LineLength

def report_counts(status_report)
  status_report.values.flatten.count
end

# rubocop:disable Metrics/ClassLength

module Danger
  class DangerCommitLint
    describe 'DangerCommitLint' do
      it 'should be a plugin' do
        expect(Danger::DangerCommitLint.new(nil)).to be_a Danger::Plugin
      end
    end

    describe 'check' do
      before do
        @dangerfile = testing_dangerfile
        @commit_lint = @dangerfile.commit_lint
        allow(@dangerfile.git).to receive(:commits).and_return([commit])
      end

      let(:commit) { double(:commit, message: message) }

      context 'with a long subject line' do
        let(:message) { MESSAGES[:long] }

        it 'adds an error for the subject_line check' do
          @commit_lint.check

          status_report = @commit_lint.status_report
          expect(report_counts(status_report)).to eq 1
          expect(status_report[:errors]).to eq [SubjectLengthCheck::MESSAGE]
        end
      end

      context 'with a period at the end of the subject line' do
        let(:message) { MESSAGES[:with_period] }

        it 'adds an error for the subject_period check' do
          @commit_lint.check

          status_report = @commit_lint.status_report
          expect(report_counts(status_report)).to eq 1
          expect(status_report[:errors]).to eq [SubjectPeriodCheck::MESSAGE]
        end
      end

      context 'without an empty line between subject and body' do
        let(:message) { MESSAGES[:no_empty] }

        it 'adds an error for the empty_line check' do
          @commit_lint.check

          status_report = @commit_lint.status_report
          expect(report_counts(status_report)).to eq 1
          expect(status_report[:errors]).to eq [EmptyLineCheck::MESSAGE]
        end
      end

      context 'with a valid commit message' do
        let(:message) { MESSAGES[:valid] }

        it 'does nothing' do
          @commit_lint.check

          status_report = @commit_lint.status_report
          expect(report_counts(status_report)).to eq 0
        end
      end
    end

    describe 'disabling' do
      before do
        @dangerfile = testing_dangerfile
        @commit_lint = @dangerfile.commit_lint
        allow(@dangerfile.git).to receive(:commits).and_return([commit])
      end

      let(:commit) { double(:commit, message: message) }

      context 'skipping subject length check' do
        let(:message) { MESSAGES[:long] }

        it 'does nothing' do
          @commit_lint.check disable: [:subject_length]

          status_report = @commit_lint.status_report
          expect(report_counts(status_report)).to eq 0
        end
      end

      context 'skipping subject period check' do
        let(:message) { MESSAGES[:with_period] }

        it 'does nothing' do
          @commit_lint.check disable: [:subject_period]

          status_report = @commit_lint.status_report
          expect(report_counts(status_report)).to eq 0
        end
      end

      context 'skipping empty line check' do
        let(:message) { MESSAGES[:no_empty] }

        it 'does nothing' do
          @commit_lint.check disable: [:empty_line]

          status_report = @commit_lint.status_report
          expect(report_counts(status_report)).to eq 0
        end
      end

      context 'skipping all checks explicitly' do
        let(:message) { MESSAGES[:long] }

        it 'warns that nothing was checked' do
          @commit_lint.check disable: :all

          status_report = @commit_lint.status_report
          expect(report_counts(status_report)).to eq 1
          expect(status_report[:warnings]).to eq [NOOP_MESSAGE]
        end
      end

      context 'skipping all checks implicitly' do
        let(:message) { MESSAGES[:long] }

        it 'warns that nothing was checked' do
          all_checks = [:subject_length, :subject_period, :empty_line]
          @commit_lint.check disable: all_checks

          status_report = @commit_lint.status_report
          expect(report_counts(status_report)).to eq 1
          expect(status_report[:warnings]).to eq [NOOP_MESSAGE]
        end
      end
    end
  end
end

# rubocop:enable Metrics/ClassLength
