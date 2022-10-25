module Ink.Internal exposing (Attribute(..), Element(..), Length(..))

import Terminal.Box exposing (Box)


type Attribute
    = Style String String
    | Spacing Int
    | Width Length
    | Height Length
    | Padding { top : Int, bottom : Int, left : Int, right : Int }
    | BorderStyle Box
    | BorderFontStyle String String


type Element
    = ElText (List Attribute) String
    | ElRow (List Attribute) (List Element)
    | ElColumn (List Attribute) (List Element)
    | ElLineHorizontal (List Attribute) String
    | ElLineVertical (List Attribute) String


type Length
    = Fill
    | Shrink
    | Exact Int
