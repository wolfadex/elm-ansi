module Ansi.Internal exposing (..)

import Bitwise
import Regex


toAnsiCommand : String -> String
toAnsiCommand str =
    "\u{001B}[" ++ str



-- Below borrowed from https://github.com/komagata/eastasianwidth/blob/master/eastasianwidth.jshttps://github.com/komagata/eastasianwidth/blob/master/eastasianwidth.js


type EastAsianCharWidth
    = FullWidth
    | HalfWidth
    | Wide
    | Narrow
    | Ambiguous
    | Natural


eastAsianWidth : String -> Maybe EastAsianCharWidth
eastAsianWidth character =
    case String.toList character of
        [ char ] ->
            eastAsianWidthHelper
                (Char.toCode char)
                0
                |> Just

        [ char1, char2 ] ->
            eastAsianWidthHelper
                (Char.toCode char1)
                (Char.toCode char2)
                |> Just

        _ ->
            Nothing


eastAsianWidthHelper : Int -> Int -> EastAsianCharWidth
eastAsianWidthHelper x y =
    let
        codePoint =
            getCodePoint ( x, y )
    in
    if
        (0x3000 == codePoint)
            || (0xFF01 <= codePoint && codePoint <= 0xFF60)
            || (0xFFE0 <= codePoint && codePoint <= 0xFFE6)
    then
        FullWidth

    else if
        (0x20A9 == codePoint)
            || (0xFF61 <= codePoint && codePoint <= 0xFFBE)
            || (0xFFC2 <= codePoint && codePoint <= 0xFFC7)
            || (0xFFCA <= codePoint && codePoint <= 0xFFCF)
            || (0xFFD2 <= codePoint && codePoint <= 0xFFD7)
            || (0xFFDA <= codePoint && codePoint <= 0xFFDC)
            || (0xFFE8 <= codePoint && codePoint <= 0xFFEE)
    then
        HalfWidth

    else if
        (0x1100 <= codePoint && codePoint <= 0x115F)
            || (0x11A3 <= codePoint && codePoint <= 0x11A7)
            || (0x11FA <= codePoint && codePoint <= 0x11FF)
            || (0x2329 <= codePoint && codePoint <= 0x232A)
            || (0x2E80 <= codePoint && codePoint <= 0x2E99)
            || (0x2E9B <= codePoint && codePoint <= 0x2EF3)
            || (0x2F00 <= codePoint && codePoint <= 0x2FD5)
            || (0x2FF0 <= codePoint && codePoint <= 0x2FFB)
            || (0x3001 <= codePoint && codePoint <= 0x303E)
            || (0x3041 <= codePoint && codePoint <= 0x3096)
            || (0x3099 <= codePoint && codePoint <= 0x30FF)
            || (0x3105 <= codePoint && codePoint <= 0x312D)
            || (0x3131 <= codePoint && codePoint <= 0x318E)
            || (0x3190 <= codePoint && codePoint <= 0x31BA)
            || (0x31C0 <= codePoint && codePoint <= 0x31E3)
            || (0x31F0 <= codePoint && codePoint <= 0x321E)
            || (0x3220 <= codePoint && codePoint <= 0x3247)
            || (0x3250 <= codePoint && codePoint <= 0x32FE)
            || (0x3300 <= codePoint && codePoint <= 0x4DBF)
            || (0x4E00 <= codePoint && codePoint <= 0xA48C)
            || (0xA490 <= codePoint && codePoint <= 0xA4C6)
            || (0xA960 <= codePoint && codePoint <= 0xA97C)
            || (0xAC00 <= codePoint && codePoint <= 0xD7A3)
            || (0xD7B0 <= codePoint && codePoint <= 0xD7C6)
            || (0xD7CB <= codePoint && codePoint <= 0xD7FB)
            || (0xF900 <= codePoint && codePoint <= 0xFAFF)
            || (0xFE10 <= codePoint && codePoint <= 0xFE19)
            || (0xFE30 <= codePoint && codePoint <= 0xFE52)
            || (0xFE54 <= codePoint && codePoint <= 0xFE66)
            || (0xFE68 <= codePoint && codePoint <= 0xFE6B)
            || (0x0001B000 <= codePoint && codePoint <= 0x0001B001)
            || (0x0001F200 <= codePoint && codePoint <= 0x0001F202)
            || (0x0001F210 <= codePoint && codePoint <= 0x0001F23A)
            || (0x0001F240 <= codePoint && codePoint <= 0x0001F248)
            || (0x0001F250 <= codePoint && codePoint <= 0x0001F251)
            || (0x00020000 <= codePoint && codePoint <= 0x0002F73F)
            || (0x0002B740 <= codePoint && codePoint <= 0x0002FFFD)
            || (0x00030000 <= codePoint && codePoint <= 0x0003FFFD)
    then
        Wide

    else if
        (0x20 <= codePoint && codePoint <= 0x7E)
            || (0xA2 <= codePoint && codePoint <= 0xA3)
            || (0xA5 <= codePoint && codePoint <= 0xA6)
            || (0xAC == codePoint)
            || (0xAF == codePoint)
            || (0x27E6 <= codePoint && codePoint <= 0x27ED)
            || (0x2985 <= codePoint && codePoint <= 0x2986)
    then
        Narrow

    else if
        (0xA1 == codePoint)
            || (0xA4 == codePoint)
            || (0xA7 <= codePoint && codePoint <= 0xA8)
            || (0xAA == codePoint)
            || (0xAD <= codePoint && codePoint <= 0xAE)
            || (0xB0 <= codePoint && codePoint <= 0xB4)
            || (0xB6 <= codePoint && codePoint <= 0xBA)
            || (0xBC <= codePoint && codePoint <= 0xBF)
            || (0xC6 == codePoint)
            || (0xD0 == codePoint)
            || (0xD7 <= codePoint && codePoint <= 0xD8)
            || (0xDE <= codePoint && codePoint <= 0xE1)
            || (0xE6 == codePoint)
            || (0xE8 <= codePoint && codePoint <= 0xEA)
            || (0xEC <= codePoint && codePoint <= 0xED)
            || (0xF0 == codePoint)
            || (0xF2 <= codePoint && codePoint <= 0xF3)
            || (0xF7 <= codePoint && codePoint <= 0xFA)
            || (0xFC == codePoint)
            || (0xFE == codePoint)
            || (0x0101 == codePoint)
            || (0x0111 == codePoint)
            || (0x0113 == codePoint)
            || (0x011B == codePoint)
            || (0x0126 <= codePoint && codePoint <= 0x0127)
            || (0x012B == codePoint)
            || (0x0131 <= codePoint && codePoint <= 0x0133)
            || (0x0138 == codePoint)
            || (0x013F <= codePoint && codePoint <= 0x0142)
            || (0x0144 == codePoint)
            || (0x0148 <= codePoint && codePoint <= 0x014B)
            || (0x014D == codePoint)
            || (0x0152 <= codePoint && codePoint <= 0x0153)
            || (0x0166 <= codePoint && codePoint <= 0x0167)
            || (0x016B == codePoint)
            || (0x01CE == codePoint)
            || (0x01D0 == codePoint)
            || (0x01D2 == codePoint)
            || (0x01D4 == codePoint)
            || (0x01D6 == codePoint)
            || (0x01D8 == codePoint)
            || (0x01DA == codePoint)
            || (0x01DC == codePoint)
            || (0x0251 == codePoint)
            || (0x0261 == codePoint)
            || (0x02C4 == codePoint)
            || (0x02C7 == codePoint)
            || (0x02C9 <= codePoint && codePoint <= 0x02CB)
            || (0x02CD == codePoint)
            || (0x02D0 == codePoint)
            || (0x02D8 <= codePoint && codePoint <= 0x02DB)
            || (0x02DD == codePoint)
            || (0x02DF == codePoint)
            || (0x0300 <= codePoint && codePoint <= 0x036F)
            || (0x0391 <= codePoint && codePoint <= 0x03A1)
            || (0x03A3 <= codePoint && codePoint <= 0x03A9)
            || (0x03B1 <= codePoint && codePoint <= 0x03C1)
            || (0x03C3 <= codePoint && codePoint <= 0x03C9)
            || (0x0401 == codePoint)
            || (0x0410 <= codePoint && codePoint <= 0x044F)
            || (0x0451 == codePoint)
            || (0x2010 == codePoint)
            || (0x2013 <= codePoint && codePoint <= 0x2016)
            || (0x2018 <= codePoint && codePoint <= 0x2019)
            || (0x201C <= codePoint && codePoint <= 0x201D)
            || (0x2020 <= codePoint && codePoint <= 0x2022)
            || (0x2024 <= codePoint && codePoint <= 0x2027)
            || (0x2030 == codePoint)
            || (0x2032 <= codePoint && codePoint <= 0x2033)
            || (0x2035 == codePoint)
            || (0x203B == codePoint)
            || (0x203E == codePoint)
            || (0x2074 == codePoint)
            || (0x207F == codePoint)
            || (0x2081 <= codePoint && codePoint <= 0x2084)
            || (0x20AC == codePoint)
            || (0x2103 == codePoint)
            || (0x2105 == codePoint)
            || (0x2109 == codePoint)
            || (0x2113 == codePoint)
            || (0x2116 == codePoint)
            || (0x2121 <= codePoint && codePoint <= 0x2122)
            || (0x2126 == codePoint)
            || (0x212B == codePoint)
            || (0x2153 <= codePoint && codePoint <= 0x2154)
            || (0x215B <= codePoint && codePoint <= 0x215E)
            || (0x2160 <= codePoint && codePoint <= 0x216B)
            || (0x2170 <= codePoint && codePoint <= 0x2179)
            || (0x2189 == codePoint)
            || (0x2190 <= codePoint && codePoint <= 0x2199)
            || (0x21B8 <= codePoint && codePoint <= 0x21B9)
            || (0x21D2 == codePoint)
            || (0x21D4 == codePoint)
            || (0x21E7 == codePoint)
            || (0x2200 == codePoint)
            || (0x2202 <= codePoint && codePoint <= 0x2203)
            || (0x2207 <= codePoint && codePoint <= 0x2208)
            || (0x220B == codePoint)
            || (0x220F == codePoint)
            || (0x2211 == codePoint)
            || (0x2215 == codePoint)
            || (0x221A == codePoint)
            || (0x221D <= codePoint && codePoint <= 0x2220)
            || (0x2223 == codePoint)
            || (0x2225 == codePoint)
            || (0x2227 <= codePoint && codePoint <= 0x222C)
            || (0x222E == codePoint)
            || (0x2234 <= codePoint && codePoint <= 0x2237)
            || (0x223C <= codePoint && codePoint <= 0x223D)
            || (0x2248 == codePoint)
            || (0x224C == codePoint)
            || (0x2252 == codePoint)
            || (0x2260 <= codePoint && codePoint <= 0x2261)
            || (0x2264 <= codePoint && codePoint <= 0x2267)
            || (0x226A <= codePoint && codePoint <= 0x226B)
            || (0x226E <= codePoint && codePoint <= 0x226F)
            || (0x2282 <= codePoint && codePoint <= 0x2283)
            || (0x2286 <= codePoint && codePoint <= 0x2287)
            || (0x2295 == codePoint)
            || (0x2299 == codePoint)
            || (0x22A5 == codePoint)
            || (0x22BF == codePoint)
            || (0x2312 == codePoint)
            || (0x2460 <= codePoint && codePoint <= 0x24E9)
            || (0x24EB <= codePoint && codePoint <= 0x254B)
            || (0x2550 <= codePoint && codePoint <= 0x2573)
            || (0x2580 <= codePoint && codePoint <= 0x258F)
            || (0x2592 <= codePoint && codePoint <= 0x2595)
            || (0x25A0 <= codePoint && codePoint <= 0x25A1)
            || (0x25A3 <= codePoint && codePoint <= 0x25A9)
            || (0x25B2 <= codePoint && codePoint <= 0x25B3)
            || (0x25B6 <= codePoint && codePoint <= 0x25B7)
            || (0x25BC <= codePoint && codePoint <= 0x25BD)
            || (0x25C0 <= codePoint && codePoint <= 0x25C1)
            || (0x25C6 <= codePoint && codePoint <= 0x25C8)
            || (0x25CB == codePoint)
            || (0x25CE <= codePoint && codePoint <= 0x25D1)
            || (0x25E2 <= codePoint && codePoint <= 0x25E5)
            || (0x25EF == codePoint)
            || (0x2605 <= codePoint && codePoint <= 0x2606)
            || (0x2609 == codePoint)
            || (0x260E <= codePoint && codePoint <= 0x260F)
            || (0x2614 <= codePoint && codePoint <= 0x2615)
            || (0x261C == codePoint)
            || (0x261E == codePoint)
            || (0x2640 == codePoint)
            || (0x2642 == codePoint)
            || (0x2660 <= codePoint && codePoint <= 0x2661)
            || (0x2663 <= codePoint && codePoint <= 0x2665)
            || (0x2667 <= codePoint && codePoint <= 0x266A)
            || (0x266C <= codePoint && codePoint <= 0x266D)
            || (0x266F == codePoint)
            || (0x269E <= codePoint && codePoint <= 0x269F)
            || (0x26BE <= codePoint && codePoint <= 0x26BF)
            || (0x26C4 <= codePoint && codePoint <= 0x26CD)
            || (0x26CF <= codePoint && codePoint <= 0x26E1)
            || (0x26E3 == codePoint)
            || (0x26E8 <= codePoint && codePoint <= 0x26FF)
            || (0x273D == codePoint)
            || (0x2757 == codePoint)
            || (0x2776 <= codePoint && codePoint <= 0x277F)
            || (0x2B55 <= codePoint && codePoint <= 0x2B59)
            || (0x3248 <= codePoint && codePoint <= 0x324F)
            || (0xE000 <= codePoint && codePoint <= 0xF8FF)
            || (0xFE00 <= codePoint && codePoint <= 0xFE0F)
            || (0xFFFD == codePoint)
            || (0x0001F100 <= codePoint && codePoint <= 0x0001F10A)
            || (0x0001F110 <= codePoint && codePoint <= 0x0001F12D)
            || (0x0001F130 <= codePoint && codePoint <= 0x0001F169)
            || (0x0001F170 <= codePoint && codePoint <= 0x0001F19A)
            || (0x000E0100 <= codePoint && codePoint <= 0x000E01EF)
            || (0x000F0000 <= codePoint && codePoint <= 0x000FFFFD)
            || (0x00100000 <= codePoint && codePoint <= 0x0010FFFD)
    then
        Ambiguous

    else
        Natural


