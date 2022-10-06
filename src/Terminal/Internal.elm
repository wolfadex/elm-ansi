module Terminal.Internal exposing (..)


type Attribute
    = Style String String
    | Layout Layout


type Layout
    = Spacing Int
    | Column
    | Row


type Element
    = ElText (List Attribute) String
    | ElContainer (List Attribute) (List Element)



-- | ElRow (List Attribute) (List Element)
