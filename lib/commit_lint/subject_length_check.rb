module Danger
  class DangerCommitLint < Plugin
    class SubjectLengthCheck < CommitCheck
      MESSAGE = 'Please limit commit subject line to 50 characters.'.freeze

      def self.type
        :subject_length
      end

      def initialize(message)
        @subject = message[:subject]
      end

      def fail?
        @subject.length > 50
      end
    end
  end
end
