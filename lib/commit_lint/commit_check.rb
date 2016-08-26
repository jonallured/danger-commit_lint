module Danger
  class DangerCommitLint < Plugin
    class CommitCheck # :nodoc:
      def self.fail?(message)
        new(message).fail?
      end

      def initialize(message); end

      def fail?
        raise 'implement in subclass'
      end
    end
  end
end
