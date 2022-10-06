port module Main exposing (main)

-- import Ansi.Border

import Ansi
import Ansi.Border
import Ansi.Color exposing (Location(..))
import Ansi.Cursor
import Ansi.Font
import Regex exposing (Regex)
import Terminal exposing (Element)
import Terminal.Text


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
      -- GENERIC
      -- , [ Ansi.clearScreen
      --   , Ansi.Cursor.moveTo { row = 4, column = 1 }
      --   , Ansi.Border.draw { width = 40, height = 4 } Ansi.Border.single
      --   , Ansi.Cursor.moveTo { row = 6, column = 2 }
      --   , Ansi.Font.resetAll
      --   , "Hello, "
      --   , Ansi.Font.color Ansi.Color.green
      --   , Ansi.Font.bold
      --   , model.input
      --   , Ansi.Font.resetAll
      --   , Ansi.Cursor.moveTo { row = 5, column = 2 }
      --   , "Enter your name: " ++ model.input
      --   ]
      --     |> String.concat
      --     |> stdout
      -- elm-land POC
      -- , [ Ansi.clearScreen
      --   , Ansi.Font.resetAll
      --   , Ansi.Cursor.moveTo { row = 0, column = 0 }
      --   , "🌈  Welcome to Elm Land! " ++ Ansi.Font.faint ++ "1.2.3" ++ Ansi.Font.resetBoldFaint
      --   , Ansi.Font.color Ansi.Color.green ++ "    " ++ String.repeat (24 + 3) "⎺"
      --   , Ansi.Color.reset Foreground
      --   ]
      --     ++ subcommandList
      --     ++ [ ""
      --        , "    Want to learn more? Visit " ++ Ansi.Font.color Ansi.Color.cyan ++ "https://elm.land/guide"
      --        , Ansi.Font.resetAll
      --        ]
      --     |> String.join "\n"
      --     |> stdout
      -- elm-land, with functions
    , Terminal.column [ Terminal.spacing 1 ]
        (Terminal.column []
            [ Terminal.row [ Terminal.spacing 1 ]
                [ Terminal.text [] "🌈  Welcome to Elm Land!"
                , Terminal.text [ Terminal.Text.faint ] "1.2.3"
                ]
            , Terminal.text [ Terminal.Text.color Ansi.Color.green ]
                ("    " ++ String.repeat (24 + 3) "⎺")
            ]
            :: subcommandList
            ++ [ Terminal.row [ Terminal.spacing 1 ]
                    [ Terminal.text [] "    Want to learn more? Visit"
                    , Terminal.text [ Terminal.Text.color Ansi.Color.cyan ] "https://elm.land/guide"
                    ]
               , Terminal.text [] "👩🏽\u{200D}🔧"
               , Terminal.text [] "😀"
               ]
        )
        |> Terminal.view
        |> stdout
    )


subcommandList : List Element
subcommandList =
    [ Terminal.column [ Terminal.spacing 1 ]
        [ Terminal.text [] "    Here are the available commands:"
        , Terminal.column []
            [ elmLandCommand "✨" "init <folder-name>" "...... create a new project"
            , elmLandCommand "🚀" "server" "................ run a local dev server"
            , elmLandCommand "📦" "build" ".......... build your app for production"
            , elmLandCommand "📄" "add page <url>" "................ add a new page"
            , elmLandCommand "📑" "add layout <name>" "........... add a new layout"
            , elmLandCommand "🔧" "customize <name>" ".. customize a default module"
            ]
        ]
    ]


elmLandCommand : String -> String -> String -> Element
elmLandCommand emoji cmd desc =
    Terminal.row [ Terminal.spacing 1 ]
        [ Terminal.text [] ("    " ++ emoji ++ " elm-land")
        , Terminal.text [ Terminal.Text.color pink ] cmd
        , Terminal.text [] desc
        ]


pink : Ansi.Color.Color
pink =
    Ansi.Color.rgb { red = 250, green = 20, blue = 100 }
