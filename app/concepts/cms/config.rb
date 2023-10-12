module Cms
  module Config
    # TODO: move ViewsController::Pages here.
    TW = OpenStruct.new(
      p: {class: ""},
      pre: {class: ""},
      code: {class: "rounded"},
      codespan: {class: "text-purple"},
      h2: {class: "text-2xl font-bold text-neutral-500 lg:text-3xl py-2"}, # is from spacing/15 in tailwind.config.js.
      h3: {class: "font-bold text-neutral-500 lg:text-2xl text-xl py-2"}, # is from spacing/15 in tailwind.config.js.
      h4: {class: "font-bold text-neutral-500 lg:text-1xl text-xl py-2"}, # mt-15 is from spacing/15 in tailwind.config.js.
      a: {class: "underline text-purple"},
      img: {class: "mt-12 mb-12 mx-auto"},
      ul: {class: "space-y-2"},
      li: {class: "list-image-disc ml-10"},
    ).freeze

    def self.tailwind
      TW
    end
  end
end
