module Tests exposing (suite)

import Ansi.Color
import Ansi.Font
import Ansi.Internal exposing (EastAsianCharWidth(..))
import Ansi.Parser
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "Assert that east asian width is"
        [ test "FullWidth for" <|
            \() ->
                [ "￠"
                , "￦"
                ]
                    |> List.map Ansi.Internal.eastAsianWidth
                    |> List.all ((==) (Just FullWidth))
                    |> Expect.equal True
                    |> Expect.onFail "Non full width East Asian character"
        ]
