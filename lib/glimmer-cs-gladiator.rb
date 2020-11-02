$LOAD_PATH.unshift(File.expand_path('..', __FILE__))

require 'filewatcher'
require 'clipboard'
require 'puts_debuggerer'
require 'views/glimmer/gladiator'

# Custom Composite Initializer (avoid default margins)
Glimmer::SWT::WidgetProxy::DEFAULT_INITIALIZERS['composite'] = lambda do |composite|
  if composite.get_layout.nil?
    layout = GridLayout.new
    composite.layout = layout
  end
end

# Custom LayoutProxy initialize method (avoid default margins)
module Glimmer
  module SWT
    class LayoutProxy
      def initialize(underscored_layout_name, widget_proxy, args)
        @underscored_layout_name = underscored_layout_name
        @widget_proxy = widget_proxy
        args = SWTProxy.constantify_args(args)
        @swt_layout = self.class.swt_layout_class_for(underscored_layout_name).new(*args)
        @widget_proxy.swt_widget.setLayout(@swt_layout)
      end
    end
  end
end
