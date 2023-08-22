// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "./navigations"
import hljs from 'highlight.js/lib/core';
import ruby from 'highlight.js/lib/languages/ruby';

hljs.registerLanguage("ruby", ruby)
hljs.highlightAll();
