Rails.application.routes.draw do
  root "views#landing"

  get"/product", to: "views#product"
  get "/documentation", to: "views#documentation"
  get "/docs", to: "views#docs"
  get"/about", to: "views#about"
  get"/blog", to: "views#blog"
end
