# encoding: utf-8

# Copyright (c) 2012, HipByte SPRL and contributors
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'motion/project/app'
require 'motion/util/version'

App = Motion::Project::App
App.template = :'ios-extension'

require 'motion/project'
require 'motion/project/template/ios-watch-extension-config'
require 'motion/project/template/ios-watch-extension-builder'

desc "Build the simulator version"
task :default => :"build:simulator"

desc "Build everything"
task :build => ['build:simulator', 'build:device']

namespace :build do
  def pre_build_actions(platform)
    # TODO: Ensure Info.plist gets regenerated on each build so it has ints for
    # Instruments and strings for normal builds.
    rm_f File.join(App.config.app_bundle(platform), 'Info.plist')

    # TODO this should go into a iOS specific Builder class which performs this
    # check before building.
    App.config.resources_dirs.flatten.each do |dir|
      next unless File.exist?(dir)
      Dir.entries(dir).grep(/^Resources$/i).each do |basename|
        path = File.join(dir, basename)
        if File.directory?(path)
          suggestion = basename == 'Resources' ? 'Assets' : 'assets'
          App.fail "An iOS application cannot be installed if it contains a " \
                   "directory called `resources'. Please rename the " \
                   "directory at path `#{path}' to, for instance, " \
                   "`#{File.join(dir, suggestion)}'."
        end
      end
    end
  end

  desc "Build the simulator version"
  task :simulator do
    pre_build_actions('iPhoneSimulator')
    App.build('iPhoneSimulator')
  end

  desc "Build the device version"
  task :device do
    pre_build_actions('iPhoneOS')
    App.build('iPhoneOS')
    App.codesign('iPhoneOS')
  end
end

# This task should be called by the host application _after_ the host
# application and its extensions (including this watch app) have been built.
#
# TODO Once everything's done, see what should be abstracted between this task
# and the normal iOS task to launch on the sim.
desc "Run the simulator"
task :simulator do
  app = App.config.embedded_watch_app_bundle
  app_executable = File.expand_path(App.config.embedded_watch_app_executable)

  if ENV['TMUX']
    tmux_default_command = `tmux show-options -g default-command`.strip
    unless tmux_default_command.include?("reattach-to-user-namespace")
      App.warn(<<END

    It appears you are using tmux without 'reattach-to-user-namespace', the simulator might not work properly. You can either disable tmux or run the following commands:

      $ brew install reattach-to-user-namespace
      $ echo 'set-option -g default-command "reattach-to-user-namespace -l $SHELL"' >> ~/.tmux.conf

END
      )
    end
  end

  # Watch apps are iPhone only
  family_int = 1
  # TODO be sure to get this data in the same way we normally do when launching
  # the sim.
  simulate_device = 'iPhone 6'
  target = App.config.sdk_version

  # Launch the simulator.
  xcode = App.config.xcode_dir
  env = "DYLD_FRAMEWORK_PATH=\"#{xcode}/../Frameworks\":\"#{xcode}/../OtherFrameworks\""
  env << " RM_BUILT_EXECUTABLE=\"#{app_executable}\""
  env << ' SIM_SPEC_MODE=1' if App.config.spec_mode
  sim = File.join(App.config.bindir, 'ios/sim')
  debug = (ENV['debug'] ? 1 : 0)
  app_args = (ENV['args'] or '')
  App.info 'Simulate', app
  at_exit { system("stty echo") } if $stdout.tty? # Just in case the simulator launcher crashes and leaves the terminal without echo.
  Signal.trap(:INT) { } if ENV['debug']
  system "#{env} #{sim} #{debug} #{family_int} \"#{simulate_device}\" #{target} \"#{xcode}\" \"#{app}\" #{app_args}"
  App.config.print_crash_message if $?.exitstatus != 0 && !App.config.spec_mode
  exit($?.exitstatus)
end

namespace :archive do
  desc "Build for distribution (AppStore)"
  task :distribution do
    App.config_without_setup.build_mode = :release
    App.config_without_setup.distribution_mode = true
    Rake::Task["build:device"].invoke
  end
end