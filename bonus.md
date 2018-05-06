# Bonus track

## Was ist mit den "subscriptions"?

### Aufgabe: Uhrzeit anzeigen

#### eine *subscription* anlegen
```elm
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every Time.second NewTime
```

####  in *main* ergänzen
```elm
    , subscriptions = subscriptions
```

#### im *Model* ergänzen
```elm
    , time : Time
```

#### in *init* ergänzen
```elm
      , time = 0
```

#### in *Msg* ergänzen
```elm
    | NewTime Time
```

#### in *update* ergänzen
```elm
        NewTime time ->
            ( { model | time = time }, Cmd.none )
```

#### in *view* ergänzen
```elm
        , h1 [ class "text-center" ] [ text ("Giphy Search - " ++ toClock model.time) ]
```

#### und *toClock* hinzufügen
```elm
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
```

### Client starten und auf die kurze Anfangssituation hinweisen - Zeit ist erst nicht richtig!

#### in *init* einen weiteren initialen *Cmd* hinzufügen
```elm
    , Cmd.batch [ Util.perform (NewSearch "minions"), Task.perform NewTime Time.now ]
```
