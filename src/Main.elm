module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import JsonDecode
import Time
import Util exposing (..)


main : Platform.Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- MODEL


type alias Model =
    { query : String
    , error : Maybe String
    , data : List JsonDecode.GiphyData
    , selected : Maybe JsonDecode.GiphyData
    }



-- initial model


init : () -> ( Model, Cmd Msg )
init _ =
    ( { query = ""
      , error = Nothing
      , data = []
      , selected = Maybe.Nothing
      }
    , perform (NewSearch "minions")
    )



-- UPDATE


type Msg
    = NewSearch String
    | NewGiphys (Result Http.Error JsonDecode.GiphyResult)
    | GiphySelect JsonDecode.GiphyData


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewSearch query ->
            ( { model | query = query }
            , searchGiphys NewGiphys query
            )

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
                    ( { model | error = toErrorString err }, Cmd.none )

        GiphySelect giphyData ->
            ( { model | selected = Just giphyData }, Cmd.none )


searchGiphys : (Result Http.Error JsonDecode.GiphyResult -> msg) -> String -> Cmd msg
searchGiphys resultToMessage query =
    Http.get
        { url = "http://api.giphy.com/v1/gifs/search?q=" ++ query ++ "&limit=7&api_key=dc6zaTOxFJmzC"
        , expect = Http.expectJson resultToMessage JsonDecode.decodeGiphyResult
        }


toErrorString : Http.Error -> Maybe String
toErrorString err =
    Just <|
        case err of
            Http.BadUrl str ->
                "Bad url " ++ str

            Http.Timeout ->
                "Request timed out"

            Http.NetworkError ->
                "Network error"

            Http.BadStatus int ->
                "Bad status " ++ String.fromInt int

            Http.BadBody str ->
                "Bad body " ++ str



--- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 [ class "text-center" ] [ text "Giphy Search" ]
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
            , onInput NewSearch
            ]
            []
        ]


viewError : Maybe String -> Html Msg
viewError error =
    case error of
        Just message ->
            div [ class "alert alert-danger" ] [ text message ]

        Nothing ->
            span [] []


viewList : List JsonDecode.GiphyData -> Html Msg
viewList data =
    ul [ class "col-md-4 list-group" ] (viewListItems data)


viewListItems : List JsonDecode.GiphyData -> List (Html Msg)
viewListItems data =
    List.map viewListItem data


viewListItem : JsonDecode.GiphyData -> Html Msg
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


viewDetail : Maybe JsonDecode.GiphyData -> Html Msg
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
                            , download data.slug
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
