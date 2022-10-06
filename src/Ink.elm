module Ink exposing (..)

import Ansi
import Ansi.Cursor
import Ansi.Font
import Ink.Internal exposing (Attribute(..), Element(..), Layout(..))
import List.Extra


type alias Element =
    Ink.Internal.Element


type alias Attribute =
    Ink.Internal.Attribute


text : List Attribute -> String -> Element
text =
    ElText


column : List Attribute -> List Element -> Element
column attrs =
    ElContainer (Layout Column :: attrs)


row : List Attribute -> List Element -> Element
row attrs =
    ElContainer (Layout Row :: attrs)


view : Element -> String
view element =
    Ansi.Font.resetAll
        ++ Ansi.clearScreen
        ++ Ansi.Cursor.moveTo { row = 0, column = 0 }
        ++ viewHelper element


viewHelper : Element -> String
viewHelper element =
    case element of
        ElText attributes content ->
            let
                ( before, after, layout ) =
                    splitAttributes attributes
            in
            before ++ content ++ after

        ElContainer attributes children ->
            let
                ( before, after, layout ) =
                    splitAttributes attributes
            in
            before ++ String.join (spacers layout) (List.map viewHelper children) ++ after


spacers : List Layout -> String
spacers styles =
    let
        amount =
            case
                List.Extra.get
                    (\style ->
                        case style of
                            Spacing d ->
                                Just d

                            _ ->
                                Nothing
                    )
                    styles
            of
                Nothing ->
                    0

                Just dist ->
                    dist

        ( symbol, additionalAmount ) =
            case
                List.Extra.get
                    (\style ->
                        case style of
                            Column ->
                                Just ( "\n", 1 )

                            Row ->
                                Just ( " ", 0 )

                            _ ->
                                Nothing
                    )
                    styles
            of
                Nothing ->
                    ( " ", 0 )

                Just char ->
                    char
    in
    String.repeat
        (amount + additionalAmount)
        symbol


splitAttributes : List Attribute -> ( String, String, List Layout )
splitAttributes attributes =
    List.foldr
        (\attr ( bs, as_, lay ) ->
            case attr of
                Style b a ->
                    ( b :: bs, a :: as_, lay )

                Layout l ->
                    ( bs, as_, l :: lay )
        )
        ( [], [], [] )
        attributes
        |> (\( a, b, l ) -> ( String.concat a, String.concat b, List.reverse l ))


spacing : Int -> Attribute
spacing dist =
    Layout (Spacing dist)
