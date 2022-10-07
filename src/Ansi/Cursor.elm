module Ansi.Cursor exposing
    ( moveUpBy
    , moveDownBy
    , moveForwardBy
    , moveBackwardBy
    , moveForwardLines
    , moveBackwardLines
    , moveTo
    , moveToColumn
    , savePosition
    , restorePosition
    , hide
    , show
    )

{-|


## Movement

@docs moveUpBy
@docs moveDownBy
@docs moveForwardBy
@docs moveBackwardBy
@docs moveForwardLines
@docs moveBackwardLines
@docs moveTo
@docs moveToColumn
@docs savePosition
@docs restorePosition


## Visibility

@docs hide
@docs show

-}

import Ansi.Internal


{-| Move the cursor up N lines
-}
moveUpBy : Int -> String
moveUpBy amount =
    Ansi.Internal.toAnsiCommand (String.fromInt amount ++ "A")


{-| Move the cursor down N lines
-}
moveDownBy : Int -> String
moveDownBy amount =
    Ansi.Internal.toAnsiCommand (String.fromInt amount ++ "B")


{-| Move the cursor forward N columns. In an LTR language this is to the right and in an RTL language it's to the left.
-}
moveForwardBy : Int -> String
moveForwardBy amount =
    Ansi.Internal.toAnsiCommand (String.fromInt amount ++ "C")


{-| Move the cursor forward N columns. In an LTR language this is to the left and in an RTL language it's to the right.
-}
moveBackwardBy : Int -> String
moveBackwardBy amount =
    Ansi.Internal.toAnsiCommand (String.fromInt amount ++ "D")


{-| -}
moveForwardLines : Int -> String
moveForwardLines amount =
    Ansi.Internal.toAnsiCommand (String.fromInt amount ++ "E")


{-| -}
moveBackwardLines : Int -> String
moveBackwardLines amount =
    Ansi.Internal.toAnsiCommand (String.fromInt amount ++ "F")


{-| Move the cursor to the specified column
-}
moveToColumn : Int -> String
moveToColumn amount =
    Ansi.Internal.toAnsiCommand (String.fromInt amount ++ "G")


{-| Move the cursor to the specified row and column
-}
moveTo : { row : Int, column : Int } -> String
moveTo to =
    Ansi.Internal.toAnsiCommand (String.fromInt to.row ++ ";" ++ String.fromInt to.column ++ "H")


{-| Save the cursor's position
-}
savePosition : String
savePosition =
    Ansi.Internal.toAnsiCommand "s"


{-| Move the cursor back to the last saved position
-}
restorePosition : String
restorePosition =
    Ansi.Internal.toAnsiCommand "u"


{-| Hide the cursor
-}
hide : String
hide =
    Ansi.Internal.toAnsiCommand "??25l"


{-| Show the cursor if it was hidden
-}
show : String
show =
    Ansi.Internal.toAnsiCommand "?25h"
