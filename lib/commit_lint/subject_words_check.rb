module Danger
  class DangerCommitLint < Plugin
    class SubjectWordsCheck < CommitCheck # :nodoc:
      MESSAGE = 'Please use more than one word.'.freeze

      def self.type
        :subject_words
      end

      def initialize(message)
        @subject = message[:subject]
      end

      def fail?
        @subject.split.count < 2
      end
    end
  end
end
