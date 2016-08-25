module Danger
  class DangerCommitLint < Plugin
    ERROR_MESSAGES = {
      subject_length: 'Please limit commit subject line to 50 characters.',
      subject_period: 'Please remove period from end of commit subject line.',
      empty_line: 'Please separate subject from body with newline.'
    }

    def check
      for commit in git.commits
        (subject, empty_line) = commit.message.split("\n")
        fail ERROR_MESSAGES[:subject_length] if subject.length > 50
        fail ERROR_MESSAGES[:subject_period] if subject.split('').last == '.'
        fail ERROR_MESSAGES[:empty_line] if empty_line && empty_line.length > 0
      end
    end
  end
end
