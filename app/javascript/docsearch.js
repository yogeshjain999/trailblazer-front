import 'docsearch-3.5.2';

// TODO: remove, currently unused function.
function my_transformItems(items) {
    return items.map((item) => {
      return {
        ...item,
        hierarchy: {...item.hierarchy, lvl1: "yo yo yo yo"},
      }
    })
  }

docsearch({
  container: '#docsearch',
  appId: 'LEN50BR1UK',
  indexName: 'trailblazer-website-24',
  apiKey: 'b1f311e280db1c40850ee82e08eb3449',

  // transformItems: my_transformItems,
});
