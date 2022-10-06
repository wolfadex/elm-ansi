module Ink.Internal exposing (..)

import Terminal.Border exposing (Border)


type Attribute
    = Style String String
    | Layout Layout
    | StyleBorder Border


type Layout
    = Spacing Int
    | Column
    | Row


type Element
    = ElText (List Attribute) String
    | ElContainer (List Attribute) (List Element)



-- | ElRow (List Attribute) (List Element)
