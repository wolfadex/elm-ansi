module Terminal.Text exposing (..)

import Ansi.Color exposing (Color, Location(..))
import Ansi.Font
import Ansi.Internal
import Browser exposing (UrlRequest(..))
import Terminal.Internal exposing (Attribute(..))


color : Color -> Attribute
color c =
    Style
        (Ansi.Color.encode Foreground c |> Ansi.Internal.toAnsiCommand)
        (Ansi.Color.reset Foreground)


bold : Attribute
bold =
    Style Ansi.Font.bold Ansi.Font.resetBoldFaint


faint : Attribute
faint =
    Style Ansi.Font.faint Ansi.Font.resetBoldFaint


italic : Attribute
italic =
    Style Ansi.Font.italic Ansi.Font.resetBoldFaint
