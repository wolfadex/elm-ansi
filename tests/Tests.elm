module Tests exposing (suite)

import Ansi.Internal exposing (EastAsianCharWidth(..))
import Ansi.String
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "Assert that"
        [ test "east asian width is FullWidth for" <|
            \() ->
                [ "￠"
                , "￦"
                ]
                    |> List.map Ansi.Internal.eastAsianWidth
                    |> List.all ((==) (Just FullWidth))
                    |> Expect.equal True
                    |> Expect.onFail "Non full width East Asian character"
        , test "Ansi.String.width is 1 not 2 for ▪" <|
            \() ->
                Ansi.String.width "▪"
                    |> Expect.equal 1
        ]
