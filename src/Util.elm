module Util exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Task exposing (..)


perform : msg -> Cmd msg
perform msg =
    -- https://medium.com/elm-shorts/how-to-turn-a-msg-into-a-cmd-msg-in-elm-5dd095175d84
    Task.succeed msg
        |> Task.perform identity


role : String -> Attribute msg
role name =
    attribute "role" name
