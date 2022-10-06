# elm-ansi

An Elm (plus JS) package for writing apps for your terminal.

## Getting Started

- Make sure you have both Nix and direnv installed
- Clone this repo, or use the GitHub `Use this template` button
- Inside your cloned repo, run `direnv allow`
- Run `npm install`

## Modules

The `Ansi` modules are used for the core ANSI related code, .e.g setting font colors and moving the cursor.

The `Terminal` modules are an abstraction above `Ansi`. E.g. with the base `Ansi` tools if you wanted to take the string "Hello, world!" and change the color of "Hello" to be green and make "world" bold, then you'd write

```elm
import Ansi.Color exposing (Location(..))
import Ansi.Font

phrase =
    Ansi.Font.color Ansi.Color.green ++ "Hello" ++ Ansi.Color.reset Foreground
        ++ ", "
        ++ Ansi.Font.bold ++ "world" ++ Ansi.Font.resetBoldFaint
        ++ "!
```

however with `Terminal` you can shorten this to

```elm
import Ansi.Color
import Terminal

phrase =
    Terminal.color Ansi.Color.green "Hello" ++ ", " ++ Terminal.bold "world" ++ "!
```

The `Ink` module is an abstraction above `Terminal`. With `Terminal` you still have to handle layout yourself. `Ink` aims to handle layout for you. E.g.

Given

```elm
phrase =
    """
Hello, World!

Welcome to the terminal!
"""
```

with `Terminal if we want to have the above layout, but also make "World" green and "terminal" italic then we'd do

```elm
import Ansi.Color
import Terminal

phrase =
    ["Hello, " ++ Terminal.color Ansi.Color.green "World" ++ "!"
    , ""
    , "Welcome to the " ++ Terminal.italic "terminal" ++ "!"
    ]
    |> String.join "\n"
```

and with `Ink` we can do

```elm
import Ansi.Color
import Ink
phrase =
    Ink.column [ Ink.spacing 1 ]
        [ Ink.row []
            [ Ink.text [] "Hello,  "
            , Ink.text [ Ink.Font.color Ansi.Color.green ] "World"
            , Ink.text [] "!"
            ]
        , Ink.row []
            [ Ink.text [] "Welcome to the "
            , Ink.text [ Ink.Font.italic ] "terminal"
            , Ink.text [] "!"
            ]
        ]
        |> Ink.view
```

Initially this might look like more work, but without the layout helpers you'll end up having to manually calculate a lot of spacings.

## Run Examples

To compile an example, run `npm run:<example name>`, e.g.

- `npm run example:ansi`
- `npm run example:terminal`
- `npm run example:ink`

To run a compiled example, run `node example-<example name>.js`, e.g.

- Run `node dist/example-ansi.js` to view the Ansi demo
- Run `node dist/example-terminal.js` to view the Terminal demo
- Run `node dist/example-ink.js` to view the Ink demo

## Thoughts

This should be split into 3 completely packages

- `elm-ansi`: a package for working with ansi and basic String related things. E.g. width of a String in terminal columns. Kind of like `elm/virtual-dom` meets `elm/code`.
- `elm-terminal`: a higher level package for working with the terminal. E.g. `Terminal.bold "some words"` instead of `Ansi.bold ++ "some words ++ Ansi.unbold`. Think of this like `elm/html`.
- `elm-ink`: a fairly high level package for building cli apps. E.g. `Ink.column [ Ink.bold, Ink.color Ink.red ] [ Ink.text "some text" ]`. Think of this like `mdgriffith/elm-ui`.
