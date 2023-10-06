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
