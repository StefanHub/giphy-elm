module MainBonus exposing (Model, Msg(..), debounce, init, main, searchBar, searchGiphys, subscriptions, to2DigitString, toClock, update, view, viewDetail, viewError, viewList, viewListItem, viewListItems)

import Control exposing (..)
import Control.Debounce exposing (..)
import Date exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import JsonDecode exposing (..)
import Task exposing (..)
import Time exposing (..)
import Util exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions

        --always Sub.none
        }



-- MODEL


type alias Model =
    { query : String
    , error : Maybe String
    , debounceState : Control.State Msg
    , data : List GiphyData
    , selected : Maybe GiphyData
    , time : Time
    }



-- initial model


init : ( Model, Cmd Msg )
init =
    ( { query = ""
      , error = Nothing
      , debounceState = Control.initialState
      , data = []
      , selected = Maybe.Nothing
      , time = 0
      }
    , Cmd.batch [ Util.perform (NewSearch "minions"), Task.perform NewTime Time.now ]
      --perform (NewSearch "minions")
      --Cmd.none
    )



-- UPDATE


type Msg
    = NewSearch String
    | Debounce (Control Msg)
    | NewGiphys (Result Error GiphyResult)
    | GiphySelect GiphyData
    | NewTime Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewSearch query ->
            ( { model | query = query }, searchGiphys NewGiphys query )

        Debounce control ->
            Control.update (\newDebounceState -> { model | debounceState = newDebounceState }) model.debounceState control

        NewGiphys result ->
            case result of
                Ok giphyResult ->
                    ( { model
                        | data = giphyResult.data
                        , selected = List.head giphyResult.data
                        , error = Nothing
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( { model | error = Just (String.fromInt err) }, Cmd.none )

        GiphySelect giphyData ->
            ( { model | selected = Just giphyData }, Cmd.none )

        NewTime time ->
            ( { model | time = time }, Cmd.none )


searchGiphys : (Result Error GiphyResult -> msg) -> String -> Cmd msg
searchGiphys resultToMessage query =
    let
        url =
            "http://api.giphy.com/v1/gifs/search?q=" ++ query ++ "&limit=7&api_key=dc6zaTOxFJmzC"
    in
    Http.send resultToMessage (Http.get url decodeGiphyResult)



--- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 [ class "text-center" ] [ text ("Giphy Search - " ++ toClock model.time) ]
        , searchBar
        , viewError model.error
        , viewDetail model.selected
        , viewList model.data
        ]


searchBar : Html Msg
searchBar =
    div [ class "search-bar" ]
        [ input
            [ placeholder "Search term .."
            , type_ "text"
            , Html.Attributes.map debounce (onInput NewSearch)
            ]
            []
        ]


debounce : Msg -> Msg
debounce =
    -- !! no parameter !!
    Control.Debounce.trailing Debounce (1 * Time.second)


viewError : Maybe String -> Html Msg
viewError error =
    case error of
        Just message ->
            div [ class "alert alert-danger" ] [ text message ]

        Nothing ->
            span [] []


viewList : List GiphyData -> Html Msg
viewList data =
    ul [ class "col-md-4 list-group" ] (viewListItems data)


viewListItems : List GiphyData -> List (Html Msg)
viewListItems data =
    List.map viewListItem data


viewListItem : GiphyData -> Html Msg
viewListItem data =
    li [ class "list-group-item" ]
        [ div [ class "giphy-list media" ]
            [ div [ class "media-left" ]
                [ img
                    [ src data.images.fixed_height_small_still.url
                    , onClick (GiphySelect data)
                    ]
                    []
                ]
            ]
        ]


viewDetail : Maybe GiphyData -> Html Msg
viewDetail maybeData =
    div [ class "giphy-detail col-md-8" ]
        [ case maybeData of
            Just data ->
                div []
                    [ div [ class "embed-responsive embed-responsive-16by9" ]
                        [ iframe
                            [ class "embed-responsive-item"
                            , src data.embed_url
                            , title data.slug
                            ]
                            []
                        ]
                    , div [ class "details text-center" ]
                        [ a
                            [ class "btn btn-primary"
                            , role "button"
                            , downloadAs data.slug
                            , href data.images.original.url
                            , title data.slug
                            , alt data.slug
                            ]
                            [ text "Download from Giphy" ]
                        ]
                    ]

            Nothing ->
                div [] [ text "Loading .." ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every Time.second NewTime


toClock : Time -> String
toClock time =
    let
        date =
            fromTime time

        hour =
            Date.hour date |> to2DigitString

        minute =
            to2DigitString (Date.minute date)

        second =
            date |> Date.second |> to2DigitString
    in
    hour ++ ":" ++ minute ++ ":" ++ second


to2DigitString : Int -> String
to2DigitString t =
    let
        ts =
            toString t
    in
    case String.length ts of
        1 ->
            "0" ++ ts

        _ ->
            ts
