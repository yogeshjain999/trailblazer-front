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

    // wyof-scrollspy

    // compile time!
    jquery("#documentation h2").each(function(index, trigger_el) {
      var trigger_element = jquery(trigger_el);
      var right_toc_id    = `#right-toc-${trigger_element.attr('id')}`; // toc div that belongs to this trigger_element/h2.

      h2_map.push(
        {
          offset_top:   trigger_el.offsetTop,
          element:      trigger_element,
          target:  jquery(right_toc_id), // for H2 -> h3/h4 right tocs.
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
            offset_top:   trigger_el.offsetTop,
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
            offset_top:   trigger_el.offsetTop,
            element:      trigger_element,
            target:       h_in_toc,
          }
        )
      }
    });

    console.log(h4_map);


    let current_h2 = h2_map[0]; // FIXME: how to initialize that?

    // let last_scrolltop = 0; // FIXME: can we avoid those globals?

    let h2_listener = function (event) {
      var _window = jquery(window);
      let scroll_top = _window.scrollTop(); // where are we at the top of viewport?
      let scroll_bottom = _window.innerHeight() + scroll_top;

      let in_viewport = null

    // H2 / TOC right
      let current_h2 = find_closest_trigger_element(h2_map, scroll_top, scroll_bottom);

      jquery(h2_map).each(function(i, h2) {
        h2['target'].removeClass("display_block");
      });

      jquery(current_h2['target']).addClass("display_block");


    // H3 in TOC right
      let current_h3 = mark_hx(h3_map, scroll_top, scroll_bottom, "documentation-right-toc-h3-active");

      // // H4 in TOC right
      //   // only "offer" the H3's h4 list as closest elements.
      if (current_h3 != null) {
        let local_h4_map = h4_map.get(current_h3.element);
        console.log("find closest for ")
      //   console.log(current_h3.element)
        console.log(local_h4_map)


      }
    }

    function find_closest_trigger_element(trigger_element_map, scroll_top, scroll_bottom) {
      for (let i = 0; i < trigger_element_map.length - 1; i++) {
        let hx = trigger_element_map[i];
        let hx_top = hx['offset_top'];

        // console.log(`${scroll_top} ${hx_top}`)
        if (hx_top > scroll_top) {
          if (hx_top < scroll_bottom) {
            // trigger_element is within viewport.
            return hx;
          } else {
            // trigger_element is not yet in viewport.
            return trigger_element_map[i-1];
          }
        }
      }
    }

    function remove_class_for(hx_map, removed_class) {
      jquery(hx_map).each(function(i, trigger_el) {
        trigger_el.target.removeClass(removed_class);
      });
    }

    function mark_hx(hx_map, scroll_top, scroll_bottom, active_class) {
      let current_hx = find_closest_trigger_element(hx_map, scroll_top, scroll_bottom);

      // Only mark h3 if it is in viewport. E.g. H2/Overview has a long intro and we shouldn't mark any H3 just yet
      if (current_hx != null) {
        remove_class_for(hx_map, active_class)

        jquery(current_hx['target']).addClass(active_class);
      } else {
        // when we are after a H2 in the intro, there's no H3, yet.
        remove_class_for(hx_map, active_class)
      }

      return current_hx;
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
