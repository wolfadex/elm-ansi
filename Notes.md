# Known issues

- Yoga nodes don't account for border width when they have a specific width. Need to figure out how to best add extra border width when a hardcoded width is set on them

# Todo

- [ ] set element width
- [ ] set element height
- [ ] support lower bit colors
- [ ] add an "animated" element of some kind (see notes below)
- [ ] inputs & focus control
  - [ ] buttons
  - [ ] single line text elements
- [ ] setup text wrapping (npm dep already installed)
- [ ] setup text truncating (npm dep already installed)

## Animated Element

An element with an interval and frames that moves to the next frame every interval. Possible API

```elm
{-| Steps to the next frame every `step`, where `step` is the number of milliseconds between frames. A "frame" is a String.
-}
Ink.animated :
    List (Style msg)
    -> { step : Float
       , frames : List String
       }
    -> Ink msg
```

example usage

```elm

view model =
    Ink.row []
        [ Ink.text [] "Animated"
        , Ink.animated
            { step = 250
            , frames = [ ">", "->", "-->" ]
            }
        ]
```

and running this for 2 seconds would display

| Miliseconds | Displayed     |
| ----------- | ------------- |
| 0           | `Animated>`   |
| 250         | `Animated->`  |
| 500         | `Animated-->` |
| 750         | `Animated>`   |
| 1000        | `Animated->`  |
| 1250        | `Animated-->` |
| 1500        | `Animated>`   |
| 1750        | `Animated->`  |
| 2000        | `Animated-->` |

# Ideas

- A "canvas" like element, but you can kinda already do this with a `text` element
