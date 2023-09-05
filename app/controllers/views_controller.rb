class ViewsController < ApplicationController
  def documentation;end

  require "cells"
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

# FIXME: remove? abstract?
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

  module Application
    class Render < Trailblazer::Activity::Railway
      # Render left_toc.
      step Torture::Cms::Page.method(:render_cell).clone,
        id: :left_toc,
        In() => ->(ctx, layout:, level_1_headers:, **) { {cell: {context_class: layout[:left_toc][:context_class], template: layout[:left_toc][:template]}, options_for_cell: {headers: level_1_headers}} },
        Out() => {:content => :left_toc_html}

      # Render "page layout" (not the app layout).
      step Torture::Cms::Page.method(:render_cell),
        id: :render_page,
        In() => ->(ctx, layout:, left_toc_html:, content:, **options) { {cell: layout, options_for_cell: {yield_block: content, left_toc_html: left_toc_html, version_options: options}} }

      # application_layout
      step Torture::Cms::Page.method(:render_cell).clone,
        id: :application_layout,
        In() => ->(ctx, content:, controller:, application_layout:, **) { {
          cell: {context_class: application_layout[:cell], template: application_layout[:template]},
          options_for_cell: {yield_block: content, controller: controller}} }


      # HTML level layout with {stylesheet_link_tag} etc
      step Torture::Cms::Page.method(:render_cell).clone,
        id: :container_layout,
        In() => ->(ctx, content:, controller:, **) { {cell: {context_class: Cell::Container, template: ::Cell::Erb::Template.new("app/concepts/cell/application/container.erb")}, options_for_cell: {yield_block: content, controller: controller}} }
    end

    module Cell
      class Container
        def initialize(controller:, **options)
          @options = options.merge(controller: controller)
        end

        [:csrf_meta_tags, :csp_meta_tag, :stylesheet_link_tag, :javascript_importmap_tags
        ].each do |name|
          define_method name do |*args, **kws, &block|
            @options[:controller].helpers.send(name, *args, **kws, &block)
          end
        end

        def to_h
          {}
        end
      end

      class Layout
        def initialize(controller:, **options)
          @options = options.merge(controller: controller)
        end

        [:link_to, :image_tag, # navbar.erb
        ].each do |name|
          define_method name do |*args, **kws, &block|
            @options[:controller].helpers.send(name, *args, **kws, &block)
          end
        end

        def navbar_link_to(text, path)
          link_to text, path, class: "font-medium text-base uppercase hover:scale-110 lg:normal-case lg:font-semibold"
        end

        def render(template)
          ::Cell.({template: template, exec_context: self}) # DISCUSS: does {render} always mean we want the same exec_context?
        end

        def to_h
          {}
        end
      end

      # This is delibarately a PORO, and not a cell, to play with the "exec_context" concept.
      class Section # #Torture::Cms::Section
        include Torture::Cms::Helper::Header # needs {headers}

        def initialize(controller:, **options)
          @options = options.merge(controller: controller)
        end

#         def self.call(template:, exec_context:)
#           # html = super
#           _result = exec_context.(template: template) # returns {Result}.
#         end

# # FIXME: remove? abstract?
#         def call(template:, &block)
#           html = ::Cell.render(template: template, exec_context: self, &block)

