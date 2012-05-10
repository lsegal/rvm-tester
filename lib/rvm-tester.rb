require 'rake'
require 'rake/tasklib'
require 'mob_spawner'

module RVM
  module Tester
    VERSION = '1.0.0'

    class TesterTask < ::Rake::TaskLib
      def initialize(name = :suite)
        runner = Runner.new
        yield(runner) if block_given?
        desc "Runs tests across RVM Rubies: #{runner.rubies.join(",")}"
        task(name) { exit runner.run }
      end
    end

    class Runner
      attr_accessor :num_workers
      attr_accessor :rubies
      attr_accessor :env
      attr_accessor :command
      attr_accessor :verbose
      attr_accessor :bundle_install

      def initialize(opts = {})
        super()
        self.command = "rake"
        self.num_workers = 3
        self.env = {}
        self.rubies = []
        self.verbose = false
        self.bundle_install = true
        opts.each {|k,v| meth = "#{k}="; send(meth, v) if respond_to?(meth) }
      end

      def run
        exit_status = 0
        outputs = []
        use_gemfile if bundle_install
        commands = rubies.map do |ruby|
          MobSpawner::Command.new(
            :command => "rvm #{ruby} do #{command}",
            :env => env, :data => {:ruby => ruby, :time => nil})
          
        end
        spawner = MobSpawner.new
        spawner.commands = commands
        spawner.num_workers = num_workers
        spawner.before_worker do |data|
          worker, cmd = data[:worker], data[:command]
          debug "Worker #{worker} running tests in #{cmd.data[:ruby]}"
          data[:command].data[:time] = Time.now
        end
        spawner.after_worker do |data|
          worker, cmd = data[:worker], data[:command]
          next(outputs << data) if data[:output].nil?
          testinfo = data[:output][/(\d+ examples, \d+ failures)/, 1]
          testinfo += ", " if testinfo
          time = Time.now - data[:command].data[:time]
          passfail = data[:status] == 0 ? "passed" : "failed"
          msg = "Tests #{passfail} in #{cmd.data[:ruby]} (#{testinfo}#{"%.2f" % time}sec)"
          if data[:status] == 0
            outputs << data if verbose
            success(msg)
          else
            outputs << data
            exit_status = 255
            fail(msg)
          end
        end
        spawner.run

        return(exit_status) if outputs.size == 0
        puts
        outputs.each do |data|
          if data[:exception]
            bright "Exception while running #{data[:command].data[:ruby]}:"
            puts data[:exception].message
            puts data[:exception].backtrace
          else
            bright "Output for #{data[:command].data[:ruby]} " +
              "(#{data[:status]}, cmd=#{data[:command].command}):"
            puts data[:output]
          end
          puts
        end

        exit_status
      end

      def use_gemfile
        return unless File.file?("Gemfile")
        print "Installing Bundler and dependencies on #{rubies.join(",")}..."
        cmds = rubies.map do |r|
          ver = r == '1.8.6' ? '-v 1.0.22' : '' # Bundler compat for 1.8.6
          "rvm #{r} do gem install bundler #{ver} && rvm #{r} do bundle update"
        end
        MobSpawner.new(cmds).run
        puts "Done."
      end

      def debug(info)
        return unless verbose
        puts(info)
      end

      def success(msg)
        puts "\e[32;1m#{msg}\e[0m"
      end

      def fail(msg)
        puts "\e[31;1m#{msg}\e[0m"
      end

      def bright(msg)
        puts "\e[1m#{msg}\e[0m"
      end

      def puts(msg = '')
        super(msg)
        $stdout.flush
      end
    end
  end
end
