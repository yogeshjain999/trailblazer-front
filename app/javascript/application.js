import hljs from 'highlight.js/lib/core';
import ruby from 'highlight.js/lib/languages/ruby';
import anchorJS from 'anchor-js';

import ScrollSpy from 'scrollspy';
import 'navigations'; // FIXME: here, part of the code should only be run when "docs".

import jquery from 'jquery';

import { ParallaxScroll } from "jquery.parallax-scroll";


// import  './jquery.scrollspy';

hljs.registerLanguage('ruby', ruby);
hljs.highlightAll();

if (pageIdentifier == "landing") {
  jquery(document).ready(function() {
    ParallaxScroll.init();

    // TODO: move to separate  function/file.
    jquery('div.user-group').click(function (event) {
      var tab_clicked     = jquery(event.target);
      var class_selected  = tab_clicked.attr("data-selected-class");

      jquery('div.user-group').removeClass(class_selected);

      var content = tab_clicked.next().clone();

      tab_clicked.addClass(class_selected);
      jquery('#users-content').children().replaceWith(content);
      jquery('#users-content ul').removeClass('hidden');
    });

    jquery('div.user-group').first().click();
  });
}

if (pageIdentifier == "docs") {
  jquery(document).ready(function() {
    // jquery("#documentation").scrollSpy();

    let h2_map = [];

    // compile time!
    jquery("#documentation h2").each(function(index, trigger_el) {
      var trigger_element = jquery(trigger_el);
      var right_toc_id    = `#right-toc-${trigger_element.attr('id')}`; // toc div that belongs to this trigger_element/h2.

      // console.log(right_toc_id)
      h2_map.push(
        {
          offset_top:   trigger_el.offsetTop,
          element:      trigger_element,
          toc_element:  jquery(right_toc_id), // for H2 -> h3/h4 right tocs.
        }
      )
    });
    console.log(h2_map)

    let current_h2 = h2_map[0]; // FIXME: how to initialize that?

    // let last_scrolltop = 0; // FIXME: can we avoid those globals?

    let h2_listener = function (event) {
      var _window = jquery(window);
      let scroll_top = _window.scrollTop(); // where are we at the top of viewport?
      let scroll_bottom = _window.innerHeight() + scroll_top;


      current_h2 = find_closest_trigger_element(h2_map, scroll_top, scroll_bottom);


      jquery(h2_map).each(function(i, h2) {
        h2['toc_element'].removeClass("display_block");
        // h2['toc_element'].addClass("display_none");  // FIXME: optimize.
      });

      jquery(current_h2['toc_element']).addClass("display_block");
    }

    function find_closest_trigger_element(trigger_element_map, scroll_top, scroll_bottom) {
      for (let i = 0; i < trigger_element_map.length - 1; i++) {
        let h2 = trigger_element_map[i];
        let h2_top = h2['offset_top'];

        // console.log(`${scroll_top} ${h2_top}`)
        if (h2_top > scroll_top) {
          if (h2_top < scroll_bottom) {
            // trigger_element is within viewport.
            return h2;
          } else {
            // trigger_element is not yet in viewport.
            return trigger_element_map[i-1];
          }
          // break;
        }
      }
    }

    // console.log(jquery("#documentation"))
    jquery(window).on("scroll", h2_listener);



    // ScrollSpy.init();

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
