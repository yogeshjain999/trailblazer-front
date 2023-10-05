module Cms
  module Config
    # TODO: move ViewsController::Pages here.
    TW = OpenStruct.new(
      p: {class: ""},
      pre: {class: ""},
      code: {class: "rounded"},
      codespan: {class: "text-purple"},
      h2: {class: "text-2xl font-bold text-neutral-500 lg:text-3xl"}, # is from spacing/15 in tailwind.config.js.
      h3: {class: "font-bold text-neutral-500 lg:text-2xl text-xl"}, # is from spacing/15 in tailwind.config.js.
      h4: {class: "font-bold text-neutral-500 lg:text-1xl text-xl"}, # mt-15 is from spacing/15 in tailwind.config.js.
      a: {class: "underline text-purple"},
      img: {class: "mt-12 mb-12 mx-auto"},
    ).freeze

    def self.tailwind
      TW
    end
  end
end
