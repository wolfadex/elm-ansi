module Ansi.Color exposing
    ( fontColor
    , backgroundColor
    , invert
    , black
    , blue
    , cyan
    , green
    , magenta
    , red
    , white
    , yellow
    , rgb
    , fromHtmlColor
    , toHtmlColor
    , Color
    , Location(..)
    , start
    , end
    , startInvert
    , endInvert
    )

{-| For coloring either the font or the background.


## Shorthand

@docs fontColor
@docs backgroundColor
@docs invert


## Basic Colors

@docs black
@docs blue
@docs cyan
@docs green
@docs magenta
@docs red
@docs white
@docs yellow


## Custom Color

@docs rgb


## Converting from/to HTML colors

@docs fromHtmlColor
@docs toHtmlColor


## Explicit

@docs Color
@docs Location

@docs start
@docs end
@docs startInvert
@docs endInvert

-}

import Ansi.Internal
import Color as HtmlColor



-- TODO: Currently only supports TrueColor.
-- 1 for 2,
-- 4 for 16,
-- 8 for 256,
-- 24 for 16,777,216 colors supported.
-- {-|
-- There is work to be able to convert between different color depths
-- -}
-- type Depth
--     = NoColor
--     | Colors16
--     | Colors256
--     | TrueColor
-- {-| -}
-- decodeDepth : Decoder Depth
-- decodeDepth =
--     Json.Decode.int
--         |> Json.Decode.andThen
--             (\d ->
--                 case d of
--                     1 ->
--                         Json.Decode.succeed NoColor
--                     4 ->
--                         Json.Decode.succeed Colors16
--                     8 ->
--                         Json.Decode.succeed Colors256
--                     24 ->
--                         Json.Decode.succeed TrueColor
--                     _ ->
--                         Json.Decode.fail ("Unknown color support" ++ String.fromInt d)
--             )


{-| Whether the color is applied to the `Font` or the `Background`
-}
type Location
    = Font
    | Background


{-| Convert from [avh4/elm-color](https://package.elm-lang.org/packages/avh4/elm-color/latest/) to an ANSI color
-}
fromHtmlColor : HtmlColor.Color -> Color
fromHtmlColor c =
    let
        parts : { red : Float, green : Float, blue : Float, alpha : Float }
        parts =
            HtmlColor.toRgba c
    in
    Color
        { red = floatToInt parts.red
        , green = floatToInt parts.green
        , blue = floatToInt parts.blue
        }


floatToInt : Float -> Int
floatToInt f =
    ceiling (255 * f)


{-| Convert from an ANSI color to [avh4/elm-color](https://package.elm-lang.org/packages/avh4/elm-color/latest/)
-}
toHtmlColor : Color -> HtmlColor.Color
toHtmlColor (Color c) =
    HtmlColor.fromRgba
        { red = intToFloat c.red
        , green = intToFloat c.green
        , blue = intToFloat c.blue
        , alpha = 1
        }


{-| -}
intToFloat : Int -> Float
intToFloat i =
    toFloat i / 255


{-| -}
type Color
    = Color
        { red : Int
        , green : Int
        , blue : Int
        }


{-| Set the color for the following text or background
-}
start : Location -> Color -> String
start location (Color col) =
    [ encodeLocation location, 2, col.red, col.green, col.blue ]
        |> List.map String.fromInt
        |> String.join Ansi.Internal.separator
        |> (\s -> s ++ "m")
        |> Ansi.Internal.toCommand


encodeLocation : Location -> Int
encodeLocation loc =
    case loc of
        Font ->
            38

        Background ->
            48


{-| -}
black : Color
black =
    Color { red = 0, green = 0, blue = 0 }


{-| -}
red : Color
red =
    Color { red = 255, green = 0, blue = 0 }


{-| -}
green : Color
green =
    Color { red = 0, green = 255, blue = 0 }


{-| -}
yellow : Color
yellow =
    Color { red = 255, green = 255, blue = 0 }


{-| -}
blue : Color
blue =
    Color { red = 0, green = 0, blue = 255 }


{-| -}
magenta : Color
magenta =
    Color { red = 255, green = 0, blue = 255 }


{-| -}
cyan : Color
cyan =
    Color { red = 0, green = 255, blue = 255 }


{-| -}
white : Color
white =
    Color { red = 255, green = 255, blue = 255 }


{-| Specify the amount of red, green, and blue in the range of 0 - 255
-}
rgb : { red : Int, green : Int, blue : Int } -> Color
rgb opts =
    Color { red = opts.red, blue = opts.blue, green = opts.green }


{-| Reset to the terminal's default color
-}
end : Location -> String
end location =
    Ansi.Internal.toCommand
        ((case location of
            Font ->
                "39"

            Background ->
                "49"
         )
            ++ "m"
        )


{-| Flip the font and background colors
-}
startInvert : String
startInvert =
    Ansi.Internal.toCommand "7m"


{-| Unflip the font and background colors
-}
endInvert : String
endInvert =
    Ansi.Internal.toCommand "27m"



---- CONVENIENCE FUNCTIONS ----


{-| Swaps the font and background colors
-}
invert : String -> String
invert str =
    startInvert ++ str ++ endInvert


{-| Sets the color of the text
-}
fontColor : Color -> String -> String
fontColor c str =
    start Font c ++ str ++ end Font


{-| Sets the color behind the text
-}
backgroundColor : Color -> String -> String
backgroundColor c str =
    start Background c ++ str ++ end Background
