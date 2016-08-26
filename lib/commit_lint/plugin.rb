module Danger
  class DangerCommitLint < Plugin
    ERROR_MESSAGES = {
      subject_length: 'Please limit commit subject line to 50 characters.',
      subject_period: 'Please remove period from end of commit subject line.',
      empty_line: 'Please separate subject from body with newline.',
      noop: 'All checks were disabled, nothing to do.'
    }.freeze

    def check(config = {})
      @config = config

      if all_checks_disabled?
        warn ERROR_MESSAGES[:noop]
        return
      end

      for commit in git.commits
        (subject, empty_line) = commit.message.split("\n")
        fail ERROR_MESSAGES[:subject_length] if subject.length > 50 && !disabled_checks.include?(:subject_length)
        fail ERROR_MESSAGES[:subject_period] if subject.split('').last == '.' && !disabled_checks.include?(:subject_period)
        fail ERROR_MESSAGES[:empty_line] if empty_line && !empty_line.empty? && !disabled_checks.include?(:empty_line)
      end
    end

    private

    def all_checks_disabled?
      @config[:disable] == :all || disabled_checks.count == 3
    end

    def disabled_checks
      @config[:disable] || []
    end
  end
end
