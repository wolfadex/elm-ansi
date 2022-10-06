module Ansi.Cursor exposing (..)

import Ansi.Internal


moveUpBy : Int -> String
moveUpBy amount =
    Ansi.Internal.toAnsiCommand (String.fromInt amount ++ "A")


moveDownBy : Int -> String
moveDownBy amount =
    Ansi.Internal.toAnsiCommand (String.fromInt amount ++ "B")


moveForwardBy : Int -> String
moveForwardBy amount =
    Ansi.Internal.toAnsiCommand (String.fromInt amount ++ "C")


moveBackwardBy : Int -> String
moveBackwardBy amount =
    Ansi.Internal.toAnsiCommand (String.fromInt amount ++ "D")


moveForwardLines : Int -> String
moveForwardLines amount =
    Ansi.Internal.toAnsiCommand (String.fromInt amount ++ "E")


moveBackwardLines : Int -> String
moveBackwardLines amount =
    Ansi.Internal.toAnsiCommand (String.fromInt amount ++ "F")


moveToColumn : Int -> String
moveToColumn amount =
    Ansi.Internal.toAnsiCommand (String.fromInt amount ++ "G")


moveTo : { row : Int, column : Int } -> String
moveTo to =
    Ansi.Internal.toAnsiCommand (String.fromInt to.row ++ ";" ++ String.fromInt to.column ++ "H")


savePosition : String
savePosition =
    Ansi.Internal.toAnsiCommand "s"


restorePosition : String
restorePosition =
    Ansi.Internal.toAnsiCommand "u"


show : String
show =
    Ansi.Internal.toAnsiCommand "?25h"


hide : String
hide =
    Ansi.Internal.toAnsiCommand "??25l"
