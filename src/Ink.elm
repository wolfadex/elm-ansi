module Ink exposing (..)

{-| When building for the terminal we have 3 layers of abstraction. This package represents the top most layer. Instead of directly controlling the placement of each character and manually adding white space you instead talk about `Element`s, layout, and style.
-}

import Ansi
import Ansi.Cursor
import Ansi.Font
import Ansi.String
import Ink.Internal exposing (Attribute(..), Element(..), Layout(..))
import List.Extra
import Terminal.Box exposing (Box)


{-| Much like [mdgriffith/elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/), Ink is made up of a few core `Element`s. In this case you have Text and Containers, the 2nd of these hold 0 or more children and does a lot of the layout.
-}
type alias Element =
    Ink.Internal.Element


{-| Much like working with `Html`, our `Element`s have a way of applying layout and styling attributes.
-}
type alias Attribute =
    Ink.Internal.Attribute


{-| For displaying text in the terminal.
-}
text : List Attribute -> String -> Element
text =
    ElText


{-| For grouping together multiple children in a vertical layout.
-}
column : List Attribute -> List Element -> Element
column attrs =
    ElContainer (Layout Column :: attrs)


{-| For grouping together multiple children in a horizontal layout.
-}
row : List Attribute -> List Element -> Element
row attrs =
    ElContainer (Layout Row :: attrs)


{-| Most used for turning your `Element`s into a `String` to be forwarded on to your terminal.
-}
toString : Element -> String
toString element =
    Ansi.Font.resetAll
        ++ Ansi.Cursor.hide
        ++ Ansi.clearScreen
        ++ Ansi.Cursor.moveTo { row = 0, column = 0 }
        ++ viewHelper element



---- INTERNAL ----


viewHelper : Element -> String
viewHelper element =
    case element of
        ElText attributes content ->
            let
                attrs : Attrs
                attrs =
                    splitAttributes attributes
            in
            (attrs.before ++ content ++ attrs.after)
                |> applyPadding attrs.padding
                |> applyBorder attrs.border

        ElContainer attributes children ->
            let
                attrs : Attrs
                attrs =
                    splitAttributes attributes

                renderedChildren : String
                renderedChildren =
                    String.join (spacers attrs.layouts)
                        (List.map viewHelper children)
            in
            (attrs.before ++ renderedChildren ++ attrs.after)
                |> applyPadding attrs.padding
                |> applyBorder attrs.border


applyPadding : Maybe { top : Int, bottom : Int, left : Int, right : Int } -> String -> String
applyPadding maybePadding content =
    case maybePadding of
        Nothing ->
            content

        Just pad ->
            let
                leftPadding : String
                leftPadding =
                    String.repeat pad.left " "

                widest : Int
                widest =
                    widestLine content
            in
            (String.repeat pad.top "\n" ++ content ++ String.repeat pad.bottom "\n")
                |> String.split "\n"
                |> List.map (\line -> leftPadding ++ Ansi.String.padRight (pad.right + widest) " " line)
                |> String.join "\n"


applyBorder : Maybe Box -> String -> String
applyBorder maybeBorder content =
    case maybeBorder of
        Nothing ->
            content

        Just bor ->
            let
                widest : Int
                widest =
                    widestLine content
            in
            (bor.topLeft ++ String.repeat widest bor.top ++ bor.topRight ++ "\n")
                ++ (content
                        |> String.split "\n"
                        |> List.map (\line -> bor.left ++ Ansi.String.padRight widest " " line ++ bor.right)
                        |> String.join "\n"
                   )
                ++ "\n"
                ++ (bor.bottomLeft ++ String.repeat widest bor.bottom ++ bor.bottomRight)


widestLine : String -> Int
widestLine str =
    List.foldl
        (\line widest -> max (Ansi.String.width line) widest)
        0
        (String.split "\n" (Ansi.String.strip str))


spacers : List Layout -> String
spacers styles =
    let
        amount : Int
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


type alias Attrs =
    { before : String
    , after : String
    , layouts : List Layout
    , border : Maybe Box
    , padding : Maybe { top : Int, bottom : Int, left : Int, right : Int }
    }


defaultAttrs :
    { before : List String
    , after : List String
    , layouts : List Layout
    , border : Maybe Box
    , padding : Maybe { top : Int, bottom : Int, left : Int, right : Int }
    }
defaultAttrs =
    { before = []
    , after = []
    , layouts = []
    , border = Nothing
    , padding = Nothing
    }


splitAttributes : List Attribute -> Attrs
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

                Padding pad ->
                    { parts | padding = Just pad }
        )
        defaultAttrs
        attributes
        |> (\parts ->
                { before = String.concat parts.before
                , after = String.concat parts.after
                , layouts = List.reverse parts.layouts
                , border = parts.border
                , padding = parts.padding
                }
           )
