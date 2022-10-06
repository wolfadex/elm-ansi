module Ink exposing (..)

import Ansi
import Ansi.Cursor
import Ansi.Font
import Ansi.String
import Ink.Internal exposing (Attribute(..), Element(..), Layout(..))
import List.Extra
import Terminal.Border exposing (Border)


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
                splitAttrs =
                    splitAttributes attributes
            in
            splitAttrs.before
                ++ content
                ++ splitAttrs.after

        ElContainer attributes children ->
            let
                attrs =
                    splitAttributes attributes

                hasBorder =
                    attrs.border /= Nothing

                renderedChildren =
                    String.join (spacers attrs.layouts)
                        (List.map
                            (\child ->
                                (if hasBorder then
                                    " "

                                 else
                                    ""
                                )
                                    ++ viewHelper child
                            )
                            children
                        )

                lines =
                    String.split "\n" renderedChildren

                widestLine =
                    List.foldl
                        (\line widest -> max (Ansi.String.width line) widest)
                        0
                        lines
            in
            (attrs.before ++ renderedChildren ++ attrs.after)
                |> applyBorder attrs.border widestLine (List.length lines)


applyBorder : Maybe Border -> Int -> Int -> String -> String
applyBorder maybeBorder width height content =
    case maybeBorder of
        Nothing ->
            content

        Just bor ->
            Terminal.Border.draw { width = width + 1, height = height + 2 } bor ++ "\n" ++ content ++ "\n"


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


splitAttributes : List Attribute -> { before : String, after : String, layouts : List Layout, border : Maybe Border }
splitAttributes attributes =
    List.foldr
        (\attr parts ->
            case attr of
                Style b a ->
                    { parts
                        | before = b :: parts.before
                        , after = a :: parts.after
                    }

                Layout l ->
                    { parts | layouts = l :: parts.layouts }

                StyleBorder bor ->
                    { parts | border = Just bor }
        )
        { before = [], after = [], layouts = [], border = Nothing }
        attributes
        |> (\parts ->
                { before = String.concat parts.before
                , after = String.concat parts.after
                , layouts = List.reverse parts.layouts
                , border = parts.border
                }
           )


spacing : Int -> Attribute
spacing dist =
    Layout (Spacing dist)


border : Border -> Attribute
border borderStyle =
    StyleBorder borderStyle
