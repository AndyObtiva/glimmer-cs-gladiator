# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'glimmer/launcher'
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "glimmer-cs-gladiator"
  gem.homepage = "http://github.com/AndyObtiva/glimmer-cs-gladiator"
  gem.license = "MIT"
  gem.summary = %Q{Gladiator (Glimmer Editor) - Glimmer Custom Shell - Text Editor Built in Ruby}
  gem.description = %Q{Gladiator (short for Glimmer Editor) is a Glimmer sample project under on-going development. It is not intended to be a full-fledged editor by any means, yet mostly a fun educational exercise in using Glimmer to build a text editor. Gladiator is also a personal tool for shaping an editor exactly the way I like. I leave building truly professional text editors to software tooling experts who would hopefully use Glimmer one day.}
  gem.post_install_message = "\nTo make the gladiator command available system-wide (especially with RVM), make sure you run this command with jruby in path: gladiator-setup\n\n"
  gem.email = "andy.am@gmail.com"
  gem.authors = ["Andy Maleh"]
  gem.files = Dir['README.md', 'VERSION', 'CHANGELOG.md', 'LICENSE.txt', 'glimmer-cs-gladiator.gemspec', 'images/glimmer-cs-gladiator-logo.png', 'lib/**/*.rb', 'bin/**/*']
  gem.executables = ['glimmer-cs-gladiator', 'gladiator', 'gladiator-setup']
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
  spec.ruby_opts = [Glimmer::Launcher.jruby_os_specific_options]
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['spec'].execute
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "glimmer-cs-gladiator #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :no_puts_debuggerer do
  ENV['puts_debuggerer'] = 'false'
end

Rake::Task["build"].enhance([:no_puts_debuggerer, :spec]) unless OS.windows? && ARGV.include?('release')

namespace :build do
  desc 'Builds without running specs for quick testing, but not release'
  task :prototype => :no_puts_debuggerer do
    Rake::Task['build'].execute
  end
end


require 'glimmer/rake_task'

Glimmer::RakeTask::Package.javapackager_extra_args =
  " -name 'Gladiator'" +
  " -title 'Gladiator'" +
  " -Bwin.menuGroup='Gladiator'" +
  " -Bmac.CFBundleName='Gladiator'" +
  " -Bmac.CFBundleIdentifier='org.glimmer.application.Gladiator'" +
  " -BappVersion=1.0.0 " + # TODO drop this once app crosses v1.0.0 (currently is below and cannot packaged, so must set 1)
  " -Bmac.CFBundleVersion=1.0.0 " # TODO drop this once app crosses v1.0.0 (currently is below and cannot packaged, so must set 1)
  # " -BlicenseType=" +
  # " -Bmac.category=" +
  # " -Bmac.signing-key-developer-id-app="
