module Ansi.Color exposing
    ( Color
    , Depth(..)
    , Location(..)
    , black
    , blue
    , cyan
    , decodeDepth
    , encode
    , fromHtmlColor
    , green
    , magenta
    , red
    , reset
    , rgb
    , toHtmlColor
    , white
    , yellow
    )

{-| For coloring either the font or the background.

@docs Color
@docs Depth
@docs Location
@docs black
@docs blue
@docs cyan
@docs decodeDepth
@docs encode
@docs fromHtmlColor
@docs green
@docs magenta
@docs red
@docs reset
@docs rgb
@docs toHtmlColor
@docs white
@docs yellow

-}

import Ansi.Internal
import Color as HtmlColor
import Json.Decode exposing (Decoder)



-- 1 for 2,
-- 4 for 16,
-- 8 for 256,
-- 24 for 16,777,216 colors supported.


{-| **TODO:** Currently only supports TrueColor.

There is work to be able to convert between different color depths

-}
type Depth
    = NoColor
    | Colors16
    | Colors256
    | TrueColor


{-| -}
decodeDepth : Decoder Depth
decodeDepth =
    Json.Decode.int
        |> Json.Decode.andThen
            (\d ->
                case d of
                    1 ->
                        Json.Decode.succeed NoColor

                    4 ->
                        Json.Decode.succeed Colors16

                    8 ->
                        Json.Decode.succeed Colors256

                    24 ->
                        Json.Decode.succeed TrueColor

                    _ ->
                        Json.Decode.fail ("Unknown color support" ++ String.fromInt d)
            )


{-| -}
type Location
    = Foreground
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


{-| -}
encode : Location -> Color -> String
encode location (Color col) =
    [ encodeLocation location, 2, col.red, col.green, col.blue ]
        |> List.map String.fromInt
        |> String.join ";"
        |> (\s -> s ++ "m")


encodeLocation : Location -> Int
encodeLocation loc =
    case loc of
        Foreground ->
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


{-| -}
reset : Location -> String
reset location =
    Ansi.Internal.toCommand
        ((case location of
            Foreground ->
                "39"

            Background ->
                "49"
         )
            ++ "m"
        )
