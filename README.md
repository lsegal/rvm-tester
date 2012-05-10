# RVM Tester

Runs tests across Ruby installations in RVM using concurrent worker processes.
This library does not sandbox installations, and requires that you have already
installed the necessary Ruby installations under RVM.

This project is heavily inspired by [Travis-CI](http://travis-ci.org), but is meant
to provide a more lightweight interface that can be run on your development machine
or a dedicated server. Because there is no VM sandboxing, you can also have more
control over your test environments, as well as your Ruby versions. Note that rvm-tester
is not meant as a replacement to Travis-CI, but rather to be used in parallel with
the service for extra coverage in different environments that might not be supported.
In other words, this tool is *not* a CI, but it can be used to perform useful local
debugging of tests under multiple Ruby environments.

## Installing

In addition to installing this library with `gem install rvm-tester`, you will also need
to setup RVM with the proper Ruby installations. RVM documentation can help with this,
but a simple command to install 1.8.7 would be:

    $ rvm install 1.8.7

rvm-tester also works with Bundler and Travis-CI meta-data files to setup your
tests. See the Integration section below for more information on setting up
your environment with these tools.

## Usage

You can either use this library via the Rake task or directly via the Runner class:

### Rake Task

Place the following in your `Rakefile`:

```ruby
require 'rvm-tester'
RVM::Tester::TesterTask.new(:suite) do |t|
  t.rubies = %w(1.8.6 1.8.7 1.9.2 1.9.3) # which versions to test (required!)
  t.bundle_install = true                # updates Gemfile.lock, default is true
  t.use_travis = true                    # looks for Rubies in .travis.yml (on by default)
  t.command = "bundle exec rake test"    # runs plain "rake" by default
  t.env = {"VERBOSE" => "1"}             # set any ENV vars
  t.num_workers = 5                      # defaults to 3
  t.verbose = true                       # shows more output, off by default
end
```

And simply run the task with `rake suite`. The output will look something
like (output with `verbose=false`):

```plain
Installing Bundler and dependencies on 1.8.6,1.8.7,1.9.2,1.9.3...
Tests passed in 1.9.3 (1527 examples, 0 failures, 18.92sec)
Tests failed in 1.9.2 (1527 examples, 5 failures, 20.29sec)
Tests passed in 1.8.6 (1527 examples, 0 failures, 20.26sec)
Tests passed in 1.8.7 (1527 examples, 0 failures, 20.72sec)

Output for 1.9.2 (pid 11241 exit 1, cmd=rvm 1.9.2 do bundle exec rake test):
[SOME FAILING TEST OUTPUT HERE]
```

The Rake task also creates a task named "suite:deps" (or the task name + :deps)
to perform only the `bundle update` portion of the task. This allows you to
disable the automatic `bundle_install` setting, which can significantly
speed up the time to run tests, while still enabling you to manually run the
updater across all of your Ruby installations with the simple command:

```sh
$ rake suite:deps
```

### Runner Class

You can also run the runner directly. The "t" object passed in the task above
is the runner class, so you would set it up in the same way. You can also pass
all attributes via the options hash.

```ruby
runner = RVM::Tester::Runner.new(:rubies => %w(rbx 1.9.3), :verbose => true)
runner.run
```

## Integration

### Bundler

If you have a Gemfile and use the "bundle_install" setting in RVM tester (on by
default), rvm-tester will also install the gem dependencies for your project before
running the tests. If you do not use Bundler, you will have to make sure that each
environment has the correct gems installed prior to testing. You can do this with
the following command:

    $ rvm all do gem install gem1 gem2 gem3 ...

Where "gem1 gem2 gem3 ..." are the dependencies needed by your project.

### Travis-CI

rvm-tester can automatically detect a `.travis.yml` file in your project and
use it to detect Ruby versions and commands to execute. Note that currently,
only the "rvm", "script" and "env" fields are used from the configuration file.
If you do not want to use the `.travis.yml` file, set `use_travis = false`.

## Dependencies

This library depends on [RVM](http://rvm.io) to control
Ruby installations and [mob_spawner](http://github.com/lsegal/mob_spawner) to
spawn worker processes.

## License & Copyright

RVM Tester is licensed under the MIT license, &copy; 2012 Loren Segal
