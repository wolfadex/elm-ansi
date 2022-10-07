port module InkExample exposing (main)

import Ansi
import Ansi.Color exposing (Location(..))
import Ansi.Cursor
import Ansi.Font
import Ansi.String
import Ink exposing (Element)
import Ink.Text
import Terminal.Border


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
        title =
            Ink.row [ Ink.spacing 1 ]
                [ Ink.text [] "Welcome to Elm Land!"
                , Ink.text [ Ink.Text.faint ] "1.2.3"
                ]

        titleWidth =
            Ansi.String.width (Ink.view title)

        welcomePadding =
            Ansi.String.width "🌈  "
      in
      Ink.column
        [-- Ink.border Terminal.Border.single
        ]
        (Ink.column []
            [ Ink.row [ Ink.spacing 1 ]
                [ Ink.text [] "🌈  Welcome to Elm Land!"
                , Ink.text [ Ink.Text.faint ] "1.2.3"
                ]
            , Ink.text
                [ Ink.Text.color Ansi.Color.green
                , Ink.paddingEach { top = 0, bottom = 0, left = welcomePadding, right = 0 }
                ]
                (String.repeat titleWidth "⎺")
            ]
            :: subcommandList welcomePadding
            ++ [ Ink.row
                    [ Ink.spacing 1
                    , Ink.paddingEach
                        { top = 1
                        , bottom = 0
                        , left = welcomePadding
                        , right = 0
                        }
                    ]
                    [ Ink.text [] "Want to learn more? Visit"
                    , Ink.text [ Ink.Text.color Ansi.Color.cyan ] "https://elm.land/guide"
                    ]
               ]
        )
        |> Ink.view
        |> stdout
    )


subcommandList : Int -> List Element
subcommandList leftPadding =
    [ Ink.column
        [ Ink.spacing 1
        , Ink.paddingEach { top = 0, bottom = 0, left = leftPadding, right = 0 }

        -- , Ink.border Terminal.Border.double
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
    Ink.row [ Ink.spacing 1 ]
        [ Ink.text [] (emoji ++ " elm-land")
        , Ink.text [ Ink.Text.color pink ] cmd
        , Ink.text [] desc
        ]


pink : Ansi.Color.Color
pink =
    Ansi.Color.rgb { red = 250, green = 20, blue = 100 }
