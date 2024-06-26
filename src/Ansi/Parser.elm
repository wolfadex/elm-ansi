module Ansi.Parser exposing
    ( parse, parseInto
    , Command(..), EraseMode(..)
    )

{-| For parsing ANSI codes into a custom type.
Useful for turning ANSI text into another format such as HTML.

Borrowed from [vito/elm-ansi](https://github.com/vito/elm-ansi/blob/05f89150e8bce99ae863cccda83e636564a64561/src/Ansi.elm) and then modified to fit the rest of this package.

@docs parse, parseInto

@docs Command, EraseMode

-}

import Ansi.Color exposing (Color(..))
import String


{-| The events relevant to interpreting the stream.

  - `Text` is a chunk of text which should be interpreted with the style implied
    by the preceding commands (i.e. `[SetBold True, Text "foo"]`) should yield a
    bold `foo`
  - `Remainder` is a partial ANSI escape sequence, returned at the end of the
    commands if it was cut off. The next string passed to `parse` should have this
    prepended to it.
  - The rest are derived from their respective ANSI escape sequences.

-}
type Command
    = Text String
    | Remainder String
    | SetForeground (Maybe Color)
    | SetBackground (Maybe Color)
    | SetBold Bool
    | SetFaint Bool
    | SetItalic Bool
    | SetUnderline Bool
    | SetBlink Bool
    | SetFastBlink Bool
    | SetInverted Bool
    | SetFraktur Bool
    | SetFramed Bool
    | Linebreak
    | CarriageReturn
    | CursorUp Int
    | CursorDown Int
    | CursorForward Int
    | CursorBack Int
    | CursorPosition Int Int
    | CursorColumn Int
    | EraseDisplay EraseMode
    | EraseLine EraseMode
    | SaveCursorPosition
    | RestoreCursorPosition


{-| Method to erase the display or line.
-}
type EraseMode
    = EraseToBeginning
    | EraseToEnd
    | EraseAll


type Parser a
    = Parser ParserState a (Command -> a -> a)


type ParserState
    = Escaped
    | CSI (List (Maybe Int)) (Maybe Int)
    | Unescaped String


emptyParser : a -> (Command -> a -> a) -> Parser a
emptyParser =
    Parser (Unescaped "")


{-| Convert an arbitrary String of text into a sequence of commands.

If the input string ends with a partial ANSI escape sequence, it will be
yielded as a `Remainder` command, which should then be prepended to the next
call to `parse`.

-}
parse : String -> List Command
parse =
    List.reverse << parseInto [] (::)


{-| Update a structure with commands parsed out of the given string.
-}
parseInto : a -> (Command -> a -> a) -> String -> a
parseInto model update ansi =
    completeParsing <|
        List.foldl parseChar (emptyParser model update) <|
            String.split "" ansi


completeParsing : Parser a -> a
completeParsing parser =
    case parser of
        Parser Escaped model update ->
            update (Remainder "\u{001B}") model

        Parser (CSI codes currentCode) model update ->
            update (Remainder <| "\u{001B}[" ++ encodeCodes (codes ++ [ currentCode ])) model

        Parser (Unescaped "") model _ ->
            model

        Parser (Unescaped str) model update ->
            update (Text str) model


encodeCodes : List (Maybe Int) -> String
encodeCodes codes =
    String.join ";" (List.map encodeCode codes)


encodeCode : Maybe Int -> String
encodeCode code =
    case code of
        Nothing ->
            ""

        Just num ->
            String.fromInt num


{-| Converts a color code to an 8-bit color per
<https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit>
-}
colorCode : Int -> Maybe Color
colorCode code =
    case code of
        0 ->
            Just Black

        1 ->
            Just Red

        2 ->
            Just Green

        3 ->
            Just Yellow

        4 ->
            Just Blue

        5 ->
            Just Magenta

        6 ->
            Just Cyan

        7 ->
            Just White

        8 ->
            Just BrightBlack

        9 ->
            Just BrightRed

        10 ->
            Just BrightGreen

        11 ->
            Just BrightYellow

        12 ->
            Just BrightBlue

        13 ->
            Just BrightMagenta

        14 ->
            Just BrightCyan

        15 ->
            Just BrightWhite

        _ ->
            if code >= 16 || code <= 255 then
                Just <| Custom256 { color = code }

            else
                Nothing


{-| Capture SGR arguments in pattern match
-}
captureArguments : List Int -> List Command
captureArguments list =
    case list of
        38 :: 5 :: n :: xs ->
            SetForeground (colorCode n) :: captureArguments xs

        48 :: 5 :: n :: xs ->
            SetBackground (colorCode n) :: captureArguments xs

        38 :: 2 :: r :: g :: b :: xs ->
            let
                c =
                    clamp 0 255
            in
            SetForeground (Just <| CustomTrueColor { red = c r, green = c g, blue = c b }) :: captureArguments xs

        48 :: 2 :: r :: g :: b :: xs ->
            let
                c =
                    clamp 0 255
            in
            SetBackground (Just <| CustomTrueColor { red = c r, green = c g, blue = c b }) :: captureArguments xs

        n :: xs ->
            codeCommandss n ++ captureArguments xs

        [] ->
            []


parseChar : String -> Parser a -> Parser a
parseChar char parser =
    case parser of
        Parser (Unescaped str) model update ->
            case char of
                "\u{000D}" ->
                    Parser (Unescaped "") (update CarriageReturn (completeUnescaped parser)) update

                "\n" ->
                    Parser (Unescaped "") (update Linebreak (completeUnescaped parser)) update

                "\u{001B}" ->
                    Parser Escaped (completeUnescaped parser) update

                _ ->
                    Parser (Unescaped (str ++ char)) model update

        Parser Escaped model update ->
            case char of
                "[" ->
                    Parser (CSI [] Nothing) model update

                _ ->
                    Parser (Unescaped char) model update

        Parser (CSI codes currentCode) model update ->
            case char of
                "m" ->
                    completeBracketed parser <|
                        captureArguments <|
                            List.map (Maybe.withDefault 0) (codes ++ [ currentCode ])

                "A" ->
                    completeBracketed parser
                        [ CursorUp (Maybe.withDefault 1 currentCode) ]

                "B" ->
                    completeBracketed parser
                        [ CursorDown (Maybe.withDefault 1 currentCode) ]

                "C" ->
                    completeBracketed parser
                        [ CursorForward (Maybe.withDefault 1 currentCode) ]

                "D" ->
                    completeBracketed parser
                        [ CursorBack (Maybe.withDefault 1 currentCode) ]

                "E" ->
                    completeBracketed parser
                        [ CursorDown (Maybe.withDefault 1 currentCode), CursorColumn 0 ]

                "F" ->
                    completeBracketed parser
                        [ CursorUp (Maybe.withDefault 1 currentCode), CursorColumn 0 ]

                "G" ->
                    completeBracketed parser
                        [ CursorColumn (Maybe.withDefault 0 currentCode) ]

                "H" ->
                    completeBracketed parser <|
                        cursorPosition (codes ++ [ currentCode ])

                "J" ->
                    completeBracketed parser
                        [ EraseDisplay (eraseMode (Maybe.withDefault 0 currentCode)) ]

                "K" ->
                    completeBracketed parser
                        [ EraseLine (eraseMode (Maybe.withDefault 0 currentCode)) ]

                "f" ->
                    completeBracketed parser <|
                        cursorPosition (codes ++ [ currentCode ])

                "s" ->
                    completeBracketed parser [ SaveCursorPosition ]

                "u" ->
                    completeBracketed parser [ RestoreCursorPosition ]

                ";" ->
                    Parser (CSI (codes ++ [ currentCode ]) Nothing) model update

                c ->
                    case String.toInt c of
                        Just num ->
                            Parser (CSI codes (Just ((Maybe.withDefault 0 currentCode * 10) + num))) model update

                        Nothing ->
                            completeBracketed parser []


completeUnescaped : Parser a -> a
completeUnescaped parser =
    case parser of
        Parser (Unescaped "") model _ ->
            model

        Parser (Unescaped str) model update ->
            update (Text str) model

        -- should be impossible
        Parser _ model _ ->
            model


completeBracketed : Parser a -> List Command -> Parser a
completeBracketed (Parser _ model update) commands =
    Parser (Unescaped "") (List.foldl update model commands) update


cursorPosition : List (Maybe Int) -> List Command
cursorPosition codes =
    case codes of
        [ Nothing, Nothing ] ->
            [ CursorPosition 1 1 ]

        [ Nothing ] ->
            [ CursorPosition 1 1 ]

        [ Just row, Nothing ] ->
            [ CursorPosition row 1 ]

        [ Nothing, Just col ] ->
            [ CursorPosition 1 col ]

        [ Just row, Just col ] ->
            [ CursorPosition row col ]

        _ ->
            []


eraseMode : Int -> EraseMode
eraseMode code =
    case code of
        0 ->
            EraseToEnd

        1 ->
            EraseToBeginning

        _ ->
            EraseAll


codeCommandss : Int -> List Command
codeCommandss code =
    case code of
        0 ->
            reset

        1 ->
            [ SetBold True ]

        2 ->
            [ SetFaint True ]

        3 ->
            [ SetItalic True ]

        4 ->
            [ SetUnderline True ]

        5 ->
            [ SetBlink True ]

        6 ->
            [ SetFastBlink True ]

        7 ->
            [ SetInverted True ]

        20 ->
            [ SetFraktur True ]

        21 ->
            [ SetBold False ]

        22 ->
            [ SetFaint False
            , SetBold False
            ]

        23 ->
            [ SetItalic False
            , SetFraktur False
            ]

        24 ->
            [ SetUnderline False ]

        25 ->
            [ SetBlink False ]

        27 ->
            [ SetInverted False ]

        30 ->
            [ SetForeground (Just Black) ]

        31 ->
            [ SetForeground (Just Red) ]

        32 ->
            [ SetForeground (Just Green) ]

        33 ->
            [ SetForeground (Just Yellow) ]

        34 ->
            [ SetForeground (Just Blue) ]

        35 ->
            [ SetForeground (Just Magenta) ]

        36 ->
            [ SetForeground (Just Cyan) ]

        37 ->
            [ SetForeground (Just White) ]

        39 ->
            [ SetForeground Nothing ]

        40 ->
            [ SetBackground (Just Black) ]

        41 ->
            [ SetBackground (Just Red) ]

        42 ->
            [ SetBackground (Just Green) ]

        43 ->
            [ SetBackground (Just Yellow) ]

        44 ->
            [ SetBackground (Just Blue) ]

        45 ->
            [ SetBackground (Just Magenta) ]

        46 ->
            [ SetBackground (Just Cyan) ]

        47 ->
            [ SetBackground (Just White) ]

        49 ->
            [ SetBackground Nothing ]

        51 ->
            [ SetFramed True ]

        54 ->
            [ SetFramed False ]

        90 ->
            [ SetForeground (Just BrightBlack) ]

        91 ->
            [ SetForeground (Just BrightRed) ]

        92 ->
            [ SetForeground (Just BrightGreen) ]

        93 ->
            [ SetForeground (Just BrightYellow) ]

        94 ->
            [ SetForeground (Just BrightBlue) ]

        95 ->
            [ SetForeground (Just BrightMagenta) ]

        96 ->
            [ SetForeground (Just BrightCyan) ]

        97 ->
            [ SetForeground (Just BrightWhite) ]

        100 ->
            [ SetBackground (Just BrightBlack) ]

        101 ->
            [ SetBackground (Just BrightRed) ]

        102 ->
            [ SetBackground (Just BrightGreen) ]

        103 ->
            [ SetBackground (Just BrightYellow) ]

        104 ->
            [ SetBackground (Just BrightBlue) ]

        105 ->
            [ SetBackground (Just BrightMagenta) ]

        106 ->
            [ SetBackground (Just BrightCyan) ]

        107 ->
            [ SetBackground (Just BrightWhite) ]

        _ ->
            []


reset : List Command
reset =
    [ SetForeground Nothing
    , SetBackground Nothing
    , SetBold False
    , SetFaint False
    , SetItalic False
    , SetUnderline False
    , SetBlink False
    , SetInverted False
    , SetFraktur False
    , SetFramed False
    ]
