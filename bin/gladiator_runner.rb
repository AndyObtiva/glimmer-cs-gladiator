require_relative '../lib/glimmer-cs-gladiator'

include Glimmer

local_dir = ENV['LOCAL_DIR'] || '.'
gladiator(project_dir_path: local_dir).open