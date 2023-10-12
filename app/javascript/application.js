import hljs from 'highlight.js/lib/core';
import ruby from 'highlight.js/lib/languages/ruby';
import anchorJS from 'anchor-js';

import ScrollSpy from 'scrollspy';
import 'navigations'; // FIXME: here, part of the code should only be run when "docs".

import jquery from 'jquery';

import { ParallaxScroll } from "jquery.parallax-scroll";

if (pageIdentifier == "landing") {
  jquery(document).ready(function() {
    ParallaxScroll.init();

    // TODO: move to separate  function/file.
    jquery('div.user-group').click(function (event) {
      var tab_clicked     = jquery(event.target);
      var class_selected  = tab_clicked.attr("data-selected-class");

      jquery('div.user-group').removeClass(class_selected);

      var content = tab_clicked.next();

      tab_clicked.addClass(class_selected);
      // jquery('#users-content').replaceWith(content);
      jquery('#users-content').html(content.html()) ;
    });
  });
}

if (pageIdentifier == "docs") {
  jquery(document).ready(function() {
    hljs.registerLanguage('ruby', ruby);
    hljs.highlightAll();

    ScrollSpy.init();

    var anchors = new anchorJS();
    anchors.add('h2, h3, h4');

    // listen for click on tab links
    jquery('a[data-toggle="code-tab"]').click(function (event) {
      var tab_clicked = jquery(event.target);
      var show_type    = tab_clicked.attr("data-show"); // code-tab-activity
      var hide_type    = tab_clicked.attr("data-hide"); // code-tab-operation

      // Retrieve colors for tab from the clicked. We could do that with a global class instead.
      var show_tab_color = tab_clicked.attr("data-show-color");
      var hide_tab_color = tab_clicked.attr("data-hide-color");

      // hide *all* operations code snippets, show all activity code snippets.
      jquery(`div.${hide_type}`).hide();
      jquery(`div.${show_type}`).show();

      // find all tabs
      var deactivated_tabs  = jquery(`span[data-show="${hide_type}"]`)
      var activated_tabs    = jquery(`span[data-show="${show_type}"]`)

      // change colors of tabs
      deactivated_tabs.removeClass(show_tab_color);
      deactivated_tabs.addClass(hide_tab_color);

      activated_tabs.removeClass(hide_tab_color);
      activated_tabs.addClass(show_tab_color);

      event.preventDefault();
    });
  });
}
