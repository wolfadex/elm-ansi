module Ansi.Decode exposing
    ( Key
    , decodeKey
    , getCommand
    , isDownArrow
    , isLeftArrow
    , isRightArrow
    , isUpArrow
    )

{-|

@docs Key
@docs decodeKey
@docs getCommand
@docs isDownArrow
@docs isLeftArrow
@docs isRightArrow
@docs isUpArrow

-}

import Ansi.Internal
import Json.Decode exposing (Decoder)


{-| If the input is an ansi command, return the command portion, with the escape code removed.
-}
getCommand : String -> Maybe String
getCommand str =
    if String.startsWith Ansi.Internal.esc str then
        Just (String.dropLeft (String.length Ansi.Internal.esc) str)

    else
        Nothing


{-| -}
isUpArrow : String -> Bool
isUpArrow str =
    case getCommand str of
        Just "A" ->
            True

        _ ->
            False


{-| -}
isDownArrow : String -> Bool
isDownArrow str =
    case getCommand str of
        Just "B" ->
            True

        _ ->
            False


{-| -}
isRightArrow : String -> Bool
isRightArrow str =
    case getCommand str of
        Just "C" ->
            True

        _ ->
            False


{-| -}
isLeftArrow : String -> Bool
isLeftArrow str =
    case getCommand str of
        Just "D" ->
            True

        _ ->
            False


{-| -}
type alias Key =
    { code : Maybe String
    , ctrl : Bool
    , meta : Bool
    , name : String
    , sequence : String
    , shift : Bool
    }


{-| You can configure Node to listen for key events, this will parse those into a nice record.
-}
decodeKey : Decoder Key
decodeKey =
    Json.Decode.map6 Key
        (Json.Decode.maybe (Json.Decode.field "code" Json.Decode.string))
        (Json.Decode.field "ctrl" Json.Decode.bool)
        (Json.Decode.field "meta" Json.Decode.bool)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "sequence" Json.Decode.string)
        (Json.Decode.field "shift" Json.Decode.bool)
