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
    Ansi.Internal.toCommand (Ansi.Color.encode Foreground c)


{-| -}
resetAll : String
resetAll =
    Ansi.Internal.toCommand "0m"


{-| -}
bold : String
bold =
    Ansi.Internal.toCommand "1m"


{-| -}
faint : String
faint =
    Ansi.Internal.toCommand "2m"


{-| -}
resetBoldFaint : String
resetBoldFaint =
    Ansi.Internal.toCommand "22m"


{-| -}
italic : String
italic =
    Ansi.Internal.toCommand "3m"


{-| -}
resetItalic : String
resetItalic =
    Ansi.Internal.toCommand "23m"


{-| -}
underline : String
underline =
    Ansi.Internal.toCommand "4m"


{-| -}
resetUnderline : String
resetUnderline =
    Ansi.Internal.toCommand "24m"


{-| -}
blink : String
blink =
    Ansi.Internal.toCommand "5m"


{-| -}
resetBlink : String
resetBlink =
    Ansi.Internal.toCommand "25m"


{-| -}
invert : String
invert =
    Ansi.Internal.toCommand "7m"


{-| -}
resetInvert : String
resetInvert =
    Ansi.Internal.toCommand "27m"


{-| -}
hide : String
hide =
    Ansi.Internal.toCommand "8m"


{-| -}
show : String
show =
    Ansi.Internal.toCommand "28m"


{-| -}
strikeThrough : String
strikeThrough =
    Ansi.Internal.toCommand "9m"


{-| -}
resetStrikeThrough : String
resetStrikeThrough =
    Ansi.Internal.toCommand "29m"
