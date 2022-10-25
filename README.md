# elm-ansi

A low-level package for text formatting and layout for your terminal.

## Who is this for?

This package is meant as a building block for more expressive packages. You can think of it like `elm/virtual-dom` for `elm/html` and `mdgriffith/elm-ui`.

## Examples

```elm
import Ansi.Font

phrase : String
phrase =
    "Hello, "
        ++ Ansi.Font.bold
        ++ "world"
        ++ Ansi.Font.resetBoldFaint
        ++ "!
```

if printed to a terminal would give you

> Hello, **World**!

This can be made slightly easier by using the `Terminal` functions

```elm
import Terminal

phrase : String
phrase =
    "Hello, "
        ++ Terminal.bold "world"
        ++ "!
```

which if printed to a terminal would also give you

> Hello, **World**!

## Run Examples

To compile an example, run `npm run:<example name>`, e.g.

- `npm run example:ansi`
- `npm run example:terminal`

To run a compiled example, run `node example-<example name>.js`, e.g.

- Run `node dist/example-ansi.js` to view the Ansi demo
- Run `node dist/example-terminal.js` to view the Terminal demo

---

## Contributing

- Make sure you have both `Nix` and `direnv` installed
- Clone this repo
- Inside your cloned repo, run `direnv allow`
