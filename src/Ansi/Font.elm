module Ansi.Font exposing
    ( color
    , invert
    , resetInvert
    , bold
    , faint
    , resetBoldFaint
    , italic
    , resetItalic
    , underline
    , resetUnderline
    , strikeThrough
    , resetStrikeThrough
    , resetAll
    , hide
    , show
    , blink
    , resetBlink
    )

{-| When styling your terminal there are 2 sets of commands, those that add the style and those that remove it. This does make this a little more difficult to use as you have to remember to reset each style when you no longer want it applied. It does however let you mix and match styles however you want.


## Color

@docs color
@docs invert
@docs resetInvert


## Style

@docs bold
@docs faint
@docs resetBoldFaint

@docs italic
@docs resetItalic

@docs underline
@docs resetUnderline

@docs strikeThrough
@docs resetStrikeThrough

@docs resetAll


## Visibility

@docs hide
@docs show


## Unsupported

These have some limited support but it varies greatly by terminal

@docs blink
@docs resetBlink

-}

import Ansi.Color exposing (Color, Location(..))
import Ansi.Internal


{-| -}
color : Color -> String
color c =
    Ansi.Internal.toAnsiCommand (Ansi.Color.encode Foreground c)


{-| -}
resetAll : String
resetAll =
    Ansi.Internal.toAnsiCommand "0m"


{-| -}
bold : String
bold =
    Ansi.Internal.toAnsiCommand "1m"


{-| -}
faint : String
faint =
    Ansi.Internal.toAnsiCommand "2m"


{-| -}
resetBoldFaint : String
resetBoldFaint =
    Ansi.Internal.toAnsiCommand "22m"


{-| -}
italic : String
italic =
    Ansi.Internal.toAnsiCommand "3m"


{-| -}
resetItalic : String
resetItalic =
    Ansi.Internal.toAnsiCommand "23m"


{-| -}
underline : String
underline =
    Ansi.Internal.toAnsiCommand "4m"


{-| -}
resetUnderline : String
resetUnderline =
    Ansi.Internal.toAnsiCommand "24m"


{-| -}
blink : String
blink =
    Ansi.Internal.toAnsiCommand "5m"


{-| -}
resetBlink : String
resetBlink =
    Ansi.Internal.toAnsiCommand "25m"


{-| -}
invert : String
invert =
    Ansi.Internal.toAnsiCommand "7m"


{-| -}
resetInvert : String
resetInvert =
    Ansi.Internal.toAnsiCommand "27m"


{-| -}
hide : String
hide =
    Ansi.Internal.toAnsiCommand "8m"


{-| -}
show : String
show =
    Ansi.Internal.toAnsiCommand "28m"


{-| -}
strikeThrough : String
strikeThrough =
    Ansi.Internal.toAnsiCommand "9m"


{-| -}
resetStrikeThrough : String
resetStrikeThrough =
    Ansi.Internal.toAnsiCommand "29m"
