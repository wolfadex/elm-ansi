module Ink.Layout exposing
    ( padding
    , paddingEach
    , spacing
    , border
    , Length, exact, fill, height, shrink, width
    )

{-| Attributes that modifying the layout of your content.

@docs padding
@docs paddingEach

@docs spacing

@docs border

-}

import Ansi.Box exposing (Box)
import Ink.Internal exposing (Attribute(..), Length(..))


{-| Add white space between the children of a container. For a column this adds a new line between children and for rows it adds a columns between them.

    -- Before: HelloWorld
    Ink.row []
        [ Ink.text [] "Hello"
        , Ink.text [] "World"
        ]

    -- After: Hello World
    Ink.row [ Ink.Layout.spacing 1 ]
        [ Ink.text [] "Hello"
        , Ink.text [] "World"
        ]

-}
spacing : Int -> Attribute
spacing =
    Spacing


{-| Adds the specified number of columns and lines around all sides of your content.

    -- Before
    Ink.text [] "Hello World"

```sh
Hello World
```

    -- After
    Ink.text [ Ink.Layout.padding 1 ] "Hello World"

```sh

 Hello World
```

-}
padding : Int -> Attribute
padding size =
    Padding { top = size, bottom = size, left = size, right = size }


{-| Adds the specified number of columns and lines on each side of your content.
-}
paddingEach : { top : Int, bottom : Int, left : Int, right : Int } -> Attribute
paddingEach sizes =
    Padding sizes


{-| Draws the specified box around your content. See `Ansi.Box` for common patterns or for creating your own.

    -- Before
    Ink.text [] "Hello World"

```sh
Hello World
```

    -- After
    Ink.text [ Ink.Layout.border Ansi.Box.single ] "Hello World"

```sh
┌───────────┐
│Hello World│
└───────────┘
```

-}
border : Box -> Attribute
border borderStyle =
    BorderStyle borderStyle


type alias Length =
    Ink.Internal.Length


width : Length -> Attribute
width =
    Width


height : Length -> Attribute
height =
    Height


fill : Length
fill =
    Fill


shrink : Length
shrink =
    Shrink


exact : Int -> Length
exact =
    Exact
