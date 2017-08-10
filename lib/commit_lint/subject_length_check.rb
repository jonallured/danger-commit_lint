module Danger
  class DangerCommitLint < Plugin
    class SubjectLengthCheck < CommitCheck # :nodoc:
      MESSAGE = 'Please limit commit subject line to 50 characters.'.freeze
      GIT_GENERATED_SUBJECT = /^Merge (pull request #\d+ from\ |\
                                       branch \'.+\' into\ )/

      attr_reader :subject

      def self.type
        :subject_length
      end

      def initialize(message)
        @subject = message[:subject]
      end

      def fail?
        subject.length > 50 && !merge_commit?
      end

      def merge_commit?
        subject =~ GIT_GENERATED_SUBJECT
      end
    end
  end
end
