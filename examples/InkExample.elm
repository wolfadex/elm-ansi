port module InkExample exposing (main)

import Ansi.Color exposing (Location(..))
import Ansi.String
import Ink exposing (Element)
import Ink.Layout
import Ink.Style
import Terminal.Box


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
    , let
        welcomeText : String
        welcomeText =
            "Welcome to Elm Land!"

        title : Element
        title =
            Ink.row [ Ink.Layout.spacing 1 ]
                [ Ink.text [] welcomeText
                , Ink.text [ Ink.Style.faint ] "1.2.3"
                ]

        titleWidth : Int
        titleWidth =
            Ansi.String.width (Ink.toString title)
      in
      Ink.row [ Ink.Layout.border Terminal.Box.single ]
        [ Ink.text [] "🌈  "
        , Ink.column []
            ([ Ink.row [ Ink.Layout.spacing 1 ]
                [ Ink.text [] welcomeText, Ink.text [ Ink.Style.faint ] "1.2.3" ]
             , Ink.text [ Ink.Style.color Ansi.Color.green ] (String.repeat titleWidth "⎺")
             ]
                ++ subcommandList
                ++ [ Ink.row
                        [ Ink.Layout.spacing 1
                        , Ink.Layout.paddingEach
                            { top = 1
                            , bottom = 0
                            , left = 0
                            , right = 0
                            }
                        ]
                        [ Ink.text [] "Want to learn more? Visit"
                        , Ink.text [ Ink.Style.color Ansi.Color.cyan ] "https://elm.land/guide"
                        ]
                   ]
            )
        ]
        |> Ink.toString
        |> stdout
    )


subcommandList : List Element
subcommandList =
    [ Ink.column
        [ Ink.Layout.spacing 1
        ]
        [ Ink.text [] "Here are the available commands:"
        , Ink.column []
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
    Ink.row [ Ink.Layout.spacing 1 ]
        [ Ink.text [] (emoji ++ " elm-land")
        , Ink.text [ Ink.Style.color pink ] cmd
        , Ink.text [] desc
        ]


pink : Ansi.Color.Color
pink =
    Ansi.Color.rgb { red = 250, green = 20, blue = 100 }
