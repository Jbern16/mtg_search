import Effects exposing (Never, Effects)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json
import Task
import StartApp


--MODEL

type alias Model =
    { name : String
    , cardUrl : String
    }

init : String -> (Model, Effects Action)
init name =
  ( Model name "About Face"
  , getCardInfo name)


--UPDATE

type Action
  = RequestCard
  | NewCard (Maybe String)

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    RequestCard ->
      ( model
      , getCardInfo model.name
      )

    NewCard maybeUrl ->
      ( Model model.name (Maybe.withDefault model.cardUrl maybeUrl)
      , Effects.none
      )
getCardInfo : String -> Effects Action
getCardInfo name =
  Http.get decodeCardUrl (nameUrl name)
    |> Task.toMaybe
    |> Task.map NewCard
    |> Effects.task

nameUrl : String -> String
nameUrl name =
  Http.url "https://api.deckbrew.com/mtg/cards"
    [ ("name" , name ) ]


decodeCardUrl : Json.Decoder String
decodeCardUrl =
  Json.at ["name"] Json.string

app =
  StartApp.start
    { init = init "About Face"
    , update = update
    , view = view
    , inputs = []
    }

main =
  app.html

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


view address model =
  div [ ]
  [ h2 [ ] [ text model.name]
  ,  div [ model.cardUrl ] []
  , button [ onClick address RequestCard ] [ text "Find Card"]
  ]
