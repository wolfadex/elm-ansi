module Terminal exposing (..)

import Ansi
import Ansi.Color exposing (Color, Location(..))
import Ansi.Font


bold : String -> String
bold str =
    Ansi.Font.bold ++ str ++ Ansi.Font.resetBoldFaint


faint : String -> String
faint str =
    Ansi.Font.faint ++ str ++ Ansi.Font.resetBoldFaint


italic : String -> String
italic str =
    Ansi.Font.italic ++ str ++ Ansi.Font.resetItalic


underline : String -> String
underline str =
    Ansi.Font.underline ++ str ++ Ansi.Font.resetUnderline


invert : String -> String
invert str =
    Ansi.Font.invert ++ str ++ Ansi.Font.resetInvert


strikeThrough : String -> String
strikeThrough str =
    Ansi.Font.strikeThrough ++ str ++ Ansi.Font.resetStrikeThrough


{-| Resets all font settings on the passed in value
-}
resetFont : String -> String
resetFont str =
    Ansi.Font.resetAll ++ str


color : Color -> String -> String
color c str =
    Ansi.Font.color c ++ str ++ Ansi.Color.reset Foreground


backgroundColor : Color -> String -> String
backgroundColor c str =
    Ansi.backgroundColor c ++ str ++ Ansi.Color.reset Background


{-| Not supported by some terminals
-}
blink : String -> String
blink str =
    Ansi.Font.blink ++ str ++ Ansi.Font.resetBlink
