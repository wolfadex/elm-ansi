module Ink.Internal exposing (..)

import Terminal.Box exposing (Box)


type Attribute
    = Style String String
    | Layout Layout
    | StyleBorder Box
    | Padding { top : Int, bottom : Int, left : Int, right : Int }


type Layout
    = Spacing Int
    | Column
    | Row


type Element
    = ElText (List Attribute) String
    | ElContainer (List Attribute) (List Element)
