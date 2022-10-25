module List.Extra exposing (get)


get : (a -> Maybe b) -> List a -> Maybe b
get predicate list =
    case list of
        [] ->
            Nothing

        next :: rest ->
            case predicate next of
                Just b ->
                    Just b

                Nothing ->
                    get predicate rest
