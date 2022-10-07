module Ink.Style exposing (..)

{-| Attributes that modify the appearance of your content
-}

import Ansi.Color exposing (Color, Location(..))
import Ansi.Font
import Ansi.Internal
import Browser exposing (UrlRequest(..))
import Ink.Internal exposing (Attribute(..))


{-| Set the color of your text. See `Ansi.Color` for colors.
-}
color : Color -> Attribute
color c =
    Style
        (Ansi.Color.encode Foreground c |> Ansi.Internal.toAnsiCommand)
        (Ansi.Color.reset Foreground)


{-| Makes the text more bold.
-}
bold : Attribute
bold =
    Style Ansi.Font.bold Ansi.Font.resetBoldFaint


{-| Makes the text less bold.
-}
faint : Attribute
faint =
    Style Ansi.Font.faint Ansi.Font.resetBoldFaint


{-| Makes the text italic.
-}
italic : Attribute
italic =
    Style Ansi.Font.italic Ansi.Font.resetBoldFaint
