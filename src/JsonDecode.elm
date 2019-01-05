module JsonDecode exposing (GiphyData, GiphyImage, GiphyImages, GiphyResult, decodeGiphyData, decodeGiphyImage, decodeGiphyImages, decodeGiphyResult)

import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline


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


decodeGiphyResult : Decode.Decoder GiphyResult
decodeGiphyResult =
    Decode.succeed GiphyResult
        |> Pipeline.required "data" (Decode.list decodeGiphyData)


decodeGiphyData : Decode.Decoder GiphyData
decodeGiphyData =
    Decode.succeed GiphyData
        |> Pipeline.required "embed_url" Decode.string
        |> Pipeline.required "slug" Decode.string
        |> Pipeline.required "images" decodeGiphyImages


decodeGiphyImages : Decode.Decoder GiphyImages
decodeGiphyImages =
    Decode.succeed GiphyImages
        |> Pipeline.required "fixed_width" decodeGiphyImage
        |> Pipeline.required "fixed_height_small_still" decodeGiphyImage
        |> Pipeline.required "original" decodeGiphyImage


decodeGiphyImage : Decode.Decoder GiphyImage
decodeGiphyImage =
    Decode.succeed GiphyImage
        |> Pipeline.required "url" Decode.string
