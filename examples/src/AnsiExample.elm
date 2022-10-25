port module AnsiExample exposing (main)

import Ansi
import Ansi.Color exposing (Location(..))
import Ansi.Cursor
import Ansi.Font


main : Program Int Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { input : String
    }


init : Int -> ( Model, Cmd Msg )
init _ =
    render
        { input = ""
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    stdin Stdin


port stdin : (String -> msg) -> Sub msg


port stdout : String -> Cmd msg


type Msg
    = Stdin String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Stdin str ->
            { model
                | input =
                    -- Delete or Backspace (not sure about forward delete)
                    if str == "\u{007F}" || str == "\u{0008}" then
                        String.dropRight 1 model.input

                    else
                        model.input ++ str
            }
                |> render


render : Model -> ( Model, Cmd Msg )
render model =
    ( model
    , [ Ansi.Font.resetAll
      , Ansi.clearScreen
      , Ansi.Cursor.moveTo { row = 1, column = 1 }
      , "🌈  Welcome to Elm Land! " ++ Ansi.Font.faint ++ "1.2.3" ++ Ansi.Font.resetBoldFaint
      , Ansi.Font.color Ansi.Color.green ++ "    " ++ String.repeat (24 + 3) "⎺" ++ Ansi.Color.reset Foreground
      , ""
      ]
        ++ subcommandList
        ++ [ ""
           , "    Want to learn more? Visit " ++ Ansi.Font.color Ansi.Color.cyan ++ "https://elm.land/guide" ++ Ansi.Color.reset Foreground
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
    , Ansi.Font.color pink ++ cmd ++ Ansi.Color.reset Foreground
    , desc
    ]
        |> String.join " "


pink : Ansi.Color.Color
pink =
    Ansi.Color.rgb { red = 250, green = 20, blue = 100 }
