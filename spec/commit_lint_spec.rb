require File.expand_path('../spec_helper', __FILE__)

# rubocop:disable Metrics/LineLength

TEST_MESSAGES = {
  subject_length: 'This is a really long subject line and should result in an error',
  subject_period: 'This subject line ends in a period.',
  empty_line: "This subject line is fine\nBut then I forgot the empty line separating the subject and the body.",
  all_errors: "This is a really long subject and it even ends in a period.\nNot to mention the missing empty line!",
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

    describe 'check without configuration' do
      context 'with invalid messages' do
        it 'fails those checks' do
          checks = {
            subject_length: SubjectLengthCheck::MESSAGE,
            subject_period: SubjectPeriodCheck::MESSAGE,
            empty_line: EmptyLineCheck::MESSAGE
          }

          for (check, warning) in checks
            commit_lint = testing_dangerfile.commit_lint
            commit = double(:commit, message: TEST_MESSAGES[check])
            allow(commit_lint.git).to receive(:commits).and_return([commit])

            commit_lint.check

            status_report = commit_lint.status_report
            expect(report_counts(status_report)).to eq 1
            expect(status_report[:errors]).to eq [warning]
          end
        end
      end

      context 'with all errors' do
        it 'fails every check' do
          commit_lint = testing_dangerfile.commit_lint
          commit = double(:commit, message: TEST_MESSAGES[:all_errors])
          allow(commit_lint.git).to receive(:commits).and_return([commit])

          commit_lint.check

          status_report = commit_lint.status_report
          expect(report_counts(status_report)).to eq 3
          expect(status_report[:errors]).to eq [
            SubjectLengthCheck::MESSAGE,
            SubjectPeriodCheck::MESSAGE,
            EmptyLineCheck::MESSAGE
          ]
        end
      end

      context 'with valid messages' do
        it 'does nothing' do
          checks = {
            subject_length: SubjectLengthCheck::MESSAGE,
            subject_period: SubjectPeriodCheck::MESSAGE,
            empty_line: EmptyLineCheck::MESSAGE
          }

          for _ in checks
            commit_lint = testing_dangerfile.commit_lint
            commit = double(:commit, message: TEST_MESSAGES[:valid])
            allow(commit_lint.git).to receive(:commits).and_return([commit])

            commit_lint.check

            status_report = commit_lint.status_report
            expect(report_counts(status_report)).to eq 0
          end
        end
      end
    end

    describe 'disable configuration' do
      context 'with individual checks' do
        context 'with invalid messages' do
          it 'does nothing' do
            checks = {
              subject_length: SubjectLengthCheck::MESSAGE,
              subject_period: SubjectPeriodCheck::MESSAGE,
              empty_line: EmptyLineCheck::MESSAGE
            }

            for (check, _) in checks
              commit_lint = testing_dangerfile.commit_lint
              commit = double(:commit, message: TEST_MESSAGES[check])
              allow(commit_lint.git).to receive(:commits).and_return([commit])

              commit_lint.check disable: [check]

              status_report = commit_lint.status_report
              expect(report_counts(status_report)).to eq 0
            end
          end
        end
      end

      context 'with all checks, implicitly' do
        it 'warns that nothing was checked' do
          commit_lint = testing_dangerfile.commit_lint
          commit = double(:commit, message: TEST_MESSAGES[:all_errors])
          allow(commit_lint.git).to receive(:commits).and_return([commit])

          all_checks = [:subject_length, :subject_period, :empty_line]
          commit_lint.check disable: all_checks

          status_report = commit_lint.status_report
          expect(report_counts(status_report)).to eq 1
          expect(status_report[:warnings]).to eq [NOOP_MESSAGE]
        end
      end

      context 'with all checks, explicitly' do
        it 'warns that nothing was checked' do
          commit_lint = testing_dangerfile.commit_lint
          commit = double(:commit, message: TEST_MESSAGES[:all_errors])
          allow(commit_lint.git).to receive(:commits).and_return([commit])

          commit_lint.check disable: :all

          status_report = commit_lint.status_report
          expect(report_counts(status_report)).to eq 1
          expect(status_report[:warnings]).to eq [NOOP_MESSAGE]
        end
      end
    end

    describe 'warn configuration' do
      context 'with individual checks' do
        context 'with invalid messages' do
          it 'warns instead of failing' do
            checks = {
              subject_length: SubjectLengthCheck::MESSAGE,
              subject_period: SubjectPeriodCheck::MESSAGE,
              empty_line: EmptyLineCheck::MESSAGE
            }

            for (check, warning) in checks
              commit_lint = testing_dangerfile.commit_lint
              commit = double(:commit, message: TEST_MESSAGES[check])
              allow(commit_lint.git).to receive(:commits).and_return([commit])

              commit_lint.check warn: [check]

              status_report = commit_lint.status_report
              expect(report_counts(status_report)).to eq 1
              expect(status_report[:warnings]).to eq [warning]
            end
          end
        end

        context 'with valid messages' do
          it 'does nothing' do
            checks = {
              subject_length: SubjectLengthCheck::MESSAGE,
              subject_period: SubjectPeriodCheck::MESSAGE,
              empty_line: EmptyLineCheck::MESSAGE
            }

            for (check, _) in checks
              commit_lint = testing_dangerfile.commit_lint
              commit = double(:commit, message: TEST_MESSAGES[:valid])
              allow(commit_lint.git).to receive(:commits).and_return([commit])

              commit_lint.check warn: [check]

              status_report = commit_lint.status_report
              expect(report_counts(status_report)).to eq 0
            end
          end
        end
      end

      context 'with all checks' do
        context 'with all errors' do
          it 'warns instead of failing' do
            commit_lint = testing_dangerfile.commit_lint
            commit = double(:commit, message: TEST_MESSAGES[:all_errors])
            allow(commit_lint.git).to receive(:commits).and_return([commit])

            commit_lint.check warn: :all

            status_report = commit_lint.status_report
            expect(report_counts(status_report)).to eq 3
            expect(status_report[:warnings]).to eq [
              SubjectLengthCheck::MESSAGE,
              SubjectPeriodCheck::MESSAGE,
              EmptyLineCheck::MESSAGE
            ]
          end
        end

        context 'with a valid message' do
          it 'does nothing' do
            commit_lint = testing_dangerfile.commit_lint
            commit = double(:commit, message: TEST_MESSAGES[:valid])
            allow(commit_lint.git).to receive(:commits).and_return([commit])

            commit_lint.check warn: :all

            status_report = commit_lint.status_report
            expect(report_counts(status_report)).to eq 0
          end
        end
      end
    end

    describe 'fail configuration' do
      context 'with individual checks' do
        context 'with invalid messages' do
          it 'fails those checks' do
            checks = {
              subject_length: SubjectLengthCheck::MESSAGE,
              subject_period: SubjectPeriodCheck::MESSAGE,
              empty_line: EmptyLineCheck::MESSAGE
            }

            for (check, warning) in checks
              commit_lint = testing_dangerfile.commit_lint
              commit = double(:commit, message: TEST_MESSAGES[check])
              allow(commit_lint.git).to receive(:commits).and_return([commit])

              commit_lint.check fail: [check]

              status_report = commit_lint.status_report
              expect(report_counts(status_report)).to eq 1
              expect(status_report[:errors]).to eq [warning]
            end
          end
        end

        context 'with valid messages' do
          it 'does nothing' do
            checks = {
              subject_length: SubjectLengthCheck::MESSAGE,
              subject_period: SubjectPeriodCheck::MESSAGE,
              empty_line: EmptyLineCheck::MESSAGE
            }

            for (check, _) in checks
              commit_lint = testing_dangerfile.commit_lint
              commit = double(:commit, message: TEST_MESSAGES[:valid])
              allow(commit_lint.git).to receive(:commits).and_return([commit])

              commit_lint.check fail: [check]

              status_report = commit_lint.status_report
              expect(report_counts(status_report)).to eq 0
            end
          end
        end
      end

      context 'with all checks' do
        context 'with all errors' do
          it 'fails those checks' do
            commit_lint = testing_dangerfile.commit_lint
            commit = double(:commit, message: TEST_MESSAGES[:all_errors])
            allow(commit_lint.git).to receive(:commits).and_return([commit])

            commit_lint.check fail: :all

            status_report = commit_lint.status_report
            expect(report_counts(status_report)).to eq 3
            expect(status_report[:errors]).to eq [
              SubjectLengthCheck::MESSAGE,
              SubjectPeriodCheck::MESSAGE,
              EmptyLineCheck::MESSAGE
            ]
          end
        end

        context 'with a valid message' do
          it 'does nothing' do
            commit_lint = testing_dangerfile.commit_lint
            commit = double(:commit, message: TEST_MESSAGES[:valid])
            allow(commit_lint.git).to receive(:commits).and_return([commit])

            commit_lint.check fail: :all

            status_report = commit_lint.status_report
            expect(report_counts(status_report)).to eq 0
          end
        end
      end
    end
  end
end

# rubocop:enable Metrics/ClassLength
