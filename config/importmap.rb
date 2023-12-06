# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "anchor-js", preload: true # @5.0.0
pin "navigations"
pin "docsearch" # the local file we wrote.

# bin/importmap pin --download highlight.js/lib/core DOESN'T WORK I downloaded highlight.js/lib/core.js manually and put it in vendor with the --ed name
#                              highlight.js/lib/languages/ruby
pin "highlight.js/lib/core", to: "highlight.js--lib--core.js" # @11.9.0
pin "highlight.js/lib/languages/ruby", to: "highlight.js--lib--languages--ruby.js" # @11.9.0
pin "jquery" # @3.7.1
pin "jquery.parallax-scroll"
# bin/importmap pin @docsearch/js@3
pin "@docsearch/js", to: "https://cdn.jsdelivr.net/npm/@docsearch/js@3.5.2/dist/umd/index.min.js"
