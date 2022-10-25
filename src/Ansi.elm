module Ansi exposing
    ( clearScreen
    , clearUp
    , clearDown
    , clearLine
    , clearLineAfter
    , clearLineBefore
    , saveScreen
    , restoreScreen
    , scrollUpBy
    , scrollDownBy
    , setTitle
    )

{-|


## Erasing

@docs clearScreen
@docs clearUp
@docs clearDown
@docs clearLine
@docs clearLineAfter
@docs clearLineBefore


## State

@docs saveScreen
@docs restoreScreen
@docs scrollUpBy
@docs scrollDownBy


## Other

@docs setTitle

-}

-- Reference for many of the codes <https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797>

import Ansi.Internal


{-| Clears all of the screen
-}
clearScreen : String
clearScreen =
    Ansi.Internal.toCommand "2J"


{-| Clears the screen from the cursor up
-}
clearUp : String
clearUp =
    Ansi.Internal.toCommand "1J"


{-| Clears the screen from the cursor down
-}
clearDown : String
clearDown =
    Ansi.Internal.toCommand "J"


{-| Clears the line the cursor is on
-}
clearLine : String
clearLine =
    Ansi.Internal.toCommand "2K"


{-| Clears the line from the cursor to the end
-}
clearLineAfter : String
clearLineAfter =
    Ansi.Internal.toCommand "K"


{-| Clears the line from the beginning through the cursor
-}
clearLineBefore : String
clearLineBefore =
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


{-| 
-}
saveScreen : String
saveScreen =
    Ansi.Internal.toCommand "?47h"


{-| 
-}
restoreScreen : String
restoreScreen =
    Ansi.Internal.toCommand "?47l"


{-| Sets the title of the terminal
-}
setTitle : String -> String
setTitle title =
    "\u{001B}]0;" ++ title ++ "\u{0007}"
