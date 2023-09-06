class ViewsController < ApplicationController
  require "cells"
  require "cells/__erb__"
  require "torture/cms"

  module Flow # DISCUSS: or "Steps" or something like that?
    def self.build(**steps)
      Class.new(Trailblazer::Activity::Railway) do
        steps.each do |name, options|
          step Torture::Cms::Page.method(:render_cell), **Flow.normalize_options(name, **options)
        end
      end
    end

    def self.normalize_options(name, template_file:, context_class:, options_for_cell:)
        template = ::Cell::Erb::Template.new(template_file) # TODO: of course, the cell should decide that.
        id = "render_#{name}"

        {
          id: id,
          Trailblazer::Activity::Railway.In() => [], # DISCUSS: change in TRB?
          Trailblazer::Activity::Railway.Inject(:context_class,     override: true) => ->(*) { context_class },
          Trailblazer::Activity::Railway.Inject(:template,          override: true) => ->(*) { template },
          Trailblazer::Activity::Railway.Inject(:options_for_cell,  override: true) => options_for_cell
        }
    end

    # Defaults for this app.
    @options_for_cell_without_content = ->(ctx, controller:, **) { {controller: controller} }
    @options_for_cell = ->(ctx, controller:, content:, **) { {yield_block: content, controller: controller} }
    singleton_class.attr_reader :options_for_cell_without_content, :options_for_cell
  end

  module My
    module Cell
      def self.delegate_to_controller_helpers(target, *methods) # FIXME: move to cells gem
        methods.each do |name|
          target.define_method name do |*args, **kws, &block|
            @options[:controller].helpers.send(name, *args, **kws, &block)
          end
        end
      end


      # This is delibarately a PORO, and not a cell, to play with the "exec_context" concept.
      class Section # #Torture::Cms::Section
        include Torture::Cms::Helper::Header # needs {headers}
        include Torture::Cms::Helper::Code   # needs {extract}

        def initialize(controller:, **options)
          @options = options.merge(controller: controller)
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

        My::Cell.delegate_to_controller_helpers(self, :image_tag)

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
        In() => ->(ctx, layout:, level_1_headers:, **) { {context_class: layout[:left_toc][:context_class], template: layout[:left_toc][:template], options_for_cell: {headers: level_1_headers}} },
        Out() => {:content => :left_toc_html}

      # Render "page layout" (not the app layout).
      step Torture::Cms::Page.method(:render_cell),
        id: :render_page,
        In() => ->(ctx, layout:, left_toc_html:, content:, **options) { {**layout, options_for_cell: {yield_block: content, left_toc_html: left_toc_html, version_options: options}} }

      # application_layout
      step Torture::Cms::Page.method(:render_cell).clone,
        id: :application_layout,
        In() => ->(ctx, content:, controller:, application_layout:, **) { {
          context_class: application_layout[:cell], template: application_layout[:template],
          options_for_cell: {yield_block: content, controller: controller}} }

      # HTML level layout with {stylesheet_link_tag} etc
      step Torture::Cms::Page.method(:render_cell).clone,
        id: :container_layout,
        In() => ->(ctx, content:, controller:, **) { {context_class: Cell::Container, template: ::Cell::Erb::Template.new("app/concepts/cell/application/container.erb"), options_for_cell: {yield_block: content, controller: controller}} }
    end

    module Cell
      class Container
        def initialize(controller:, **options)
          @options = options.merge(controller: controller)
        end

        My::Cell.delegate_to_controller_helpers(self, :csrf_meta_tags, :csp_meta_tag, :stylesheet_link_tag, :javascript_importmap_tags)

        def to_h
          {}
        end
      end

      class Layout
        # TODO: abstract into cells-5.
        module Render
          def initialize(controller:, **options)
            @options = options.merge(controller: controller)
          end

          My::Cell.delegate_to_controller_helpers(self, :link_to, :image_tag) # navbar.erb

          def render(template)
            ::Cell.({template: template, exec_context: self}) # DISCUSS: does {render} always mean we want the same exec_context?
          end

          def to_h
            {}
          end
        end

        include Render

        def navbar_link_to(text, path)
          link_to text, path, class: "font-medium text-base uppercase hover:scale-110 lg:normal-case lg:font-semibold"
        end
      end

      # This is delibarately a PORO, and not a cell, to play with the "exec_context" concept.
      class Section # #Torture::Cms::Section
        include Torture::Cms::Helper::Header # needs {headers}

        def initialize(controller:, **options)
          @options = options.merge(controller: controller)
        end

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
          In() => ->(ctx, layout:, left_toc_html:, right_tocs_html:, content:, **options) { {**layout, options_for_cell: {yield_block: content, left_toc_html: left_toc_html, right_tocs_html: right_tocs_html, version_options: options}} }

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

        My::Cell.delegate_to_controller_helpers(self, :link_to)

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

        def to_h # FIXME: why are we not returning headers here?
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
          section_dir: "section/activity",
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
          "troubleshooting.md.erb" => {section_dir: "section/developer", snippet_dir: "../trailblazer-developer/test/docs", snippet_file: "developer_test.rb" },
          "kitchen_sink.md.erb" => { snippet_file: "____test.rb" },
        }
      },

      "macro" => {
        toc_title: "Macro",
        "2.1" => {
          title: "Macro",
          snippet_dir: "../trailblazer-macro/test/docs",
          section_dir: "section/macro",
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
          section_dir: "section/operation",
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

  module Landing
    class Cell
      include Application::Cell::Layout::Render
    end

    Flow = Flow.build(
      page: {template_file: "app/concepts/cell/landing/landing.erb", context_class: Landing::Cell, options_for_cell: Flow.options_for_cell_without_content},
      html: {template_file: "app/concepts/cell/application/container.erb", context_class: Application::Cell::Container, options_for_cell: Flow.options_for_cell}
    )
  end

  module Pro
    class Cell
      include Application::Cell::Layout::Render
    end

    Flow = Flow.build(
      page:         {template_file: "app/concepts/cell/pro/pro.erb", context_class: Pro::Cell, options_for_cell: Flow.options_for_cell_without_content},
      application:  {template_file: "app/concepts/cell/application/layout.erb", context_class: Application::Cell::Layout, options_for_cell: Flow.options_for_cell},
      html:         {template_file: "app/concepts/cell/application/container.erb", context_class: Application::Cell::Container, options_for_cell: Flow.options_for_cell}
    )
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
          render: Pro::Flow,
        }
      },
    }

    pages = Torture::Cms::DSL.(pages)

    pages = Torture::Cms::Site.new.render_pages(pages,
      controller: self,
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
          render:      Landing::Flow,
        }
      },
    }

    pages = Torture::Cms::DSL.(pages)

    pages = Torture::Cms::Site.new.render_pages(pages,
    # pages = Torture::Cms::Site.new.produce_versioned_pages(pages, section_cell: My::Cell::Section,
      controller: self,

      kramdown_options: {converter: "to_fuckyoukramdown"}, # use Kramdown::Torture parser from the torture-server gem.
    )

    # raise pages[0].to_h["2.1"].inspect

    activity_content_html = pages[0].to_h["2.1"][:content]

    render html: activity_content_html.html_safe
  end

  def about;end

  def blog;end
end
