import ScrollMagic from 'scrollmagic';

export function rightTOCScrollSpy() {
  var controller = new ScrollMagic.Controller();
  var leftSidebarLinks = document.querySelectorAll('#sideNav a[href^="#"]');

  leftSidebarLinks.forEach(function (anchor, index) {
    var sectionAnchor = anchor.getAttribute('href').split('#')[1];

    new ScrollMagic.Scene({
      triggerElement: `#${sectionAnchor}`,
      triggerHook: index === 0 ? 'onEnter' : 'onLeave',
      offset: -100
    })
      .setClassToggle(`#right-toc-${sectionAnchor}`, 'xl:block')
      .addTo(controller);
  });
}

export function tocLinkScrollSpy(tocId, headerSelector, activeClass) {
  var controller = new ScrollMagic.Controller();
  var headers = document.querySelectorAll(headerSelector);
  var scenes = [];

  function getLinkHref(headerId) {
    return `${tocId} a[href="${headerId}"]`;
  }

  function togglePreviousScene(event, index) {
    if (scenes[index - 1]) {
      var headerId = `#${headers[index - 1].getAttribute('id')}`;

      if (event.scrollDirection === 'FORWARD') {
        document.querySelector(getLinkHref(headerId)).classList.remove(activeClass);
      } else {
        document.querySelector(getLinkHref(headerId)).classList.add(activeClass);
      }
    }
  }

  headers.forEach(function (header, index) {
    var headerId = `#${header.getAttribute('id')}`;

    var scene = new ScrollMagic.Scene({
      triggerElement: headerId,
      triggerHook: '0.2'
    })
      .setClassToggle(getLinkHref(headerId), activeClass)
      .addTo(controller)
      .on('progress', function (event) {
        togglePreviousScene(event, index);
      });

    scenes.push(scene);
  });
}

export default {
  init() {
    rightTOCScrollSpy();
    tocLinkScrollSpy('#sideNav', '#documentation h2', 'xl:bg-selected');
    tocLinkScrollSpy('#right-toc', '#documentation h3, #documentation h4', 'xl:bg-bg-orange');
  }
};
