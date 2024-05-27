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
    , brightBlack
    , brightRed
    , brightGreen
    , brightYellow
    , brightBlue
    , brightMagenta
    , brightCyan
    , brightWhite
    , rgb
    , fromHtmlColor
    , toHtmlColor
    , Color(..)
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


## Bright Colors

@docs brightBlack
@docs brightRed
@docs brightGreen
@docs brightYellow
@docs brightBlue
@docs brightMagenta
@docs brightCyan
@docs brightWhite


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


{-| Whether the color is applied to the `Font` (foreground) or the `Background`
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
    CustomTrueColor
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
toHtmlColor color_ =
    let
        c : { red : Int, green : Int, blue : Int }
        c =
            case color_ of
                Black ->
                    { red = 0, green = 0, blue = 0 }

                Red ->
                    { red = 128, green = 0, blue = 0 }

                Green ->
                    { red = 0, green = 128, blue = 0 }

                Yellow ->
                    { red = 128, green = 128, blue = 0 }

                Blue ->
                    { red = 0, green = 0, blue = 128 }

                Magenta ->
                    { red = 128, green = 0, blue = 128 }

                Cyan ->
                    { red = 0, green = 128, blue = 128 }

                White ->
                    { red = 128, green = 128, blue = 128 }

                BrightBlack ->
                    { red = 0, green = 0, blue = 0 }

                BrightRed ->
                    { red = 255, green = 0, blue = 0 }

                BrightGreen ->
                    { red = 0, green = 255, blue = 0 }

                BrightYellow ->
                    { red = 255, green = 255, blue = 0 }

                BrightBlue ->
                    { red = 0, green = 0, blue = 255 }

                BrightMagenta ->
                    { red = 255, green = 0, blue = 255 }

                BrightCyan ->
                    { red = 0, green = 255, blue = 255 }

                BrightWhite ->
                    { red = 255, green = 255, blue = 255 }

                Custom256 { color } ->
                    if color >= 16 && color < 232 then
                        let
                            c_ =
                                color - 16

                            b =
                                modBy 6 c_

                            g =
                                modBy 6 (c_ // 6)

                            r =
                                modBy 6 ((c_ // 6) // 6)

                            -- Scales [0,5] -> [0,255] (not uniformly)
                            -- 0     1     2     3     4     5
                            -- 0    95   135   175   215   255
                            scale n =
                                if n == 0 then
                                    0

                                else
                                    55 + n * 40
                        in
                        { red = scale r, green = scale g, blue = scale b }

                    else if color >= 232 && color < 256 then
                        let
                            -- scales [232,255] -> [8,238]
                            c_ =
                                (color - 232) * 10 + 8
                        in
                        { red = c_, green = c_, blue = c_ }

                    else
                        { red = 0, green = 0, blue = 0 }

                CustomTrueColor customColor_ ->
                    customColor_
    in
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
    = Black
    | Red
    | Green
    | Yellow
    | Blue
    | Magenta
    | Cyan
    | White
    | BrightBlack
    | BrightRed
    | BrightGreen
    | BrightYellow
    | BrightBlue
    | BrightMagenta
    | BrightCyan
    | BrightWhite
    | Custom256
        -- A number ranging from 16 through 255
        { color : Int
        }
    | CustomTrueColor
        { red : Int
        , green : Int
        , blue : Int
        }


{-| Set the color for the following text or background
-}
start : Location -> Color -> String
start location color_ =
    (case color_ of
        Black ->
            case location of
                Font ->
                    [ 30 ]

                Background ->
                    [ 40 ]

        Red ->
            case location of
                Font ->
                    [ 31 ]

                Background ->
                    [ 41 ]

        Green ->
            case location of
                Font ->
                    [ 32 ]

                Background ->
                    [ 42 ]

        Yellow ->
            case location of
                Font ->
                    [ 33 ]

                Background ->
                    [ 43 ]

        Blue ->
            case location of
                Font ->
                    [ 34 ]

                Background ->
                    [ 44 ]

        Magenta ->
            case location of
                Font ->
                    [ 35 ]

                Background ->
                    [ 45 ]

        Cyan ->
            case location of
                Font ->
                    [ 36 ]

                Background ->
                    [ 46 ]

        White ->
            case location of
                Font ->
                    [ 37 ]

                Background ->
                    [ 47 ]

        BrightBlack ->
            case location of
                Font ->
                    [ 90 ]

                Background ->
                    [ 100 ]

        BrightRed ->
            case location of
                Font ->
                    [ 91 ]

                Background ->
                    [ 101 ]

        BrightGreen ->
            case location of
                Font ->
                    [ 92 ]

                Background ->
                    [ 102 ]

        BrightYellow ->
            case location of
                Font ->
                    [ 93 ]

                Background ->
                    [ 103 ]

        BrightBlue ->
            case location of
                Font ->
                    [ 94 ]

                Background ->
                    [ 104 ]

        BrightMagenta ->
            case location of
                Font ->
                    [ 95 ]

                Background ->
                    [ 105 ]

        BrightCyan ->
            case location of
                Font ->
                    [ 96 ]

                Background ->
                    [ 106 ]

        BrightWhite ->
            case location of
                Font ->
                    [ 97 ]

                Background ->
                    [ 107 ]

        Custom256 { color } ->
            case location of
                Font ->
                    [ encodeLocation location, 5, color ]

                Background ->
                    [ encodeLocation location, 5, color ]

        CustomTrueColor customColor_ ->
            [ encodeLocation location, 2, customColor_.red, customColor_.green, customColor_.blue ]
    )
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
    Black


{-| -}
red : Color
red =
    Red


{-| -}
green : Color
green =
    Green


{-| -}
yellow : Color
yellow =
    Yellow


{-| -}
blue : Color
blue =
    Blue


{-| -}
magenta : Color
magenta =
    Magenta


{-| -}
cyan : Color
cyan =
    Cyan


{-| -}
white : Color
white =
    White


{-| -}
brightBlack : Color
brightBlack =
    BrightBlack


{-| -}
brightRed : Color
brightRed =
    BrightRed


{-| -}
brightGreen : Color
brightGreen =
    BrightGreen


{-| -}
brightYellow : Color
brightYellow =
    BrightYellow


{-| -}
brightBlue : Color
brightBlue =
    BrightBlue


{-| -}
brightMagenta : Color
brightMagenta =
    BrightMagenta


{-| -}
brightCyan : Color
brightCyan =
    BrightCyan


{-| -}
brightWhite : Color
brightWhite =
    BrightWhite


{-| Specify the amount of red, green, and blue in the range of 0 - 255
-}
rgb : { red : Int, green : Int, blue : Int } -> Color
rgb opts =
    CustomTrueColor { red = opts.red, blue = opts.blue, green = opts.green }


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
