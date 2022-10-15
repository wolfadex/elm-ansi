module Ink.Style exposing
    ( color
    , backgroundColor
    , bold
    , faint
    , italic
    )

{-| Attributes that modify the appearance of your content


## Color

@docs color
@docs backgroundColor


## Format

@docs bold
@docs faint
@docs italic

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
        (Ansi.Color.encode Foreground c |> Ansi.Internal.toCommand)
        (Ansi.Color.reset Foreground)


{-| Set the color behind your text. See `Ansi.Color` for colors.
-}
backgroundColor : Color -> Attribute
backgroundColor c =
    Style
        (Ansi.Color.encode Background c |> Ansi.Internal.toCommand)
        (Ansi.Color.reset Background)


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
