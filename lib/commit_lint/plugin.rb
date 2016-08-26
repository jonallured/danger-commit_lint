module Danger
  class DangerCommitLint < Plugin
    NOOP_MESSAGE = 'All checks were disabled, nothing to do.'.freeze

    def check(config = {})
      @config = config

      if all_checks_disabled?
        warn NOOP_MESSAGE
      else
        check_messages
      end
    end

    private

    def check_messages
      for message in messages
        for klass in warning_checkers
          warn klass::MESSAGE if klass.fail? message
        end

        for klass in failing_checkers
          # rubocop:disable Style/SignalException
          fail klass::MESSAGE if klass.fail? message
          # rubocop:enable Style/SignalException
        end
      end
    end

    def checkers
      [SubjectLengthCheck, SubjectPeriodCheck, EmptyLineCheck]
    end

    def checks
      checkers.map(&:type)
    end

    def enabled_checkers
      checkers.reject { |klass| disabled_checks.include? klass.type }
    end

    def warning_checkers
      enabled_checkers.select { |klass| warning_checks.include? klass.type }
    end

    def failing_checkers
      enabled_checkers - warning_checkers
    end

    def all_checks_disabled?
      @config[:disable] == :all || disabled_checks.count == checkers.count
    end

    def disabled_checks
      @config[:disable] || []
    end

    def warning_checks
      return checks if @config[:warn] == :all
      @config[:warn] || []
    end

    def messages
      git.commits.map do |commit|
        (subject, empty_line) = commit.message.split("\n")
        { subject: subject, empty_line: empty_line }
      end
    end
  end
end
