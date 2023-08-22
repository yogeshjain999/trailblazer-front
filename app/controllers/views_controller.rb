class ViewsController < ApplicationController
  def landing;end

  def product;end

  def documentation

  end

  require "cell"
  require "cells/__erb__"
  require "torture/cms"
  require "kramdown"

  module My
    module Cell
      # This is delibarately a PORO, and not a cell, to play with the "exec_context" concept.
      class Section # #Torture::Cms::Section
        include Torture::Cms::Helper::Header # needs {headers}
        include Torture::Cms::Helper::Code   # needs {extract}

        def initialize(options)
          @options = options
        end

        def vite_image_tag(*)
          # FIXME: implement etc
        end

      end
    end
  end

  def docs
    # TODO: app layout is still AV

    pages = {
      # "cells" => {
      #   title: "Cells",
      #   "4.0" => { # "prefix/version"
      #     snippet_dir: "test/cells/",
      #     section_dir: "test/sections/cells/4.0",
      #     target_file: "test/site/2.1/docs/cells/index.html",
      #     "overview.md.erb" => { snippet_file: "cell_test.rb" }
      #   },
      #   "5.0" => {
      #     snippet_dir: "test/cells-5/",
      #     section_dir: "test/sections/cells/5.0",
      #     target_file: "test/site/2.1/docs/cells/5.0/index.html",
      #   }
      # },
      # "reform" => {
      #   title: "Reform",
      #   "2.3" => {
      #     snippet_dir: "test/code/reform",
      #     section_dir: "test/sections/reform",
      #     target_file: "test/site/2.1/docs/reform/index.html",
      #     "intro.md.erb" => { snippet_file: "intro_test.rb" }
      #   }
      # }
      "activity" => {
        title: "Activity",
        "2.1" => {
          snippet_dir: "../trailblazer-activity-dsl-linear/test/docs",
          section_dir: "../website-NEW/app/concepts/documentation/page/snippet/activity",
          target_file: "tmp/activity.html",
          "task_wrap.md.erb" => { snippet_file: "task_wrap_test.rb" }
        }
      }
    }



    pages = pages.collect do |name, options|
      Torture::Cms::Site.new.render_versioned_pages(**options, section_cell: My::Cell::Section)
    end

    activity_content_html = File.open("tmp/activity.html").read

    template = Cell::Erb::Template.new("app/concepts/cell/documentation/documentation.erb")


    doc_layout_cell = Class.new do
      def link_to(text, url, **options)
        %(<a href="" class="#{options[:class]}">#{text}</a>)
      end
    end.new

    # Render docs in documentation layout.
    result = Cell.({template: template, exec_context: doc_layout_cell}) { activity_content_html }

    # Render documentation layout in app layout. :D
    render html: result.to_s.html_safe, layout: true
  end

  def about;end

  def blog;end
end
