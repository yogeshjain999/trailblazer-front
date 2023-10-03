Rails.application.config.tailwind = OpenStruct.new(
    p: {class: "mt-6"},
    pre: {class: "mt-4"},
    code: {class: "rounded mt-9"},
    codespan: {class: "text-purple"},
    h2: {class: "text-2xl font-bold text-neutral-500 lg:text-3xl mt-15"}, # mt-15 is from spacing/15 in tailwind.config.js.
    h3: {class: "font-bold text-neutral-500 lg:text-2xl mt-15 text-xl"}, # mt-15 is from spacing/15 in tailwind.config.js.
    h4: {class: "font-bold text-neutral-500 lg:text-1xl mt-15 text-xl"}, # mt-15 is from spacing/15 in tailwind.config.js.
    a: {class: "underline text-purple"},
  ).freeze


class Kramdown::Converter::Fuckyoukramdown < Kramdown::Converter::Html
  def convert_p(el, *args)
    el.attr.merge!(Rails.application.config.tailwind.p)
    super
  end

  def convert_codespan(el, *args)
    el.attr.merge!(Rails.application.config.tailwind.codespan)
    super
  end

  def convert_a(el, *args)
    el.attr.merge!(Rails.application.config.tailwind.a)
    super
  end
end
