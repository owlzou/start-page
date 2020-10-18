module Data exposing (..)

import Array exposing (Array)
import Html exposing (Html)
import Json.Decode as D
import Json.Encode as E


type alias Link =
    { name : String
    , url : String
    , icon : Maybe String
    }


type alias BackgroundPhoto =
    { file : String
    , photographer : String
    , photographerUrl : String
    , url : String
    }


type alias SaveData =
    { search : Array Link
    }


initLink : Link
initLink =
    { name = ""
    , url = ""
    , icon = Nothing
    }


defaultSearchEngine : Array Link
defaultSearchEngine =
    Array.fromList
        [ { name = "百度"
          , url = "https://www.baidu.com/baidu?wd=%s"
          , icon = Just "M4.312 12.65c2.61-.562 2.25-3.684 2.176-4.366-.128-1.05-1.366-2.888-3.044-2.74-2.11.186-2.418 3.24-2.418 3.24-.287 1.41.682 4.426 3.286 3.865m4.845-5.24c1.44 0 2.604-1.66 2.604-3.71 0-2.04-1.16-3.7-2.6-3.7S6.55 1.65 6.55 3.7c0 2.05 1.17 3.71 2.61 3.71m6.207.245c1.93.26 3.162-1.8 3.412-3.36.25-1.55-1-3.36-2.36-3.67-1.37-.316-3.06 1.874-3.23 3.3-.18 1.75.25 3.49 2.17 3.737M23 10.284c0-.746-.613-2.993-2.91-2.993-2.295 0-2.61 2.12-2.61 3.62 0 1.43.118 3.42 2.985 3.36 2.855-.07 2.543-3.24 2.543-3.99M20.1 16.82s-2.985-2.31-4.726-4.8c-2.36-3.677-5.715-2.18-6.834-.316-1.12 1.883-2.86 3.062-3.105 3.377-.25.31-3.6 2.12-2.854 5.42.75 3.3 3.36 3.24 3.36 3.24s1.92.19 4.16-.31 4.16.12 4.16.12 5.207 1.75 6.648-1.61c1.424-3.37-.81-5.11-.81-5.11"
          }
        , { name = "Bing"
          , url = "https://cn.bing.com/search?q=%s"
          , icon = Just "M3.605 0L8.4 1.686V18.56l6.753-3.895-3.31-1.555-2.09-5.2 10.64 3.738v5.435L8.403 24l-4.797-2.67V0z"
          }
        , { name = "Github"
          , url = "https://github.com/search?q=%s"
          , icon = Just "M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"
          }
        , { name = "Google"
          , url = "https://www.google.com/search?q=%s"
          , icon = Just "M12.24 10.285V14.4h6.806c-.275 1.765-2.056 5.174-6.806 5.174-4.095 0-7.439-3.389-7.439-7.574s3.345-7.574 7.439-7.574c2.33 0 3.891.989 4.785 1.849l3.254-3.138C18.189 1.186 15.479 0 12.24 0c-6.635 0-12 5.365-12 12s5.365 12 12 12c6.926 0 11.52-4.869 11.52-11.726 0-.788-.085-1.39-.189-1.989H12.24z"
          }
        , { name = "Bilibili"
          , url = "https://search.bilibili.com/all?keyword=%s"
          , icon = Just "M17.813 4.653h.854c1.51.054 2.769.578 3.773 1.574 1.004.995 1.524 2.249 1.56 3.76v7.36c-.036 1.51-.556 2.769-1.56 3.773s-2.262 1.524-3.773 1.56H5.333c-1.51-.036-2.769-.556-3.773-1.56S.036 18.858 0 17.347v-7.36c.036-1.511.556-2.765 1.56-3.76 1.004-.996 2.262-1.52 3.773-1.574h.774l-1.174-1.12a1.234 1.234 0 0 1-.373-.906c0-.356.124-.658.373-.907l.027-.027c.267-.249.573-.373.92-.373.347 0 .653.124.92.373L9.653 4.44c.071.071.134.142.187.213h4.267a.836.836 0 0 1 .16-.213l2.853-2.747c.267-.249.573-.373.92-.373.347 0 .662.151.929.4.267.249.391.551.391.907 0 .355-.124.657-.373.906zM5.333 7.24c-.746.018-1.373.276-1.88.773-.506.498-.769 1.13-.786 1.894v7.52c.017.764.28 1.395.786 1.893.507.498 1.134.756 1.88.773h13.334c.746-.017 1.373-.275 1.88-.773.506-.498.769-1.129.786-1.893v-7.52c-.017-.765-.28-1.396-.786-1.894-.507-.497-1.134-.755-1.88-.773zM8 11.107c.373 0 .684.124.933.373.25.249.383.569.4.96v1.173c-.017.391-.15.711-.4.96-.249.25-.56.374-.933.374s-.684-.125-.933-.374c-.25-.249-.383-.569-.4-.96V12.44c0-.373.129-.689.386-.947.258-.257.574-.386.947-.386zm8 0c.373 0 .684.124.933.373.25.249.383.569.4.96v1.173c-.017.391-.15.711-.4.96-.249.25-.56.374-.933.374s-.684-.125-.933-.374c-.25-.249-.383-.569-.4-.96V12.44c.017-.391.15-.711.4-.96.249-.249.56-.373.933-.373Z"
          }
        , { name = "淘宝"
          , url = "https://s.taobao.com/search?q=%s"
          , icon = Just "m 23.478928,16.521355 c -0.398061,2.916758 -1.879875,3.334081 -3.857981,3.384801 -1.441366,0.03595 -2.884658,0 -4.326023,0 -0.03917,-0.4231 -0.07833,-0.8462 -0.116851,-1.268658 0.895637,0 1.793201,0.03339 2.688838,0 1.833006,-0.07127 2.62977,-0.760168 2.68948,-2.855766 L 20.67324,11.657307 C 20.7368,9.3934959 20.885112,6.9345061 18.451803,6.4754517 16.695199,6.1441621 14.866044,6.6166999 13.073487,6.6866812 12.710096,6.7508822 12.360829,6.8253602 12.02633,6.9139614 l 1.397707,1.0420207 -1.137041,1.057429 h 7.099609 v 1.3745949 h -4.208532 v 1.586466 h 4.208532 v 1.163364 h -4.208532 v 2.740201 c 0.659369,-0.15152 1.318737,-0.308819 1.987737,-0.41347 -0.234343,-0.353119 -0.468043,-0.705596 -0.701743,-1.05743 0.545087,-0.211871 1.090173,-0.4231 1.636544,-0.634971 1.285994,0.774935 1.792558,1.833648 1.520336,3.172289 -0.507207,0.423742 -1.013772,0.846842 -1.520336,1.2693 -0.272865,-0.458412 -0.546371,-0.916824 -0.818593,-1.374594 -7.7557677,2.748547 -10.9909759,1.833007 -9.7036982,-2.74983 h 2.8056872 c 0,1.868318 0.376232,2.166864 1.403486,2.221437 0.03917,0.0019 0.07768,0.0019 0.116851,0.0032 V 13.137836 H 7.69517 v -1.163364 h 4.209174 V 10.388006 H 11.08575 V 10.131834 L 9.3317141,11.763242 7.8120202,11.022977 10.742262,7.3460499 C 9.4652571,7.8770115 8.4514858,8.6461684 7.69517,9.6483832 7.5783198,9.8942822 7.4614697,10.141465 7.3446195,10.388006 6.6049967,9.8596117 5.8634477,9.330576 5.1225407,8.8021826 6.3314903,7.0038461 7.5397978,5.2061509 8.7474633,3.4090988 9.7605927,3.7262635 10.773079,4.0434278 11.787493,4.3605926 11.55315,4.888987 11.320093,5.4180227 11.08575,5.9464161 15.890731,3.8604485 23.323556,3.6158336 23.712628,8.3790824 c 0.248467,3.0387456 0.114925,5.5940406 -0.2337,8.1422726 z M 4.2461646,7.6388172 c -1.1916147,0 -2.1636538,-0.8783018 -2.1636538,-1.9562767 0,-1.0779748 0.9720391,-1.956277 2.1636538,-1.956277 1.1909726,0 2.1623697,0.8783022 2.1623697,1.956277 0,1.0779749 -0.9713971,1.9562767 -2.1623697,1.9562767 z M 1.0308595,9.8596117 C 1.5374241,9.2952642 2.0446308,8.7309167 2.5511955,8.1672106 6.7199208,10.563281 7.1834691,12.628062 5.7074335,15.358632 4.6833896,17.253273 4.2275456,18.68565 3.4859966,20.117386 2.3560171,19.305855 1.2253957,18.495608 0.0960583,17.685362 1.3428879,16.733868 2.7598564,15.938388 3.8371891,14.829595 5.8281358,12.778297 3.6099091,11.196968 1.0308595,9.8596117 Z"
          }
        ]


dataToJson : Array Link -> E.Value
dataToJson arr =
    let
        linkToJson link =
            E.object [ ( "name", E.string link.name ), ( "url", E.string link.url ), ( "icon", E.string <| Maybe.withDefault "" link.icon ) ]
    in
    E.object [ ( "search", E.array linkToJson arr ) ]


jsonToData : D.Decoder SaveData
jsonToData =
    let
        linkDecoder =
            D.map3 Link (D.field "name" D.string) (D.field "url" D.string) (D.maybe (D.field "icon" D.string))
    in
    D.map SaveData (D.field "search" (D.array linkDecoder))
