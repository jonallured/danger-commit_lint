module Danger
  class DangerCommitLint < Plugin
    class SubjectCapCheck < CommitCheck # :nodoc:
      MESSAGE = 'Please start commit message subject with capital letter.'.freeze

      def self.type
        :subject_cap
      end

      def initialize(message)
        @first_character = message[:subject].split('').first
      end

      def fail?
        @first_character != @first_character.upcase
      end
    end
  end
end
