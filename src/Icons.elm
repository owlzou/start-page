module Icons exposing
    ( checkSquare
    , chevronsDown
    , chevronsUp
    , delete
    , github
    , minusSquare
    , plusSquare
    , search
    , settings
    , square
    , svgIcon
    , x
    )

import Html exposing (Html)
import Svg exposing (Svg, svg)
import Svg.Attributes exposing (..)


svgFeatherIcon : String -> List (Svg msg) -> Html msg
svgFeatherIcon className =
    svg
        [ class <| "feather feather-" ++ className
        , fill "none"
        , height "24"
        , stroke "currentColor"
        , strokeLinecap "round"
        , strokeLinejoin "round"
        , strokeWidth "2"
        , viewBox "0 0 24 24"
        , width "24"
        ]


checkSquare : Html msg
checkSquare =
    svgFeatherIcon "check-square"
        [ Svg.polyline [ points "9 11 12 14 22 4" ] []
        , Svg.path [ d "M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11" ] []
        ]


chevronsDown : Html msg
chevronsDown =
    svgFeatherIcon "chevrons-down"
        [ Svg.polyline [ points "7 13 12 18 17 13" ] []
        , Svg.polyline [ points "7 6 12 11 17 6" ] []
        ]


chevronsUp : Html msg
chevronsUp =
    svgFeatherIcon "chevrons-up"
        [ Svg.polyline [ points "17 11 12 6 7 11" ] []
        , Svg.polyline [ points "17 18 12 13 7 18" ] []
        ]


delete : Html msg
delete =
    svgFeatherIcon "delete"
        [ Svg.path [ d "M21 4H8l-7 8 7 8h13a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2z" ] []
        , Svg.line [ x1 "18", y1 "9", x2 "12", y2 "15" ] []
        , Svg.line [ x1 "12", y1 "9", x2 "18", y2 "15" ] []
        ]


github : Html msg
github =
    svgFeatherIcon "github"
        [ Svg.path [ d "M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22" ] []
        ]


minusSquare : Html msg
minusSquare =
    svgFeatherIcon "minus-square"
        [ Svg.rect [ Svg.Attributes.x "3", y "3", width "18", height "18", rx "2", ry "2" ] []
        , Svg.line [ x1 "8", y1 "12", x2 "16", y2 "12" ] []
        ]


plusSquare : Html msg
plusSquare =
    svgFeatherIcon "plus-square"
        [ Svg.rect [ Svg.Attributes.x "3", y "3", width "18", height "18", rx "2", ry "2" ] []
        , Svg.line [ x1 "12", y1 "8", x2 "12", y2 "16" ] []
        , Svg.line [ x1 "8", y1 "12", x2 "16", y2 "12" ] []
        ]


search : Html msg
search =
    svgFeatherIcon "search"
        [ Svg.circle [ cx "11", cy "11", r "8" ] []
        , Svg.line [ x1 "21", y1 "21", x2 "16.65", y2 "16.65" ] []
        ]


settings : Html msg
settings =
    svgFeatherIcon "settings"
        [ Svg.circle [ cx "12", cy "12", r "3" ] []
        , Svg.path [ d "M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z" ] []
        ]


square : Html msg
square =
    svgFeatherIcon "square"
        [ Svg.rect [ Svg.Attributes.x "3", y "3", width "18", height "18", rx "2", ry "2" ] []
        ]


x : Html msg
x =
    svgFeatherIcon "x"
        [ Svg.line [ x1 "18", y1 "6", x2 "6", y2 "18" ] []
        , Svg.line [ x1 "6", y1 "6", x2 "18", y2 "18" ] []
        ]



-- 将普通路径转换成svg


svgIcon : String -> Html msg
svgIcon path =
    svg
        [ viewBox "0 0 24 24"
        , fill "currentColor"
        , height "24"
        , width "24"
        ]
        [ Svg.path [ d path ] [] ]
