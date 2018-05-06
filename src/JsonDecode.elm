module JsonDecode exposing (..)

import Json.Decode exposing (Decoder, decodeString, list, string)
import Json.Decode.Pipeline exposing (decode, required)


type alias GiphyResult =
    { data : List GiphyData
    }


type alias GiphyData =
    { embed_url : String
    , slug : String
    , images : GiphyImages
    }


type alias GiphyImages =
    { fixed_width : GiphyImage
    , fixed_height_small_still : GiphyImage
    , original : GiphyImage
    }


type alias GiphyImage =
    { url : String
    }


decodeGiphyResult : Decoder GiphyResult
decodeGiphyResult =
    decode GiphyResult
        |> required "data" (list decodeGiphyData)


decodeGiphyData : Decoder GiphyData
decodeGiphyData =
    decode GiphyData
        |> required "embed_url" string
        |> required "slug" string
        |> required "images" decodeGiphyImages


decodeGiphyImages : Decoder GiphyImages
decodeGiphyImages =
    decode GiphyImages
        |> required "fixed_width" decodeGiphyImage
        |> required "fixed_height_small_still" decodeGiphyImage
        |> required "original" decodeGiphyImage


decodeGiphyImage : Decoder GiphyImage
decodeGiphyImage =
    decode GiphyImage
        |> required "url" string
