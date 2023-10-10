class Kramdown::Converter::Fuckyoukramdown < Kramdown::Converter::Html
  def convert_p(el, *args)
    el.attr.merge!(Cms::Config.tailwind.p)
    super
  end

  def convert_codespan(el, *args)
    el.attr.merge!(Cms::Config.tailwind.codespan)
    super
  end

  def convert_a(el, *args)
    el.attr.merge!(Cms::Config.tailwind.a)
    super
  end

  def convert_ul(el, *args)
    el.attr.merge!(Cms::Config.tailwind.ul)
    super
  end

  def convert_li(el, *args)
    el.attr.merge!(Cms::Config.tailwind.li)
    super
  end
end