getCodePoint : ( Int, Int ) -> Int
getCodePoint ( x, y ) =
    if (0xD800 <= x && x <= 0xDBFF) && (0xDC00 <= y && y <= 0xDFFF) then
        x
            |> Bitwise.and 0x03FF
            |> Bitwise.shiftLeftBy 10
            |> Bitwise.or (Bitwise.and y 0x03FF)
            |> (\codePoint_ -> codePoint_ + 0x00010000)

    else
        x


characterLength : String -> Int
characterLength character =
    case eastAsianWidth character of
        Nothing ->
            0

        Just FullWidth ->
            2

        Just Wide ->
            2

        Just Ambiguous ->
            2

        _ ->
            1


{-| Split a string considering surrogate-pairs.
-}
toList : String -> List String
toList =
    Regex.split
        (Regex.fromString "[\u{D800}-\u{DBFF}][\u{DC00}-\u{DFFF}]|[^\u{D800}-\u{DFFF}]"
            |> Maybe.withDefault Regex.never
        )


length : String -> Int
length string =
    List.foldl
        (\char total ->
            total + characterLength char
        )
        0
        (toList string)


slice : Int -> Int -> String -> String
slice start end text =
    let
        textLen =
            length text

        start_ =
            if start < 0 then
                textLen + start

            else
                start

        end_ =
            if end < 0 then
                textLen + end

            else
                end
    in
    List.foldl
        (\char ( result, eawLen ) ->
            let
                charLen =
                    length char
            in
            if
                eawLen
                    >= start_
                    - (if charLen == 2 then
                        1

                       else
                        0
                      )
            then
                if eawLen + charLen <= end_ then
                    ( result ++ char, eawLen )

                else
                    ( result, eawLen )

            else
                ( result, eawLen + charLen )
        )
        ( "", 0 )
        (toList text)
        |> Tuple.first
