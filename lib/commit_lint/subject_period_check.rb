module Danger
  class DangerCommitLint < Plugin
    class SubjectPeriodCheck < CommitCheck # :nodoc:
      MESSAGE = 'Please remove period from end of commit subject line.'.freeze

      def self.type
        :subject_period
      end

      def initialize(message)
        @subject = message[:subject]
      end

      def fail?
        @subject.split('').last == '.'
      end
    end
  end
end
