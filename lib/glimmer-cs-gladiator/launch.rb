command_mode = ENV['GLADIATOR_COMMAND_MODE'] == 'true'
require_relative '../views/glimmer/gladiator/splash' unless command_mode

startup = lambda do
  require_relative '../glimmer-cs-gladiator'
  
  include Glimmer
  
  sync_exec {
    local_dir = ENV['LOCAL_DIR'] || '.'
    gladiator_instance = gladiator(project_dir_path: local_dir)
    Glimmer::Gladiator::Splash.close unless command_mode
    gladiator_instance.open
  }
end

if command_mode
  startup.call
else
  Thread.new(&startup)
end

Glimmer::Gladiator::Splash.open unless command_mode
