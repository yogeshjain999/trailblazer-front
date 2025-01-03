import hljs from 'highlight.js/lib/core';
import ruby from 'highlight.js/lib/languages/ruby';
import anchorJS from 'anchor-js';

import 'navigations'; // FIXME: here, part of the code should only be run when "docs".

import jquery from 'jquery';

import { ParallaxScroll } from "jquery.parallax-scroll";

hljs.registerLanguage('ruby', ruby);
hljs.highlightAll();

if (pageIdentifier == "landing") {
  jquery(document).ready(function() {
    import("lottie-player");

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
    import("docsearch");

    let h2_map = [];

    // wyof-scrollspy
    // compile time!
    jquery("#documentation h2").each(function(index, trigger_el) {
      var trigger_element = jquery(trigger_el);
      let trigger_id      = trigger_element.attr('id');
      var right_toc_id    = `#right-toc-${trigger_id}`; // toc div that belongs to this trigger_element/h2.
      var left_toc_id     = `#left-toc-${trigger_id}`; // div with link in left toc.

      h2_map.push(
        {
          element:      trigger_element,
          target:       jquery(right_toc_id), // for H2 -> h3/h4 right tocs.
          left_target:  jquery(left_toc_id),
        }
      )
    });

    // DISCUSS: we could key H3/H4 under H2.
    let h3_map = [];
    let h4_map = new Map();

    jquery("#documentation h3, #documentation h4").each(function(index, trigger_el) {
      var trigger_element = jquery(trigger_el);

      let h_id = trigger_element.attr('id');
      let h_in_toc = jquery(`#right-toc [href="#${h_id}"]`);

      if (trigger_element.prop("tagName") == "H3") {
        h3_map.push(
          {
            element:      trigger_element,
            target:       h_in_toc,
          }
        )

        h4_map.set(trigger_element, []);
      } else {
        // h4
        let current_h3 = h3_map[h3_map.length - 1].element;

        // FIXME: we should do some error handling here.
        h4_map.get(current_h3).push(
          {
            element:      trigger_element,
            target:       h_in_toc,
          }
        )
      }
    });

    let active_h2 = null;
    let active_left_h2 = null;
    let active_h3 = null;
    let active_h4 = null;
    let _window = jquery(window);

    let h2_listener = function (event) {
      let scroll_top = _window.scrollTop(); // where are we at the top of viewport?
      let scroll_bottom = _window.innerHeight() + scroll_top;

    // H2 / TOC right
      let current_h2 = find_closest_trigger_element(h2_map, scroll_top, scroll_bottom);

      active_h2 = swap_classes(active_h2, current_h2, "display_block");
      active_left_h2 = swap_classes(active_left_h2, current_h2, 'xl:bg-selected', 'left_target')

    // H3 in TOC right
      let current_h3 = find_closest_trigger_element(h3_map, scroll_top, scroll_bottom);

      active_h3 = swap_classes(active_h3, current_h3, "documentation-right-toc-h3-active");

        // console.log("h4   ")
      if (current_h3 != null) {
        let local_h4_map = h4_map.get(current_h3.element);

        // many H3 don't have H4!
        let current_h4 = find_closest_trigger_element(local_h4_map, scroll_top, scroll_bottom);

        active_h4 = swap_classes(active_h4, current_h4, "documentation-right-toc-h4-active");
      }
    }

    // Note: this might return null for empty lists.
    function find_closest_trigger_element(trigger_element_map, scroll_top, scroll_bottom) {
      for (let i = 0; i <= trigger_element_map.length - 1; i++) {
        let hx = trigger_element_map[i];
        let hx_top = hx.element.offset().top; //  DISCUSS: this could be cached in the maps and recomputed when screen changes.

        if (hx_top > scroll_top) {
          if (hx_top < scroll_bottom) {
            // trigger_element is within viewport.
            return hx;
          } else {
            // trigger_element is not yet in viewport.
            return trigger_element_map[i-1];
          }
        } else if(i == trigger_element_map.length - 1) {
          // obviously, we're beyond the last h.
          return hx; // return the last element.
        }
      }
    }

    function swap_classes(active_hx, current_hx, removed_class, target='target') {
      if (active_hx === current_hx) {
        return active_hx
      }

      if (active_hx != null) {
        active_hx[target].removeClass(removed_class);
      }

      // many H3 don't have H4!
      if (current_hx != null) { // this is the case when there are no H4s under a H3, for example.
        // console.log(`add ${removed_class}    +++++++++ ${current_hx[target].attr("href")}`)
        current_hx[target].addClass(removed_class);
      }

      return current_hx;
    }

    // console.log(jquery("#documentation"))
    jquery(window).on("scroll", h2_listener);
    h2_listener(null); // init wyof-scrollspy

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
