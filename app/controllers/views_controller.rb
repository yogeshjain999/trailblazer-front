class ViewsController < ApplicationController
  def landing;end

  def product;end

  def documentation

  end

  require "cell"
  require "cells/__erb__"
  require "torture/cms"

  module My
    module Cell
      # This is delibarately a PORO, and not a cell, to play with the "exec_context" concept.
      class Section # #Torture::Cms::Section
        include Torture::Cms::Helper::Header # needs {headers}
        include Torture::Cms::Helper::Code   # needs {extract}

        def initialize(controller:, **options)
          @options = options.merge(controller: controller)
        end

        def self.call(template:, exec_context:)
          # html = super
          _result = exec_context.(template: template) # returns {Result}.
        end

        def call(template:, &block)
          html = ::Cell.render(template: template, exec_context: self, &block)

          # DISCUSS: make this optional?
          ::Cell::Result.new(
            content: html,
            **to_h,
          ).freeze
        end

        def to_h
          {
            headers: @options[:headers]
          }
        end

        def code_tabs(*args, **kws) # TODO: implement tabs
          code(*args, **kws)
        end
        def api(*) # FIXME: implement

        end


        def vite_image_tag(*)
          # FIXME: implement etc
        end

            # = image_tag "info_icon.svg"
        def info(type: :info, &block) # TODO: use cell for this.
          # TODO: allow kramdown
          %(<div class="rounded flex p-4 gap-4 mt-5 bg-bg-purple-1/50">
          #{@options[:controller].helpers.image_tag "info_icon.svg"}
<p>
  #{yield}
</p>
</div>)
        end

        def warning(&block)  # TODO: use info parametrized.
          # TODO: allow kramdown
          %(<div class="rounded flex p-4 gap-4 mt-5 bg-bg-orange">
          #{@options[:controller].helpers.image_tag "light_bulb_icon.svg"}
<p>
  #{yield}
</p>
</div>)
        end

        module H
          def h2(*args, **options)
            super(*args, **options, classes: "text-2xl font-bold text-neutral-500 lg:text-3xl mt-6")
          end

          def h3(*args, **options)
            super(*args, **options, classes: "font-bold text-neutral-500 lg:text-2xl mt-6 text-xl")
          end

          def h4(*args, **options)
            super(*args, **options, classes: "font-bold text-neutral-500 lg:text-1xl mt-4 text-xl")
          end
        end

        include H
      end
    end
  end

  def docs
    # TODO: app layout is still AV

    doc_layout_template = Cell::Erb::Template.new("app/concepts/cell/documentation/documentation.erb")

    doc_layout_cell = Class.new do
      def link_to(text, url, **options)
        %(<a href="" class="#{options[:class]}">#{text}</a>)
      end

      def initialize(left_toc_html:, version_options:)
        @options = {left_toc_html: left_toc_html, documentation_title: version_options[:title]||raise }
      end

      def to_h
        {}
      end

      def toc_left
        @options[:left_toc_html]
      end

      def documentation_title
        @options[:documentation_title]
      end
    end

    left_toc = Class.new do
      def initialize(headers:, current_page:)
        @options = {
          headers: headers,
          current_page: current_page
        }
      end

      def link_to(text, url, **options)
        %(<a href="" class="#{options[:class]}">#{text}</a>)
      end

      def to_h
        {}
      end
    end

    left_toc_template = Cell::Erb::Template.new("app/concepts/cell/documentation/toc_left.erb")

    layout_options = {cell: doc_layout_cell, template: doc_layout_template, left_toc: {cell: left_toc, template: left_toc_template}}

    pages = {
      "activity" => {
        toc_title: "Activity",
        "2.1" => {
          title: "Activity",
          snippet_dir: "../trailblazer-activity-dsl-linear/test/docs",
          section_dir: "../website-NEW/app/concepts/documentation/page/snippet/activity",
          target_file: "tmp/activity.html",
          target_url:  "/2.1/docs/activity/index.html",
          layout:      layout_options,

          "activity.md.erb" => { snippet_file: "basics_test.rb" },
          "dsl/strategy.md.erb" => { snippet_file: "strategy_test.rb" },
          "dsl/api.md.erb" => { snippet_file: "basics_test.rb" },
          "dsl/path.md.erb" => { snippet_file: "path_test.rb" },
          "dsl/subprocess.md.erb" => { snippet_file: "subprocess_test.rb" },
          "dsl/options.md.erb" => { snippet_file: "subprocess_test.rb" },
          "dsl/sequence.md.erb" => { snippet_file: "sequence_options_test.rb" },
          "dsl/patching.md.erb" => { snippet_file: "patching_test.rb" },
          "dsl/composable_variable_mapping.md.erb" => { snippet_file: "composable_variable_mapping_test.rb" },
          "dsl/variable_mapping.md.erb" => { snippet_file: "variable_mapping_test.rb" },
          "dsl/macro.md.erb" => { snippet_file: "macro_test.rb" },
          "internals.md.erb" => { snippet_file: "macro_test.rb" },
          "internals/introspect.md.erb" => { snippet_file: "introspect_test.rb" },
          "interfaces.md.erb" => { snippet_file: "activity_test.rb" },
          "task_wrap.md.erb" => { snippet_file: "task_wrap_test.rb" },
          "troubleshooting.md.erb" => {section_dir: "../website-NEW/app/concepts/documentation/page/snippet/developer", snippet_dir: "../trailblazer-developer/test/docs", snippet_file: "developer_test.rb" },
          "kitchen_sink.md.erb" => { snippet_file: "____test.rb" },
        }
      },

      "macro" => {
        toc_title: "Macro",
        "2.1" => {
          title: "Macro",
          snippet_dir: "../trailblazer-macro/test/docs",
          section_dir: "../website-NEW/app/concepts/documentation/page/snippet/macro",
          target_file: "tmp/macro.html",
          target_url: "/2.1/docs/macro/index.html",
          layout: layout_options,

          "overview.md.erb"   => {snippet_file: "model_test.rb"},
          "nested/dynamic.md.erb"   => {snippet_file: "nested_static_test.rb"},
          "nested/auto_wire.md.erb"   => {snippet_file: "nested_static_test.rb"},
          "wrap.md.erb"   => {snippet_file: "wrap_test.rb"},
          "each.md.erb"   => {snippet_file: "each_test.rb"},
          "model_find.md.erb"   => {snippet_file: "model/find_test.rb"},
          "model.md.erb"   => {snippet_file: "model_test.rb"},
          "rescue.md.erb"   => {snippet_file: "rescue_test.rb"},
          "policy.md.erb"   => {snippet_file: "policy_test.rb"},
        }
      },

      "operation" => {
        toc_title: "Operation",
        "2.1" => {
          title: "Operation",
          snippet_dir: "../trailblazer-operation/test/docs",
          section_dir: "../website-NEW/app/concepts/documentation/page/snippet/operation",
          target_file: "tmp/operation.html",
          target_url: "/2.1/docs/operation/index.html",
          layout: layout_options,
        }
      }

    }


    # raise helpers.image_tag( "info_icon.svg").inspect
    pages = Torture::Cms::DSL.(pages)

    pages = Torture::Cms::Site.new.render_pages(pages, section_cell: My::Cell::Section,
      section_cell_options: {
        controller: self,
        pre_attributes: Rails.application.config.tailwind.pre,
        code_attributes: Rails.application.config.tailwind.code,
      },

      kramdown_options: {converter: "to_fuckyoukramdown"}, # use Kramdown::Torture parser from the torture-server gem.
    )

    activity_content_html = pages[0].to_h["2.1"][:content]

    # Render documentation layout in app layout. :D
    render html: activity_content_html.html_safe, layout: true
  end

  def about;end

  def blog;end
end
