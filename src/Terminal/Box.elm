module Terminal.Box exposing
    ( Box
    , single
    , double
    , singleDouble
    , doubleSingle
    , bold
    , classic
    , rounded
    , custom
    , draw
    )

{-| Styles borrowed from <https://www.npmjs.com/package/cli-boxes>

@docs Box

@docs single
@docs double
@docs singleDouble
@docs doubleSingle
@docs bold
@docs classic
@docs rounded
@docs custom

@docs draw

-}

import Ansi.Cursor


{-| -}
type alias Box =
    { topLeft : String
    , top : String
    , topRight : String
    , right : String
    , bottomRight : String
    , bottom : String
    , bottomLeft : String
    , left : String
    }


{-| A thin box with sharp corners

    ┌────┐
    │    │
    └────┘

-}
single : Box
single =
    { topLeft = "┌"
    , top = "─"
    , topRight = "┐"
    , right = "│"
    , bottomRight = "┘"
    , bottom = "─"
    , bottomLeft = "└"
    , left = "│"
    }


{-| 2 thin, nested boxes with sharp corners

    ╔════╗
    ║    ║
    ╚════╝

-}
double : Box
double =
    { topLeft = "╔"
    , top = "═"
    , topRight = "╗"
    , right = "║"
    , bottomRight = "╝"
    , bottom = "═"
    , bottomLeft = "╚"
    , left = "║"
    }


{-| A thin box with rounded corners

    ╭────╮
    │    │
    ╰────╯

-}
rounded : Box
rounded =
    { topLeft = "╭"
    , top = "─"
    , topRight = "╮"
    , right = "│"
    , bottomRight = "╯"
    , bottom = "─"
    , bottomLeft = "╰"
    , left = "│"
    }


{-| A thick box with sharp corners

    ┏━━━━┓
    ┃    ┃
    ┗━━━━┛

-}
bold : Box
bold =
    { topLeft = "┏"
    , top = "━"
    , topRight = "┓"
    , right = "┃"
    , bottomRight = "┛"
    , bottom = "━"
    , bottomLeft = "┗"
    , left = "┃"
    }


{-| A box with sharp corners, thin on the top and bottom and doubled up on the sides

    ╓────╖
    ║    ║
    ╙────╜

-}
singleDouble : Box
singleDouble =
    { topLeft = "╓"
    , top = "─"
    , topRight = "╖"
    , right = "║"
    , bottomRight = "╜"
    , bottom = "─"
    , bottomLeft = "╙"
    , left = "║"
    }


{-| A box with sharp corners, thin on the sides and doubled on top and bottom

    ╒════╕
    │    │
    ╘════╛

-}
doubleSingle : Box
doubleSingle =
    { topLeft = "╒"
    , top = "═"
    , topRight = "╕"
    , right = "│"
    , bottomRight = "╛"
    , bottom = "═"
    , bottomLeft = "╘"
    , left = "│"
    }


{-| A thin box with plus shaped corners

    +----+
    |    |
    +----+

-}
classic : Box
classic =
    { topLeft = "+"
    , top = "-"
    , topRight = "+"
    , right = "|"
    , bottomRight = "+"
    , bottom = "-"
    , bottomLeft = "+"
    , left = "|"
    }


{-| Design your own box, such as

    •————•
    ∫    ∫
    •————•

This can break layout when you use `Char`s that have a width greater than 1.
E.g. 🌈 is 2 columns wide.

-}
custom :
    { topLeft : Char
    , top : Char
    , topRight : Char
    , right : Char
    , bottomRight : Char
    , bottom : Char
    , bottomLeft : Char
    , left : Char
    }
    -> Box
custom options =
    { topLeft = String.fromChar options.topLeft
    , top = String.fromChar options.top
    , topRight = String.fromChar options.topRight
    , right = String.fromChar options.right
    , bottomRight = String.fromChar options.bottomRight
    , bottom = String.fromChar options.bottom
    , bottomLeft = String.fromChar options.bottomLeft
    , left = String.fromChar options.left
    }


{-| Helps to draw the box for you
-}
draw : { width : Int, height : Int } -> Box -> String
draw dimensions style =
    [ style.topLeft
    , List.repeat (dimensions.width - 2) style.top |> String.concat
    , style.topRight
    , List.foldl
        (\right result ->
            result
                ++ Ansi.Cursor.moveDownBy 1
                ++ Ansi.Cursor.moveBackwardBy 1
                ++ right
        )
        ""
        (List.repeat (dimensions.height - 2) style.right)
    , Ansi.Cursor.moveDownBy 1
    , Ansi.Cursor.moveBackwardBy 1
    , style.bottomRight
    , Ansi.Cursor.moveBackwardBy (dimensions.width - 1)
    , List.repeat (dimensions.width - 2) style.bottom |> String.concat
    , Ansi.Cursor.moveBackwardBy dimensions.width
    , style.bottomLeft
    , Ansi.Cursor.moveBackwardBy 1
    , List.foldl
        (\left result ->
            result
                ++ Ansi.Cursor.moveUpBy 1
                ++ Ansi.Cursor.moveBackwardBy 1
                ++ left
        )
        ""
        (List.repeat (dimensions.height - 2) style.left)
    , Ansi.Cursor.moveUpBy 1
    ]
        |> String.concat
