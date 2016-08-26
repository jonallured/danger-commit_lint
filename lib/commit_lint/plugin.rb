module Danger
  # Run each commit in the PR through a message linting.
  #
  # @example Lint all commits using defaults
  #
  #          commit_lint.check
  #
  # @example Warn instead of fail
  #
  #          commit_lint.check warn: :all
  #
  # @example Disable a particular check
  #
  #          commit_lint.check disable: [:subject_period]
  #
  # @see danger/danger
  # @tags commit linting
  #
  class DangerCommitLint < Plugin
    NOOP_MESSAGE = 'All checks were disabled, nothing to do.'.freeze

    # Checks the commits with whatever config the user passes.
    #
    # @param [Hash] config
    #        This hash can contain the following keys:
    #
    #        * `disable` - array of checks to skip
    #        * `fail` - array of checks to fail on
    #        * `warn` - array of checks to warn on
    #
    #        The current check types are:
    #
    #        * `subject_length`
    #        * `subject_period`
    #        * `empty_line`
    #
    #        Note: you can pass :all instead of an array to target all checks.
    #
    # @return [void]
    #
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
