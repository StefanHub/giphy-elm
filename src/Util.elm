module Util exposing (perform, role)

import Html
import Html.Attributes
import Task


perform : msg -> Cmd msg
perform msg =
    -- https://medium.com/elm-shorts/how-to-turn-a-msg-into-a-cmd-msg-in-elm-5dd095175d84
    Task.succeed msg
        |> Task.perform identity


role : String -> Html.Attribute msg
role name =
    Html.Attributes.attribute "role" name
