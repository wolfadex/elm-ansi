module Ink.Border exposing
    ( color
    , backgroundColor
    )

{-| Attributes that modify the appearance of your border


## Color

@docs color
@docs backgroundColor

-}

import Ansi.Color exposing (Color, Location(..))
import Ansi.Internal
import Ink.Internal exposing (Attribute(..))


{-| Set the color of your border. See `Ansi.Color` for colors.
-}
color : Color -> Attribute
color c =
    BorderFontStyle
        (Ansi.Color.encode Font c |> Ansi.Internal.toCommand)
        (Ansi.Color.reset Font)


{-| Set the color behind your border. See `Ansi.Color` for colors.
-}
backgroundColor : Color -> Attribute
backgroundColor c =
    BorderFontStyle
        (Ansi.Color.encode Font c |> Ansi.Internal.toCommand)
        (Ansi.Color.reset Font)
