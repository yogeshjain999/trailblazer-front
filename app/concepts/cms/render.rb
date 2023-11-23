module Cms
  module Render
    # Compile/render the entire site.
    def self.call
      pages_config = ::Torture::Cms::DSL.(ViewsController::Pages)

      controller = ViewsController.new()
      req = ActionDispatch::Request.new 'HTTP_HOST' => 'example.com'
      controller.instance_variable_set(:@_request, req)

      puts "here comes full site compile"
      pages, returned = ::Torture::Cms::Site.produce_versioned_pages(pages_config,
        controller: controller, # TODO: pass this to all cells.
      )

      return pages_config, pages, returned
    end
  end
end