#           # DISCUSS: make this optional?
#           ::Cell::Result.new(
#             content: html,
#             **to_h,
#           ).freeze
#         end

        def to_h
          {
            headers: @options[:headers]
          }
        end
      end
    end
  end

  module Documentation
    class Render < Application::Render # TODO: better naming.
      step :right_tocs, after: "Start.default"
      step Torture::Cms::Page.method(:render_cell),
          # id: :render_page,
          replace: :render_page,
          # inherit: [:variable_mapping],
          # In() => [:right_tocs_html]
          # TODO: allow adding to {options_for_cell} instead of repeating In() from Cms::Page.
          In() => ->(ctx, layout:, left_toc_html:, right_tocs_html:, content:, **options) { {cell: layout, options_for_cell: {yield_block: content, left_toc_html: left_toc_html, right_tocs_html: right_tocs_html, version_options: options}} }

      def right_tocs(ctx, headers:, right_toc:, **)
        right_tocs =
          headers[2].collect do |h2|
            cell_instance = right_toc[:cell].new(h2: h2, **right_toc[:options]) # DISCUSS: what options to hand in here?

            result = ::Cell.({template: right_toc[:template], exec_context: cell_instance})

            result.to_s
          end

        ctx[:right_tocs_html] = right_tocs.join("\n")
      end
    end

    module Cell
      class TocRight
        def initialize(controller:, h2:, **options)
          @options = options.merge(controller: controller, h2: h2)
        end

        [:link_to].each do |name|
          define_method name do |*args, **kws, &block|
            @options[:controller].helpers.send(name, *args, **kws, &block)
          end
        end

        def h2
          @options[:h2]
        end

        def css_id
          "right-toc-#{@options[:h2].id}"
        end

        def to_h
          {}
        end
      end

      class Layout
        def link_to(text, url, **options)
          %(<a href="" class="#{options[:class]}">#{text}</a>)
        end

        def initialize(left_toc_html:, right_tocs_html:, version_options:)
          @options = {left_toc_html: left_toc_html, right_tocs_html: right_tocs_html, documentation_title: version_options[:title]||raise }
        end

        def to_h
          {}
        end

        def toc_left
          @options[:left_toc_html]
        end

        def tocs_right
          @options[:right_tocs_html]
        end

        def documentation_title
          @options[:documentation_title]
        end
      end

      class TocLeft
        def initialize(headers:)
          @options = {headers: headers}
        end

        def link_to(text, url, **options)
          %(<a href="#{url}" class="#{options[:class]}">#{text}</a>)
        end

        def to_h
          {}
        end
      end
    end
  end

  def docs
    doc_layout_template = Cell::Erb::Template.new("app/concepts/cell/documentation/documentation.erb")

    left_toc_template = Cell::Erb::Template.new("app/concepts/cell/documentation/toc_left.erb")

    layout_options = {context_class: Documentation::Cell::Layout, template: doc_layout_template, left_toc: {context_class: Documentation::Cell::TocLeft, template: left_toc_template}}

    pages = {
      render: Documentation::Render,
      "activity" => {
        toc_title: "Activity",
        "2.1" => {
          title: "Activity",
          snippet_dir: "../trailblazer-activity-dsl-linear/test/docs",
          section_dir: "../website-NEW/app/concepts/documentation/page/snippet/activity",
          target_file: "public/2.1/docs/activity.html",
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
          target_file: "public/2.1/docs/macro.html",
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
          target_file: "public/2.1/docs/operation.html",
          target_url: "/2.1/docs/operation/index.html",
          layout: layout_options,
        }
      }

    }


    pages = Torture::Cms::DSL.(pages)

    pages = Torture::Cms::Site.new.render_pages(pages, section_cell: My::Cell::Section,
    # pages = Torture::Cms::Site.new.produce_versioned_pages(pages, section_cell: My::Cell::Section,
      section_cell_options: {
        controller: self,
        pre_attributes: Rails.application.config.tailwind.pre,
        code_attributes: Rails.application.config.tailwind.code,
      },

      kramdown_options: {converter: "to_fuckyoukramdown"}, # use Kramdown::Torture parser from the torture-server gem.

      application_layout: {cell: Application::Cell::Layout, template: Cell::Erb::Template.new("app/concepts/cell/application/layout.erb"), options: {controller: self}},
      right_toc: {cell: Documentation::Cell::TocRight, template: Cell::Erb::Template.new("app/concepts/cell/documentation/toc_right.erb"), options: {controller: self}},

      controller: self, # TODO: pass this to all cells.
    )

    activity_content_html = pages[0].to_h["2.1"][:content]

    render html: activity_content_html.html_safe
  end

  class RenderLanding < Trailblazer::Activity::Railway
    # Render "page layout" (not the app layout).
    step Torture::Cms::Page.method(:render_cell),
      id: :render_page,
      In() => ->(ctx, controller:, page_template:, page_cell:, **options) { {cell: {context_class: page_cell, template: page_template}, options_for_cell: {yield_block: nil, controller: controller}} }

    step Torture::Cms::Page.method(:render_cell).clone,
        id: :container_layout,
        In() => ->(ctx, content:, controller:, **) { {cell: {context_class: Application::Cell::Container, template: ::Cell::Erb::Template.new("app/concepts/cell/application/container.erb")}, options_for_cell: {yield_block: content, controller: controller}} }
  end

  class RenderPro < RenderLanding
    class Cell
      def initialize(**options)
        @options = options
      end

      [:image_tag, :link_to].each do |name|
        define_method name do |*args, **kws, &block|
          @options[:controller].helpers.send(name, *args, **kws, &block)
        end
      end

      def to_h
        {}
      end
    end

    step Torture::Cms::Page.method(:render_cell).clone,
      id: :render_application_layout,
      In() => ->(ctx, controller:, content:, **options) {
        {cell: {context_class: Application::Cell::Layout, template: ::Cell::Erb::Template.new("app/concepts/cell/application/layout.erb")},
        options_for_cell: {yield_block: content, controller: controller}} }


  end


  def product
    # doc_layout_template = Cell::Erb::Template.new("app/concepts/cell/documentation/documentation.erb")
    # layout_options = {cell: Documentation::Cell::Layout, template: doc_layout_template}

    pages = {
      "pro_page" => {
        toc_title: "Trailblazer PRO",
        "2.1" => {
          title: "Trailblazer PRO",
          snippet_dir: "../trailblazer-activity-dsl-linear/test/docs",
          section_dir: "sections/page",
          target_file: "public/2.1/pro.html",
          target_url:  "/2.1/pro.html",
          # layout:      layout_options,
          render: RenderPro,
        }
      },
    }

    pages = Torture::Cms::DSL.(pages)

    pages = Torture::Cms::Site.new.render_pages(pages,
      controller: self,

      page_template: ::Cell::Erb::Template.new("app/concepts/cell/pro/pro.erb"),
      page_cell:     RenderPro::Cell,

      kramdown_options: {converter: "to_fuckyoukramdown"}, # use Kramdown::Torture parser from the torture-server gem.

      # application_layout: {cell: Application::Cell::Layout, template: Cell::Erb::Template.new("app/concepts/cell/application/layout.erb"), options: {controller: self}},
    )

    # raise pages[0].to_h["2.1"].inspect

    activity_content_html = pages[0].to_h["2.1"][:content]

    render html: activity_content_html.html_safe
  end

  def landing
    pages = {
      "landing" => {
        toc_title: "Trailblazer",
        "2.1" => {
          title: "Trailblazer",
          snippet_dir: "../trailblazer-activity-dsl-linear/test/docs",
          section_dir: "sections/page",
          target_file: "public/2.1/pro.html",
          target_url:  "/2.1/pro.html",
          render:      RenderLanding, # no layout, nothing!
        }
      },
    }

    pages = Torture::Cms::DSL.(pages)

    pages = Torture::Cms::Site.new.render_pages(pages,
    # pages = Torture::Cms::Site.new.produce_versioned_pages(pages, section_cell: My::Cell::Section,
      controller: self,
      page_template: ::Cell::Erb::Template.new("app/concepts/cell/landing/landing.erb"),
      page_cell:     RenderPro::Cell,

      kramdown_options: {converter: "to_fuckyoukramdown"}, # use Kramdown::Torture parser from the torture-server gem.
    )

    # raise pages[0].to_h["2.1"].inspect

    activity_content_html = pages[0].to_h["2.1"][:content]

    render html: activity_content_html.html_safe
  end

  def about;end

  def blog;end
end
