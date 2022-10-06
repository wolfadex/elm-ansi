module Ansi.Font exposing (..)

import Ansi.Color exposing (Color, Location(..))
import Ansi.Internal


color : Color -> String
color c =
    Ansi.Internal.toAnsiCommand (Ansi.Color.encode Foreground c)


resetAll : String
resetAll =
    Ansi.Internal.toAnsiCommand "0m"


bold : String
bold =
    Ansi.Internal.toAnsiCommand "1m"


faint : String
faint =
    Ansi.Internal.toAnsiCommand "2m"


resetBoldFaint : String
resetBoldFaint =
    Ansi.Internal.toAnsiCommand "22m"


italic : String
italic =
    Ansi.Internal.toAnsiCommand "3m"


resetItalic : String
resetItalic =
    Ansi.Internal.toAnsiCommand "23m"


underline : String
underline =
    Ansi.Internal.toAnsiCommand "4m"


resetUnderline : String
resetUnderline =
    Ansi.Internal.toAnsiCommand "24m"


blink : String
blink =
    Ansi.Internal.toAnsiCommand "5m"


resetBlink : String
resetBlink =
    Ansi.Internal.toAnsiCommand "25m"


invert : String
invert =
    Ansi.Internal.toAnsiCommand "7m"


resetInvert : String
resetInvert =
    Ansi.Internal.toAnsiCommand "27m"


hide : String
hide =
    Ansi.Internal.toAnsiCommand "8m"


show : String
show =
    Ansi.Internal.toAnsiCommand "28m"


strikeThrough : String
strikeThrough =
    Ansi.Internal.toAnsiCommand "9m"


resetStrikeThrough : String
resetStrikeThrough =
    Ansi.Internal.toAnsiCommand "29m"
