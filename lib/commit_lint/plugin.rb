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

      for message in messages
        for (check, klass) in enabled_checks
          checker = klass.new(message)
          fail ERROR_MESSAGES[check] if checker.fail?
        end
      end
    end

    private

    def checks
      {
        subject_length: SubjectLengthCheck,
        subject_period: SubjectPeriodCheck,
        empty_line: EmptyLineCheck
      }
    end

    def enabled_checks
      checks.delete_if { |key, _| disabled_checks.include? key }
    end

    def all_checks_disabled?
      @config[:disable] == :all || disabled_checks.count == 3
    end

    def disabled_checks
      @config[:disable] || []
    end

    def messages
      git.commits.map do |commit|
        (subject, empty_line) = commit.message.split("\n")
        { subject: subject, empty_line: empty_line }
      end
    end

    class SubjectLengthCheck
      def initialize(message)
        @subject = message[:subject]
      end

      def fail?
        @subject.length > 50
      end
    end

    class SubjectPeriodCheck
      def initialize(message)
        @subject = message[:subject]
      end

      def fail?
        @subject.split('').last == '.'
      end
    end

    class EmptyLineCheck
      def initialize(message)
        @empty_line = message[:empty_line]
      end

      def fail?
        @empty_line && !@empty_line.empty?
      end
    end
  end
end
