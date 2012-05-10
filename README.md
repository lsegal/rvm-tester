# RVM Tester

Runs tests across Ruby installations in RVM using concurrent worker processes.
This library does not sandbox installations, and requires that you have already
installed the necessary Ruby installations under RVM.

## Installing

In addition to installing this library with `gem install rvm-tester`, you will also need
to setup

## Usage

You can either use this library via the Rake task or directly via the Runner class:

### Rake Task

Place the following in your `Rakefile`:

```ruby
require 'rvm-tester'
RVM::Tester::TesterTask.new(:suite) do |t|
  t.rubies = %w(1.8.6 1.8.7 1.9.2 1.9.3) # which versions to test (required!)
  t.bundle_install = true                # updates Gemfile.lock, default is true
  t.command = "bundle exec rake test"    # runs plain "rake" by default
  t.env = {"VERBOSE" => "1"}             # set any ENV vars
  t.num_workers = 5                      # defaults to 3
  t.verbose = true                       # shows more output, off by default
end
```

And simply run the task with `rake suite`.

### Runner Class

You can also run the runner directly. The "t" object passed in the task above
is the runner class, so you would set it up in the same way. You can also pass
all attributes via the options hash.

```ruby
runner = RVM::Tester::Runner.new(:rubies => %w(rbx 1.9.3), :verbose => true)
runner.run
```

## Dependencies

This library depends on [RVM](http://rvm.beginrescueend.com) to control
Ruby installations and [mob_spawner](http://github.com/lsegal/mob_spawner) to
spawn worker processes.

## License & Copyright

MobSpawner is licensed under the MIT license, &copy; 2012 Loren Segal
