# README

Run with

```
$ foreman start -f Procfile.dev
```

# Tailwind CSS principles to follow

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

## Publishing

GH pages: ONLY docs/ is published under mia.trb.to


RAILS_ENV=production rails assets:precompile
RAILS_ENV=production be guard
cp -R public/2.1 docs/ && cp -R public/assets docs/
touch docs/index.html
