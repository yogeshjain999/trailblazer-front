module ApplicationHelper
  def navbar_link_to(text, path)
    link_to text, path, class: "font-medium text-base uppercase hover:scale-110 lg:normal-case lg:font-semibold"
  end
end
