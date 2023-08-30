import hljs from 'highlight.js/lib/core';
import ruby from 'highlight.js/lib/languages/ruby';
import anchorJS from 'anchor-js';
import ScrollMagic from 'scrollmagic';

import "./navigations"

document.addEventListener('DOMContentLoaded', function () {
  hljs.registerLanguage("ruby", ruby)
  hljs.highlightAll();

  var anchors = new anchorJS();
  anchors.add();

  var controller = new ScrollMagic.Controller();
  new ScrollMagic.Scene({
    offset: 145,
    duration: '200%'
  })
    .setPin('#right-toc')
    .addTo(controller);
});
