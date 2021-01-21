require 'glimmer-dsl-swt'

module Glimmer
  class Gladiator
    class Splash
      include Glimmer::UI::CustomShell
      
      display # pre-initialize SWT Display before any threads are later created, so they would auto-reuse it
      
      class << self
        def open
          sync_exec {
            @splash = splash
            @splash.open
          }
        end
        
        def close
          sync_exec {
            @splash.close
          }
        end
      end
      
      before_body {
        @shell_style = OS.windows? ? [:no_resize] : [:title, :on_top]
        @logo_image_path = ::File.expand_path(::File.join('..', '..', '..', '..', 'images', 'glimmer-cs-gladiator-logo.png'), __dir__)
        @original_logo_image = image(@logo_image_path)
        @logo_image = @original_logo_image.scale_to(256, 256)
      }
      
      body {
        shell(*@shell_style) {
          text 'Gladiator (Glimmer Editor)'
          minimum_size 256, 286
          image @original_logo_image
          
          canvas {
            background rgb(20, 130, 255)
            image @logo_image.swt_image, 0, 5
            
            animation {
              every 0.037
        
              frame {|index|
                background rgb(20, 30 + index%100, 155 + index%100)
                image @logo_image.swt_image, 0, 5
              }
            }
          }
        }
      }
    end
  end
end
