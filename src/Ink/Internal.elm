module Ink.Internal exposing (..)

import Terminal.Border exposing (Border)


type Attribute
    = Style String String
    | Layout Layout
    | StyleBorder Border
    | Padding { top : Int, bottom : Int, left : Int, right : Int }


type Layout
    = Spacing Int
    | Column
    | Row


type Element
    = ElText (List Attribute) String
    | ElContainer (List Attribute) (List Element)
