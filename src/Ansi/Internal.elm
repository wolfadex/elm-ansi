module Ansi.Internal exposing (..)


toAnsiCommand : String -> String
toAnsiCommand str =
    "\u{001B}[" ++ str
