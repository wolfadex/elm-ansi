module Ansi exposing
    ( clearScreen
    , eraseScreen
    , eraseUp
    , eraseDown
    , eraseLine
    , eraseLineAfter
    , eraseLineBefore
    , saveScreen
    , restoreScreen
    , scrollUpBy
    , scrollDownBy
    , setTitle
    , link
    , beep
    )

{-|


## Erasing

@docs clearScreen
@docs eraseScreen
@docs eraseUp
@docs eraseDown
@docs eraseLine
@docs eraseLineAfter
@docs eraseLineBefore


## State

@docs saveScreen
@docs restoreScreen
@docs scrollUpBy
@docs scrollDownBy


## Other

@docs setTitle
@docs link
@docs beep

-}

-- Reference for many of the codes <https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797>

import Ansi.Internal


{-| Clears the entire screen
-}
clearScreen : String
clearScreen =
    "\u{001B}c"


{-| Erases all of the screen
-}
eraseScreen : String
eraseScreen =
    Ansi.Internal.toCommand "2J"


{-| Erases the screen from the cursor up
-}
eraseUp : String
eraseUp =
    Ansi.Internal.toCommand "1J"


{-| Erases the screen from the cursor down
-}
eraseDown : String
eraseDown =
    Ansi.Internal.toCommand "J"


{-| Erases the line the cursor is on
-}
eraseLine : String
eraseLine =
    Ansi.Internal.toCommand "2K"


{-| Erases the line from the cursor to the end
-}
eraseLineAfter : String
eraseLineAfter =
    Ansi.Internal.toCommand "K"


{-| Erases the line from the beginning through the cursor
-}
eraseLineBefore : String
eraseLineBefore =
    Ansi.Internal.toCommand "1K"


{-| Scrolls the terminal up
-}
scrollUpBy : Int -> String
scrollUpBy amount =
    Ansi.Internal.toCommand (String.fromInt amount ++ "L")


{-| Scrolls the terminal down
-}
scrollDownBy : Int -> String
scrollDownBy amount =
    Ansi.Internal.toCommand (String.fromInt amount ++ "M")


{-| -}
saveScreen : String
saveScreen =
    Ansi.Internal.toCommand "?47h"


{-| -}
restoreScreen : String
restoreScreen =
    Ansi.Internal.toCommand "?47l"


{-| Sets the title of the terminal
-}
setTitle : String -> String
setTitle title =
    Ansi.Internal.bel ++ "0" ++ Ansi.Internal.separator ++ title ++ Ansi.Internal.bel


{-| Similar formatting to Markdown URLs. Not all terminals support this format.
-}
link : { text : String, url : String } -> String
link options =
    String.concat
        [ Ansi.Internal.osc
        , "8"
        , Ansi.Internal.separator
        , Ansi.Internal.separator
        , options.url
        , Ansi.Internal.bel
        , options.text
        , Ansi.Internal.osc
        , "8"
        , Ansi.Internal.separator
        , Ansi.Internal.separator
        , Ansi.Internal.bel
        ]


{-| Emits an audio beep
-}
beep : String
beep =
    Ansi.Internal.bel
