module Ink exposing
    ( Element
    , Attribute
    , text
    , column
    , row
    , toString
    )

{-| When building for the terminal we have 3 layers of abstraction. This package represents the top most layer. Instead of directly controlling the placement of each character and manually adding white space you instead talk about `Element`s, layout, and style.

@docs Element
@docs Attribute

@docs text
@docs column
@docs row
@docs toString

-}

import Ansi
import Ansi.Cursor
import Ansi.Font
import Ansi.String
import Ink.Internal exposing (Attribute(..), Element(..))
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
column =
    ElColumn


{-| For grouping together multiple children in a horizontal layout.
-}
row : List Attribute -> List Element -> Element
row =
    ElRow


{-| Most used for turning your `Element`s into a `String` to be forwarded on to your terminal.
-}
toString : Element -> String
toString element =
    Ansi.Font.resetAll
        ++ Ansi.Cursor.hide
        ++ Ansi.clearScreen
        ++ Ansi.Cursor.moveTo { row = 0, column = 0 }
        ++ viewHelper 0 element



---- INTERNAL ----


viewHelper : Int -> Element -> String
viewHelper extraPadding element =
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

        ElRow attributes children ->
            let
                attrs : Attrs
                attrs =
                    splitAttributes attributes

                spacingStr =
                    String.repeat attrs.spacing " "

                renderedChildren : String
                renderedChildren =
                    List.foldl
                        (\child ( result, xPad, index ) ->
                            let
                                renderedChild : String
                                renderedChild =
                                    viewHelper xPad child
                                        |> (\ren ->
                                                if index > 0 then
                                                    ren
                                                        |> String.split "\n"
                                                        |> List.map ((++) spacingStr)
                                                        |> String.join "\n"

                                                else
                                                    ren
                                           )

                                tallest =
                                    max
                                        (List.length (String.split "\n" result))
                                        (List.length (String.split "\n" renderedChild))

                                widestChildLine : Int
                                widestChildLine =
                                    widestLine renderedChild

                                leftSide =
                                    String.split "\n" (padHeight tallest result)

                                rightSide =
                                    String.split "\n" (padHeight tallest renderedChild)
                            in
                            ( List.map2 (++)
                                leftSide
                                rightSide
                                |> String.join "\n"
                            , widestChildLine
                            , index + 1
                            )
                        )
                        ( "", extraPadding, 0 )
                        children
                        |> (\( ren, _, _ ) -> ren)
            in
            (attrs.before ++ renderedChildren ++ attrs.after)
                |> applyPadding attrs.padding
                |> applyBorder attrs.border

        ElColumn attributes children ->
            let
                attrs : Attrs
                attrs =
                    splitAttributes attributes

                renderedChildren : String
                renderedChildren =
                    String.join (String.repeat (attrs.spacing + 1) "\n")
                        (List.map (viewHelper extraPadding) children)
            in
            (attrs.before ++ renderedChildren ++ attrs.after)
                |> applyPadding attrs.padding
                |> applyBorder attrs.border


padHeight : Int -> String -> String
padHeight desiredHeight str =
    let
        widest : Int
        widest =
            widestLine str

        lines : List String
        lines =
            String.split "\n" str

        linesToAdd : List String
        linesToAdd =
            List.repeat
                (desiredHeight - List.length lines)
                (String.repeat widest " ")
    in
    (lines ++ linesToAdd)
        |> String.join "\n"


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


type alias Attrs =
    { before : String
    , after : String
    , spacing : Int
    , border : Maybe Box
    , padding : Maybe { top : Int, bottom : Int, left : Int, right : Int }
    }


defaultAttrs :
    { before : List String
    , after : List String
    , spacing : Int
    , border : Maybe Box
    , padding : Maybe { top : Int, bottom : Int, left : Int, right : Int }
    }
defaultAttrs =
    { before = []
    , after = []
    , spacing = 0
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

                Spacing s ->
                    { parts | spacing = s }

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
                , spacing = parts.spacing
                , border = parts.border
                , padding = parts.padding
                }
           )
