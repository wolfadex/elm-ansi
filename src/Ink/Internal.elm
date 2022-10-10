module Ink.Internal exposing (..)

import Terminal.Box exposing (Box)


type Attribute
    = Style String String
    | Spacing Int
    | Padding { top : Int, bottom : Int, left : Int, right : Int }
    | BorderStyle Box
    | BorderFontStyle String String


type Element
    = ElText (List Attribute) String
    | ElRow (List Attribute) (List Element)
    | ElColumn (List Attribute) (List Element)
