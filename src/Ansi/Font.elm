module Ansi.Font exposing
    ( bold
    , faint
    , italic
    , underline
    , strikeThrough
    , startBold
    , startFaint
    , endBoldFaint
    , startItalic
    , endItalic
    , startUnderline
    , endUnderline
    , startStrikeThrough
    , endStrikeThrough
    , resetAll
    , hide
    , show
    , startBlink
    , endBlink
    )

{-| When styling your terminal there are 2 sets of commands, those that add the style and those that remove it. This does make this a little more difficult to use as you have to remember to reset each style when you no longer want it applied. It does however let you mix and match styles however you want. For example

    Ansi.Font.startItalic ++ "Hello, " ++ Ansi.Font.startBold ++ "World" ++ Ansi.Font.endBold ++ "!" ++ Ansi.Font.endItalic

produces "_Hello, **World**!_". However most people don't need this fine grained of control. If you want simpler functions I recommend

    Ansi.Font.italic ("Hello, " ++ Ansi.Font.bold "World" ++ "!")

which produces the same result.


## Shorthand Styling

@docs bold
@docs faint
@docs italic
@docs underline
@docs strikeThrough


## Explicit Styling

@docs startBold
@docs startFaint
@docs endBoldFaint

@docs startItalic
@docs endItalic

@docs startUnderline
@docs endUnderline

@docs startStrikeThrough
@docs endStrikeThrough

@docs resetAll


## Visibility

@docs hide
@docs show


## Limited Support

These have some limited support but it varies greatly by terminal

@docs startBlink
@docs endBlink

-}

import Ansi.Internal


{-| -}
resetAll : String
resetAll =
    Ansi.Internal.toCommand "0m"


{-| -}
startBold : String
startBold =
    Ansi.Internal.toCommand "1m"


{-| The opposite of bold
-}
startFaint : String
startFaint =
    Ansi.Internal.toCommand "2m"


{-| -}
endBoldFaint : String
endBoldFaint =
    Ansi.Internal.toCommand "22m"


{-| -}
startItalic : String
startItalic =
    Ansi.Internal.toCommand "3m"


{-| -}
endItalic : String
endItalic =
    Ansi.Internal.toCommand "23m"


{-| -}
startUnderline : String
startUnderline =
    Ansi.Internal.toCommand "4m"


{-| -}
endUnderline : String
endUnderline =
    Ansi.Internal.toCommand "24m"


{-| -}
startBlink : String
startBlink =
    Ansi.Internal.toCommand "5m"


{-| -}
endBlink : String
endBlink =
    Ansi.Internal.toCommand "25m"


{-| -}
hide : String
hide =
    Ansi.Internal.toCommand "8m"


{-| -}
show : String
show =
    Ansi.Internal.toCommand "28m"


{-| -}
startStrikeThrough : String
startStrikeThrough =
    Ansi.Internal.toCommand "9m"


{-| -}
endStrikeThrough : String
endStrikeThrough =
    Ansi.Internal.toCommand "29m"



---- CONVENIENCE FUNCTIONS ----


{-| -}
bold : String -> String
bold str =
    startBold ++ str ++ endBoldFaint


{-| The opposite of bold
-}
faint : String -> String
faint str =
    startFaint ++ str ++ endBoldFaint


{-| -}
italic : String -> String
italic str =
    startItalic ++ str ++ endItalic


{-| -}
underline : String -> String
underline str =
    startUnderline ++ str ++ endUnderline


{-| -}
strikeThrough : String -> String
strikeThrough str =
    startStrikeThrough ++ str ++ endStrikeThrough


{-| Not supported by some terminals
-}
blink : String -> String
blink str =
    startBlink ++ str ++ endBlink
