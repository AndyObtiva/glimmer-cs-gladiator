module Glimmer
  class Gladiator
    class ProgressShell
      include Glimmer::UI::CustomShell
  
      option :gladiator
      option :progress_text, default: 'Work In Progress'
  
      body {
        shell(gladiator.body_root, :title) {
          fill_layout(:vertical) {
            margin_width 15
            margin_height 15
            spacing 5
          }
          
          text 'Gladiator'
          
          label(:center) {
            text progress_text
            font height: 20
          }
#           @progress_bar = progress_bar(:horizontal, :indeterminate)
        }
      }
  
    end
  end
end
