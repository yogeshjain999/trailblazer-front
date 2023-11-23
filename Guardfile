require_relative "config/environment"

module ::Guard
  # https://github.com/guard/guard/wiki/Create-a-guard
  class Torture < Plugin
  end
end

puts "========= Guardfile:"
pages_config, pages, returned, controller = Cms::Render.call()


file_to_page_map  = returned.fetch(:file_to_page_map)
book_headers        = returned[:book_headers]

guard :torture do
  # This runs the modified test
  watch /section\/(.*)/ do |m|
    # pp file_to_page_map

    book_name, version = file_to_page_map.fetch(m[0])
    puts %(Re-rendering #{book_name}/#{version} because #{m[0].inspect} changed...)


    book_options = pages_config.fetch(book_name)[:versions].fetch(version).fetch(:options)
    book_sections = pages_config.fetch(book_name)[:versions].fetch(version).fetch(:sections)

    if book_headers[book_name].versions_to_h2_headers[version]
      # only applies to docs with h2 headers, not landing page.
      book_headers[book_name].versions_to_h2_headers[version].items = [] # FIXME: they will be recomputed in {render_page}.
    end

    page, _ = ::Torture::Cms::Site.render_page(name: book_name, sections: book_sections, book_headers: book_headers, version: version, **book_options)

    page, _ = ::Torture::Cms::Site.render_final_page([book_name, version], book_headers: book_headers,  controller: controller, **page)
    page, _ = ::Torture::Cms::Site.produce_page(**page)
  end

  # Reload when ViewsController changes
  watch("app/controllers/views_controller.rb") { Guard.queue.instance_variable_get(:@commander).reload }
  # and reload when images are added (veeery convenient).
  watch("app/assets/images") { puts "IMAGE"; Guard.queue.instance_variable_get(:@commander).reload } # FIXME: not called!
end
