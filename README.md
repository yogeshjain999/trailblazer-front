# README

## Writing

To write docs, use `guard` and `rails` as a server.

```
bundle exec guard
rails s
```


## Extending

To work on CSS and new features, you need to run the "development mode" where Tailwind constantly recompiles its CSS file, etc.

Run with

```
$ foreman start -f Procfile.dev
```

## Publishing

```
$ rails site:deploy
```

Will update `dist/` and push everything to `main`.


## Tailwind CSS principles to follow

- Use Tailwind CSS utility classes as much as possible.
- Avoid using custom CSS classes as much as possible in `.css` files.
- Avoid usage of `@apply` directive. More details [here](https://tailwindcss.com/docs/reusing-styles#avoiding-premature-abstraction)
- Check if can extract out repetative HTML into separate components/methods instead of using `@apply` directive.

## Javascript

```ruby
bin/importmap pin jquery --download
```

will copy the library to `vendor/javascript/jquery.js`


## Troubleshooting

1. Changes not picked up? Run `rails assets:clobber`


## Publishing (before Netlify)

GH pages: ONLY docs/ is published under mia.trb.to


RAILS_ENV=production rails assets:precompile
RAILS_ENV=production be guard
rm -r docs/*
cp -R public/2.1/ docs/ && cp -R public/assets docs/
touch docs/index.html


## Notes

We could remove public/2.1 and public/assets from git control since it's copied to dist/.
