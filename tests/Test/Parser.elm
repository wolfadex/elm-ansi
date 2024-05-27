module Test.Parser exposing (suite)

import Ansi
import Ansi.Color
import Ansi.Cursor
import Ansi.Font
import Ansi.Parser
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "ANSI"
        [ parsing
        ]


parsing : Test
parsing =
    describe "Parsing"
        [ test "colors" <|
            \() ->
                ("normal"
                    ++ Ansi.Color.start Ansi.Color.Font Ansi.Color.red
                    ++ "red fg"
                    ++ Ansi.Color.start Ansi.Color.Background Ansi.Color.green
                    ++ "green bg"
                    ++ Ansi.Color.start Ansi.Color.Font Ansi.Color.brightRed
                    ++ "bright red fg"
                    ++ Ansi.Color.start Ansi.Color.Background Ansi.Color.brightGreen
                    ++ "bright green bg"
                )
                    |> Ansi.Parser.parse
                    |> Expect.equal
                        [ Ansi.Parser.Text "normal"
                        , Ansi.Parser.SetForeground (Just Ansi.Color.Red)
                        , Ansi.Parser.Text "red fg"
                        , Ansi.Parser.SetBackground (Just Ansi.Color.Green)
                        , Ansi.Parser.Text "green bg"
                        , Ansi.Parser.SetForeground (Just Ansi.Color.BrightRed)
                        , Ansi.Parser.Text "bright red fg"
                        , Ansi.Parser.SetBackground (Just Ansi.Color.BrightGreen)
                        , Ansi.Parser.Text "bright green bg"
                        ]
        , test "single argument colors" <|
            \() ->
                ("normal"
                    ++ Ansi.Color.start Ansi.Color.Font Ansi.Color.red
                    ++ "red fg"
                    ++ Ansi.Color.start Ansi.Color.Background Ansi.Color.green
                    ++ "green bg"
                    ++ Ansi.Color.start Ansi.Color.Font Ansi.Color.brightRed
                    ++ "bright red fg"
                    ++ Ansi.Color.start Ansi.Color.Background Ansi.Color.brightGreen
                    ++ "bright green bg"
                )
                    |> Ansi.Parser.parse
                    |> Expect.equal
                        [ Ansi.Parser.Text "normal"
                        , Ansi.Parser.SetForeground (Just Ansi.Color.Red)
                        , Ansi.Parser.Text "red fg"
                        , Ansi.Parser.SetBackground (Just Ansi.Color.Green)
                        , Ansi.Parser.Text "green bg"
                        , Ansi.Parser.SetForeground (Just Ansi.Color.BrightRed)
                        , Ansi.Parser.Text "bright red fg"
                        , Ansi.Parser.SetBackground (Just Ansi.Color.BrightGreen)
                        , Ansi.Parser.Text "bright green bg"
                        ]
        , test "8-bit colors" <|
            \() ->
                ("normal"
                    ++ Ansi.Color.start Ansi.Color.Font Ansi.Color.blue
                    ++ "green fg"
                    ++ Ansi.Color.start Ansi.Color.Background Ansi.Color.cyan
                    ++ "orange bg"
                    ++ Ansi.Color.start Ansi.Color.Font Ansi.Color.brightYellow
                    ++ "dark grey fg"
                    ++ Ansi.Color.start Ansi.Color.Background Ansi.Color.brightMagenta
                    ++ "light grey bg"
                )
                    |> Ansi.Parser.parse
                    |> Expect.equal
                        [ Ansi.Parser.Text "normal"
                        , Ansi.Parser.SetForeground (Just <| Ansi.Color.Blue)
                        , Ansi.Parser.Text "green fg"
                        , Ansi.Parser.SetBackground (Just <| Ansi.Color.Cyan)
                        , Ansi.Parser.Text "orange bg"
                        , Ansi.Parser.SetForeground (Just <| Ansi.Color.BrightYellow)
                        , Ansi.Parser.Text "dark grey fg"
                        , Ansi.Parser.SetBackground (Just <| Ansi.Color.BrightMagenta)
                        , Ansi.Parser.Text "light grey bg"
                        ]
        , test "24-bit colors" <|
            \() ->
                "normal"
                    ++ Ansi.Color.start Ansi.Color.Font (Ansi.Color.Custom256 { color = 76 })
                    ++ "custom fg"
                    ++ Ansi.Color.start Ansi.Color.Background (Ansi.Color.Custom256 { color = 32 })
                    ++ "custom bg"
                    ++ Ansi.Color.start Ansi.Color.Background (Ansi.Color.Custom256 { color = 212 })
                    ++ "clamped"
                    |> Ansi.Parser.parse
                    |> Expect.equal
                        [ Ansi.Parser.Text "normal"
                        , Ansi.Parser.SetForeground (Just <| Ansi.Color.Custom256 { color = 76 })
                        , Ansi.Parser.Text "custom fg"
                        , Ansi.Parser.SetBackground (Just <| Ansi.Color.Custom256 { color = 32 })
                        , Ansi.Parser.Text "custom bg"
                        , Ansi.Parser.SetBackground (Just <| Ansi.Color.Custom256 { color = 212 })
                        , Ansi.Parser.Text "clamped"
                        ]
        , test "true-color colors" <|
            \() ->
                "normal"
                    ++ Ansi.Color.start Ansi.Color.Font (Ansi.Color.CustomTrueColor { red = 123, green = 15, blue = 51 })
                    ++ "custom fg"
                    ++ Ansi.Color.start Ansi.Color.Background (Ansi.Color.CustomTrueColor { red = 55, green = 66, blue = 77 })
                    ++ "custom bg"
                    ++ Ansi.Color.start Ansi.Color.Background (Ansi.Color.CustomTrueColor { red = 1000, green = 0, blue = 255 })
                    ++ "clamped"
                    |> Ansi.Parser.parse
                    |> Expect.equal
                        [ Ansi.Parser.Text "normal"
                        , Ansi.Parser.SetForeground (Just <| Ansi.Color.CustomTrueColor { red = 123, green = 15, blue = 51 })
                        , Ansi.Parser.Text "custom fg"
                        , Ansi.Parser.SetBackground (Just <| Ansi.Color.CustomTrueColor { red = 55, green = 66, blue = 77 })
                        , Ansi.Parser.Text "custom bg"
                        , Ansi.Parser.SetBackground (Just <| Ansi.Color.CustomTrueColor { red = 255, green = 0, blue = 255 })
                        , Ansi.Parser.Text "clamped"
                        ]
        , test "text styling" <|
            \() ->
                ("normal"
                    ++ Ansi.Font.startBold
                    ++ "bold"
                    ++ Ansi.Font.startFaint
                    ++ "faint"
                    ++ Ansi.Font.startItalic
                    ++ "italic"
                    ++ Ansi.Font.startUnderline
                    ++ "underline"
                    ++ Ansi.Font.startBlink
                    ++ "blink"
                    ++ Ansi.Font.startFastBlink
                    ++ "fast blink"
                    ++ Ansi.Color.startInvert
                    ++ "inverted"
                )
                    |> Ansi.Parser.parse
                    |> Expect.equal
                        [ Ansi.Parser.Text "normal"
                        , Ansi.Parser.SetBold True
                        , Ansi.Parser.Text "bold"
                        , Ansi.Parser.SetFaint True
                        , Ansi.Parser.Text "faint"
                        , Ansi.Parser.SetItalic True
                        , Ansi.Parser.Text "italic"
                        , Ansi.Parser.SetUnderline True
                        , Ansi.Parser.Text "underline"
                        , Ansi.Parser.SetBlink True
                        , Ansi.Parser.Text "blink"
                        , Ansi.Parser.SetFastBlink True
                        , Ansi.Parser.Text "fast blink"
                        , Ansi.Parser.SetInverted True
                        , Ansi.Parser.Text "inverted"
                        ]
        , test "resetting" <|
            \() ->
                ("some text"
                    ++ Ansi.Font.resetAll
                    ++ "reset"
                    ++ Ansi.Font.resetAll
                    ++ "reset again\u{001B}[;31mreset to red"
                )
                    |> Ansi.Parser.parse
                    |> Expect.equal
                        [ Ansi.Parser.Text "some text"
                        , Ansi.Parser.SetForeground Nothing
                        , Ansi.Parser.SetBackground Nothing
                        , Ansi.Parser.SetBold False
                        , Ansi.Parser.SetFaint False
                        , Ansi.Parser.SetItalic False
                        , Ansi.Parser.SetUnderline False
                        , Ansi.Parser.SetBlink False
                        , Ansi.Parser.SetInverted False
                        , Ansi.Parser.SetFraktur False
                        , Ansi.Parser.SetFramed False
                        , Ansi.Parser.Text "reset"
                        , Ansi.Parser.SetForeground Nothing
                        , Ansi.Parser.SetBackground Nothing
                        , Ansi.Parser.SetBold False
                        , Ansi.Parser.SetFaint False
                        , Ansi.Parser.SetItalic False
                        , Ansi.Parser.SetUnderline False
                        , Ansi.Parser.SetBlink False
                        , Ansi.Parser.SetInverted False
                        , Ansi.Parser.SetFraktur False
                        , Ansi.Parser.SetFramed False
                        , Ansi.Parser.Text "reset again"
                        , Ansi.Parser.SetForeground Nothing
                        , Ansi.Parser.SetBackground Nothing
                        , Ansi.Parser.SetBold False
                        , Ansi.Parser.SetFaint False
                        , Ansi.Parser.SetItalic False
                        , Ansi.Parser.SetUnderline False
                        , Ansi.Parser.SetBlink False
                        , Ansi.Parser.SetInverted False
                        , Ansi.Parser.SetFraktur False
                        , Ansi.Parser.SetFramed False
                        , Ansi.Parser.SetForeground (Just Ansi.Color.Red)
                        , Ansi.Parser.Text "reset to red"
                        ]
        , test "partial resetting" <|
            \() ->
                ("some text"
                    ++ Ansi.Font.endBold
                    ++ "not bold"
                    ++ Ansi.Font.endBoldFaint
                    ++ "not intense"
                    ++ Ansi.Font.endItalic
                    ++ "not italic/fraktur"
                )
                    |> Ansi.Parser.parse
                    |> Expect.equal
                        [ Ansi.Parser.Text "some text"
                        , Ansi.Parser.SetBold False
                        , Ansi.Parser.Text "not bold"
                        , Ansi.Parser.SetFaint False
                        , Ansi.Parser.SetBold False
                        , Ansi.Parser.Text "not intense"
                        , Ansi.Parser.SetItalic False
                        , Ansi.Parser.SetFraktur False
                        , Ansi.Parser.Text "not italic/fraktur"
                        ]
        , test "carriage returns and linebreaks" <|
            \() ->
                "some text\u{000D}\nnext line\u{000D}overwriting\nshifted down"
                    |> Ansi.Parser.parse
                    |> Expect.equal
                        [ Ansi.Parser.Text "some text"
                        , Ansi.Parser.CarriageReturn
                        , Ansi.Parser.Linebreak
                        , Ansi.Parser.Text "next line"
                        , Ansi.Parser.CarriageReturn
                        , Ansi.Parser.Text "overwriting"
                        , Ansi.Parser.Linebreak
                        , Ansi.Parser.Text "shifted down"
                        ]
        , test "cursor movement" <|
            \() ->
                (Ansi.Cursor.moveUpBy 5
                    ++ Ansi.Cursor.moveUpBy 50
                    ++ Ansi.Cursor.moveUpBy 1
                    ++ Ansi.Cursor.moveDownBy 5
                    ++ Ansi.Cursor.moveDownBy 50
                    ++ Ansi.Cursor.moveDownBy 1
                    ++ Ansi.Cursor.moveForwardBy 5
                    ++ Ansi.Cursor.moveForwardBy 50
                    ++ Ansi.Cursor.moveForwardBy 1
                    ++ Ansi.Cursor.moveBackwardBy 5
                    ++ Ansi.Cursor.moveBackwardBy 50
                    ++ Ansi.Cursor.moveBackwardBy 1
                    ++ Ansi.Cursor.moveTo { row = 1, column = 50 }
                    ++ Ansi.Cursor.moveTo { row = 50, column = 1 }
                    ++ Ansi.Cursor.moveTo { row = 1, column = 1 }
                    ++ Ansi.Cursor.moveTo { row = 50, column = 50 }
                )
                    |> Ansi.Parser.parse
                    |> Expect.equal
                        [ Ansi.Parser.CursorUp 5
                        , Ansi.Parser.CursorUp 50
                        , Ansi.Parser.CursorUp 1
                        , Ansi.Parser.CursorDown 5
                        , Ansi.Parser.CursorDown 50
                        , Ansi.Parser.CursorDown 1
                        , Ansi.Parser.CursorForward 5
                        , Ansi.Parser.CursorForward 50
                        , Ansi.Parser.CursorForward 1
                        , Ansi.Parser.CursorBack 5
                        , Ansi.Parser.CursorBack 50
                        , Ansi.Parser.CursorBack 1
                        , Ansi.Parser.CursorPosition 1 50
                        , Ansi.Parser.CursorPosition 50 1
                        , Ansi.Parser.CursorPosition 1 1
                        , Ansi.Parser.CursorPosition 50 50
                        ]
        , test "cursor movement (not ANSI.SYS)" <|
            \() ->
                Expect.equal
                    [ Ansi.Parser.CursorDown 1
                    , Ansi.Parser.CursorColumn 0
                    , Ansi.Parser.CursorDown 5
                    , Ansi.Parser.CursorColumn 0
                    , Ansi.Parser.CursorDown 50
                    , Ansi.Parser.CursorColumn 0
                    , Ansi.Parser.CursorUp 1
                    , Ansi.Parser.CursorColumn 0
                    , Ansi.Parser.CursorUp 5
                    , Ansi.Parser.CursorColumn 0
                    , Ansi.Parser.CursorUp 50
                    , Ansi.Parser.CursorColumn 0
                    , Ansi.Parser.CursorColumn 0
                    , Ansi.Parser.CursorColumn 0
                    , Ansi.Parser.CursorColumn 1
                    , Ansi.Parser.CursorColumn 5
                    , Ansi.Parser.CursorColumn 50
                    ]
                    (Ansi.Parser.parse "\u{001B}[E\u{001B}[5E\u{001B}[50E\u{001B}[F\u{001B}[5F\u{001B}[50F\u{001B}[G\u{001B}[0G\u{001B}[1G\u{001B}[5G\u{001B}[50G")
        , test "cursor position save/restore" <|
            \() ->
                Expect.equal
                    [ Ansi.Parser.SaveCursorPosition
                    , Ansi.Parser.RestoreCursorPosition
                    ]
                    (Ansi.Parser.parse "\u{001B}[s\u{001B}[u")
        , test "erasure" <|
            \() ->
                (Ansi.eraseDown
                    ++ "\u{001B}[0J"
                    ++ Ansi.eraseUp
                    ++ Ansi.eraseScreen
                    ++ Ansi.eraseLineAfter
                    ++ "\u{001B}[0K"
                    ++ Ansi.eraseLineBefore
                    ++ Ansi.eraseLine
                )
                    |> Ansi.Parser.parse
                    |> Expect.equal
                        [ Ansi.Parser.EraseDisplay Ansi.Parser.EraseToEnd
                        , Ansi.Parser.EraseDisplay Ansi.Parser.EraseToEnd
                        , Ansi.Parser.EraseDisplay Ansi.Parser.EraseToBeginning
                        , Ansi.Parser.EraseDisplay Ansi.Parser.EraseAll
                        , Ansi.Parser.EraseLine Ansi.Parser.EraseToEnd
                        , Ansi.Parser.EraseLine Ansi.Parser.EraseToEnd
                        , Ansi.Parser.EraseLine Ansi.Parser.EraseToBeginning
                        , Ansi.Parser.EraseLine Ansi.Parser.EraseAll
                        ]
        , test "partial escape sequence" <|
            \() ->
                Expect.equal
                    [ Ansi.Parser.Text "foo", Ansi.Parser.Remainder "\u{001B}" ]
                    (Ansi.Parser.parse "foo\u{001B}")
        , test "partial escape sequence with bracket" <|
            \() ->
                Expect.equal
                    [ Ansi.Parser.Text "foo", Ansi.Parser.Remainder "\u{001B}[" ]
                    (Ansi.Parser.parse "foo\u{001B}[")
        , test "partial escape sequence with bracket and codes" <|
            \() ->
                Expect.equal
                    [ Ansi.Parser.Text "foo", Ansi.Parser.Remainder "\u{001B}[31;32" ]
                    (Ansi.Parser.parse "foo\u{001B}[31;32")
        , test "invalid escape sequences (no bracket)" <|
            \() ->
                Expect.equal
                    [ Ansi.Parser.Text "foo", Ansi.Parser.Text "lol" ]
                    (Ansi.Parser.parse "foo\u{001B}lol")
        , test "invalid escape sequences (double bracket)" <|
            \() ->
                Expect.equal
                    [ Ansi.Parser.Text "foo", Ansi.Parser.Text "lol" ]
                    (Ansi.Parser.parse "foo\u{001B}[[lol")
        , test "unknown escape sequences" <|
            \() ->
                Expect.equal
                    [ Ansi.Parser.Text "foo", Ansi.Parser.Text "bar" ]
                    (Ansi.Parser.parse "foo\u{001B}[1Zbar")
        ]
