port module AnsiExample exposing (main)

import Ansi
import Ansi.Color exposing (Location(..))
import Ansi.Cursor
import Ansi.Font


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    ()


init : () -> ( Model, Cmd Msg )
init () =
    render ()


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


port stdout : String -> Cmd msg


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update _ _ =
    render ()


render : Model -> ( Model, Cmd Msg )
render model =
    ( model
    , [ Ansi.Font.resetAll
      , Ansi.clearScreen
      , Ansi.Cursor.moveTo { row = 1, column = 1 }
      , "🌈  Welcome to Elm Land! " ++ Ansi.faint "1.2.3"
      , Ansi.fontColor Ansi.Color.green ("    " ++ String.repeat (24 + 3) "⎺")
      , ""
      ]
        ++ subcommandList
        ++ [ ""
           , "    Want to learn more? Visit " ++ Ansi.fontColor Ansi.Color.cyan "https://elm.land/guide"
           ]
        |> String.join "\n"
        |> stdout
    )


subcommandList : List String
subcommandList =
    [ "    Here are the available commands:"
    , ""
    , elmLandCommand "✨" "init <folder-name>" "...... create a new project"
    , elmLandCommand "🚀" "server" "................ run a local dev server"
    , elmLandCommand "📦" "build" ".......... build your app for production"
    , elmLandCommand "📄" "add page <url>" "................ add a new page"
    , elmLandCommand "📑" "add layout <name>" "........... add a new layout"
    , elmLandCommand "🔧" "customize <name>" ".. customize a default module"
    ]


elmLandCommand : String -> String -> String -> String
elmLandCommand emoji cmd desc =
    [ "    " ++ emoji ++ " elm-land"
    , Ansi.fontColor pink cmd
    , desc
    ]
        |> String.join " "


pink : Ansi.Color.Color
pink =
    Ansi.Color.rgb { red = 250, green = 20, blue = 100 }
