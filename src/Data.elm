module Data exposing (..)

import Array exposing (Array)
import Html exposing (Html)
import Icons


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
        ]


background : BackgroundPhoto
background =
    { url = "https://unsplash.com/s/photos/cityscape?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText"
    , photographer = "CHUTTERSNAP"
    , photographerUrl = "https://unsplash.com/@chuttersnap?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText"
    , file = "chuttersnap-JH0wCegJsrQ-unsplash.jpg"
    }
