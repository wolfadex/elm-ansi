module Ink exposing
    ( Element
    , Attribute
    , text
    , column
    , row
    , toString
    , Config, lineHorizontal, lineVertical
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
import Ansi.Box exposing (Box)
import Ansi.Color
import Ansi.Cursor
import Ansi.Font
import Ansi.String
import Ink.Internal exposing (Attribute(..), Element(..), Length(..))


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


lineHorizontal : List Attribute -> String -> Element
lineHorizontal =
    ElLineHorizontal


lineVertical : List Attribute -> String -> Element
lineVertical =
    ElLineVertical


type alias Config =
    { rows : Int
    , columns : Int
    }


{-| Most used for turning your `Element`s into a `String` to be forwarded on to your terminal.
-}
toString : Config -> Element -> String
toString config element =
    Ansi.Font.resetAll
        ++ Ansi.Cursor.hide
        ++ Ansi.eraseScreen
        ++ Ansi.Cursor.moveTo { row = 1, column = 1 }
        ++ viewHelper
            { column = 0
            , row = 0
            , width = config.columns
            , height = config.rows
            }
            0
            element



---- INTERNAL ----


type alias Options =
    { column : Int
    , row : Int
    , width : Int
    , height : Int
    }


viewHelper : Options -> Int -> Element -> String
viewHelper opts extraPadding element =
    case element of
        ElText attributes content ->
            let
                attrs : Attrs
                attrs =
                    splitAttributes attributes
            in
            (attrs.before ++ content ++ attrs.after)
                |> applyPadding opts attrs
                |> applyBorder attrs

        ElLineHorizontal attributes content ->
            let
                attrs : Attrs
                attrs =
                    splitAttributes attributes

                drawWidth : Int
                drawWidth =
                    case attrs.width of
                        Fill ->
                            opts.width

                        Exact l ->
                            l

                        Shrink ->
                            0
                                |> (\w ->
                                        if attrs.border /= Nothing then
                                            max 0 (w - 2)

                                        else
                                            w
                                   )
                                |> (\w ->
                                        case attrs.padding of
                                            Nothing ->
                                                w

                                            Just pad ->
                                                max 0 (w - pad.left - pad.right)
                                   )
            in
            (attrs.before ++ Ansi.String.padRight drawWidth content "" ++ attrs.after)
                |> applyPadding opts attrs
                |> applyBorder attrs

        ElLineVertical attributes content ->
            let
                attrs : Attrs
                attrs =
                    splitAttributes attributes
            in
            (attrs.before ++ content ++ attrs.after)
                |> applyPadding opts attrs
                |> applyBorder attrs

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
                                    viewHelper opts xPad child
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
                |> applyPadding opts attrs
                |> applyBorder attrs

        ElColumn attributes children ->
            let
                attrs : Attrs
                attrs =
                    splitAttributes attributes

                renderedChildren : String
                renderedChildren =
                    children
                        |> List.map
                            (viewHelper
                                { column = opts.column
                                , row = opts.row
                                , width = opts.width
                                , height = opts.height
                                }
                                extraPadding
                            )
                        |> String.join (String.repeat (attrs.spacing + 1) "\n")
            in
            (attrs.before ++ renderedChildren ++ attrs.after)
                |> applyPadding opts attrs
                |> applyBorder attrs


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


applyPadding : Options -> Attrs -> String -> String
applyPadding opts attrs content =
    case attrs.padding of
        Nothing ->
            content

        Just pad ->
            let
                leftPadding : String
                leftPadding =
                    String.repeat pad.left " "

                hasBorder : Bool
                hasBorder =
                    attrs.border /= Nothing

                widest : Int
                widest =
                    widestLine content
                        |> min opts.width
                        |> (\w ->
                                if hasBorder then
                                    w - 2

                                else
                                    w
                           )
            in
            (String.repeat pad.top "\n" ++ content ++ String.repeat pad.bottom "\n")
                |> String.split "\n"
                |> List.map (\line -> leftPadding ++ Ansi.String.padRight (pad.right + widest) " " line)
                |> String.join "\n"


applyBorder : Attrs -> String -> String
applyBorder attrs content =
    case attrs.border of
        Nothing ->
            content

        Just bor ->
            let
                widest : Int
                widest =
                    widestLine content

                wrapBorderStyle : String -> String
                wrapBorderStyle str =
                    attrs.borderBefore ++ str ++ attrs.borderAfter
            in
            (wrapBorderStyle (bor.topLeft ++ String.repeat widest bor.top ++ bor.topRight) ++ "\n")
                ++ (content
                        |> String.split "\n"
                        |> List.map
                            (\line ->
                                wrapBorderStyle bor.left
                                    ++ Ansi.String.padRight widest " " line
                                    ++ wrapBorderStyle bor.right
                            )
                        |> String.join "\n"
                   )
                ++ "\n"
                ++ wrapBorderStyle (bor.bottomLeft ++ String.repeat widest bor.bottom ++ bor.bottomRight)


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
    , width : Length
    , height : Length
    , padding : Maybe { top : Int, bottom : Int, left : Int, right : Int }
    , border : Maybe Box
    , borderBefore : String
    , borderAfter : String
    }


defaultAttrs :
    { before : List String
    , after : List String
    , spacing : Int
    , width : Length
    , height : Length
    , padding : Maybe { top : Int, bottom : Int, left : Int, right : Int }
    , border : Maybe Box
    , borderBefore : List String
    , borderAfter : List String
    }
defaultAttrs =
    { before = []
    , after = []
    , spacing = 0
    , width = Shrink
    , height = Shrink
    , border = Nothing
    , padding = Nothing
    , borderBefore = []
    , borderAfter = []
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

                Width l ->
                    { parts | width = l }

                Height l ->
                    { parts | height = l }

                Padding pad ->
                    { parts | padding = Just pad }

                BorderStyle bor ->
                    { parts | border = Just bor }

                BorderFontStyle b a ->
                    { parts
                        | borderBefore = b :: parts.borderBefore
                        , borderAfter = a :: parts.borderAfter
                    }
        )
        defaultAttrs
        attributes
        |> (\parts ->
                { before = String.concat parts.before
                , after = String.concat parts.after
                , spacing = parts.spacing
                , width = parts.width
                , height = parts.height
                , padding = parts.padding
                , border = parts.border
                , borderBefore = String.concat parts.borderBefore
                , borderAfter = String.concat parts.borderAfter
                }
           )
