# Commit Lint for Danger

[![Build Status](https://travis-ci.org/jonallured/danger-commit_lint.svg?branch=master)](https://travis-ci.org/jonallured/danger-commit_lint)

This is a [Danger Plugin][danger] that ensures nice and tidy commit messages.

[danger]: http://danger.systems/plugins/commit_lint.html

## Installation

```
$ gem install danger-commit_lint
```

## Usage

Simply add this to your Dangerfile:

```ruby
commit_lint.check
```

That will check each commit in the PR to ensure the following is true:

* Commit subject begins with a capital letter (`subject_cap`)
* Commit subject is no longer than 50 characters (`subject_length`)
* Commit subject does not end in a period (`subject_period`)
* Commit subject and body are separated by an empty line (`empty_line`)

By default, Commit Lint fails, but you can configure this behavior.

## Configuration

Configuring Commit Lint is done by passing a hash. The three keys that can be
passed are:

* `disable`
* `fail`
* `warn`

To each of these keys you can pass either the symbol `:all` or an array of
checks. Here are some ways you could configure Commit Lint:

```ruby
# warn on all checks (instead of failing)
commit_lint.check warn: :all

# disable the `subject_period` check
commit_lint.check disable: [:subject_period]
```

Remember, by default all checks are run and they will fail. Think of this as the
default:

```ruby
commit_lint.check fail: :all
```

Also note that there is one more way that Commit Lint can behave:

```ruby
commit_lint.check disable: :all
```

This will actually throw a warning that Commit Lint isn't doing anything.
