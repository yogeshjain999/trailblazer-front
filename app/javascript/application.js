// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import anchorJS from 'anchor-js';
import ScrollMagic from 'scrollmagic';

import './navigations';

document.addEventListener('DOMContentLoaded', function () {
  var anchors = new anchorJS();
  anchors.add();

  var controller = new ScrollMagic.Controller();

  new ScrollMagic.Scene({
    offset: 145,
    duration: '200%'
  })
    .setPin('#right-toc') // pins the element for the the scene's duration
    .addTo(controller);
});
