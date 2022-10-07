module Ansi.String exposing
    ( width
    , padRight
    , strip
    )

{-| Various functions for working with ANSI strings. E.g. when measuring the width of an ANSI string you don't want to include any of the command characters, only those that are displayed in the terminal.

@docs width
@docs padRight
@docs strip

-}

import Ansi
import Ansi.Internal exposing (EastAsianCharWidth(..))
import Regex


{-| Add the specified string to the right side of your `String` so that it's the specified length. If this is impossible, e.g. in `padRight 10 "🌈" "hello"` the 🌈 is 2 columns wide meaning that your result will be either 9 or 11 columns wide, then white space will be added to fill the remaining space.
-}
padRight : Int -> String -> String -> String
padRight desiredWidth paddingStr content =
    let
        currentWidth : Int
        currentWidth =
            width content

        paddingWidth : Int
        paddingWidth =
            width paddingStr

        padAmount : Int
        padAmount =
            (desiredWidth - currentWidth) // paddingWidth

        whiteSpaceAmount : Int
        whiteSpaceAmount =
            desiredWidth - (paddingWidth * padAmount) - currentWidth
    in
    content ++ String.repeat padAmount paddingStr ++ String.repeat whiteSpaceAmount " "


{-| Measures the width of a `String` in terminal columns.

Copied from <https://github.com/sindresorhus/string-width/blob/main/index.js>

-}
width : String -> Int
width str =
    if String.isEmpty str then
        0

    else
        let
            withoutAnsi : String
            withoutAnsi =
                strip str
        in
        if String.isEmpty withoutAnsi then
            0

        else
            let
                replacedEmojis : String
                replacedEmojis =
                    Regex.replace Ansi.emojiRegex (\_ -> "  ") withoutAnsi
            in
            String.foldl
                (\char total ->
                    let
                        codePoint : Int
                        codePoint =
                            Char.toCode char
                    in
                    if
                        (codePoint <= 0x1F)
                            || (codePoint >= 0x7F && codePoint <= 0x9F)
                            || (codePoint >= 0x0300 && codePoint <= 0x036F)
                    then
                        total

                    else
                        case Ansi.Internal.eastAsianWidth (String.fromChar char) of
                            Just FullWidth ->
                                total + 2

                            Just Wide ->
                                total + 2

                            Just Ambiguous ->
                                total + 1

                            Nothing ->
                                total

                            _ ->
                                total + 1
                )
                0
                replacedEmojis


{-| Remove ANSI characters from a `String`. Mostly useful for things like measuring a `String`'s width.
-}
strip : String -> String
strip =
    Regex.replace Ansi.regex (\_ -> "")
