# elm-ansi

A low-level package for text formatting and layout for your terminal.

## Who is this for?

This package is meant as a building block for more expressive packages. You can think of it like [elm/virtual-dom](https://package.elm-lang.org/packages/elm/virtual-dom/latest/) for [elm/html](https://package.elm-lang.org/packages/elm/html/latest/) and [mdgriffith/elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/).

## Basic Example

```elm
port module Main exposing (..)

import Ansi
import Ansi.Cursor
import Ansi.Font
import Platform


init _ =
    ( ()
    , [ Ansi.Font.resetAll
      , Ansi.clearScreen
      , Ansi.Cursor.moveTo { row = 1, column = 1 }
      , "🌈 Hello, " ++ Ansi.Font.bold "world" ++ "!"
      ]
        |> String.concat
        |> stdout
    )


stdout : String -> Cmd msg


main =
    Platform.worker
        { init = init
        , subscriptions = \_ -> Sub.none
        , update = \_ model -> ( model, Cmd.none )
        }
```

if printed to a terminal would give you

> 🌈 Hello, **World**!

Walking through this step-by-step:

1. With `Ansi.Font.resetAll` we reset all of the font settings, removing and styles that might be left over.
1. Then we use `Ansi.clearScreen` to, clear the screen.
1. At this point our cursor is still wherever we left it so we move it to the top left most corner with `Ansi.Cursor.moveTo { row = 1, column = 1 }`.
1. Now we can finally start drawing our content! We want to write out `"🌈 Hello, World!"`, but we also want to make `World` bold.
1. Finally we join all of this together and send it out through a port!

For more complete example including handling input, checkout the examples directory [in the repo](https://github.com/wolfadex/elm-ansi).

---

## Contributing

- Install [Nix](https://nixos.org/download.html) and [direnv](https://direnv.net/)
- Clone this repo
- Inside your cloned repo, run `direnv allow`

or

- Install [Node.js](https://nodejs.org/en/) and [Em](https://elm-lang.org/)
- Clone this repo
- Inside the cloned repo, run `npm install`
