module Ansi.String exposing (..)

{-| -}

import Ansi
import Ansi.Internal exposing (EastAsianCharWidth(..))
import Regex


{-| Copied from <https://github.com/sindresorhus/string-width/blob/main/index.js>
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


strip : String -> String
strip =
    Regex.replace Ansi.regex (\_ -> "")
