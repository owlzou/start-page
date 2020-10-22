port module Main exposing (main)

import Array exposing (Array)
import Browser
import Browser.Dom as Dom
import Browser.Navigation exposing (back)
import Data exposing (Link, SaveData, dataToJson, defaultNav, defaultSearchEngine, initLink, jsonToData, trimLink)
import Html exposing (Html, a, button, div, footer, h3, input, li, span, text, ul)
import Html.Attributes exposing (class, href, placeholder, style, target, title, type_, value)
import Html.Events exposing (keyCode, on, onBlur, onClick, onFocus, onInput)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy)
import Icons
import Json.Decode as D
import Json.Encode as E
import Svg exposing (path)
import Task
import Time



-- MAIN


main : Program E.Value Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }



-- MODEL


type alias Model =
    { searchFocused : Bool
    , searchSelectOpen : Bool
    , keyword : String
    , navs : Array Link
    , time : Time.Posix
    , zone : Time.Zone
    , drawerOpen : Bool
    , searchEngines : Array Link
    , curSearchEngine : Link
    , viewportHeight : Float
    , targetHeight : Float
    , scrollStep : Float
    , scrollTime : Float
    , scrollTimeStep : Float
    , scrolling : Bool
    , page : Page
    }


init : E.Value -> ( Model, Cmd Msg )
init val =
    case D.decodeValue jsonToData val of
        Ok v ->
            ( { initModel | searchEngines = v.search }, Task.perform AdjustTimeZone Time.here )

        Err _ ->
            ( initModel, Task.perform AdjustTimeZone Time.here )


initModel : Model
initModel =
    { -- 搜索栏
      searchFocused = False
    , searchSelectOpen = False
    , keyword = ""

    --导航
    , navs = defaultNav

    -- 时间
    , time = Time.millisToPosix 0
    , zone = Time.utc

    --抽屉
    , drawerOpen = False
    , searchEngines = defaultSearchEngine
    , curSearchEngine =
        case Array.get 0 defaultSearchEngine of
            Just link ->
                link

            Nothing ->
                { name = "百度"
                , url = "https://www.baidu.com/baidu?wd=%s"
                , icon = Nothing
                }

    -- 滚动相关
    , viewportHeight = 0
    , targetHeight = 0
    , scrollStep = 0
    , scrollTime = 600.0
    , scrollTimeStep = 50.0
    , scrolling = False
    , page = Search
    }



-- UPDATE


type Msg
    = OnSearchbarFocus Bool
    | OnSearchSelectOpen
    | OnSearchSelect Link
    | OnSearchInput String
    | OnSearch
    | OnTick Time.Posix
    | AdjustTimeZone Time.Zone
    | OnDrawerOpen Bool
    | OnEntryInput Int EntryInput String
    | OnEntryAdd
    | OnEntryRemove Int
    | ChangePage Page
    | GetViewportHeight Dom.Viewport Page
    | Scroll Time.Posix
    | NoOp


type EntryInput
    = Name
    | URL
    | ICON


type Page
    = Search
    | Nav


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnSearchbarFocus b ->
            ( { model
                | searchFocused = b || model.searchSelectOpen
                , searchSelectOpen =
                    if b && model.searchSelectOpen then
                        False

                    else
                        model.searchSelectOpen
              }
            , Cmd.none
            )

        OnSearchSelectOpen ->
            ( { model | searchSelectOpen = not model.searchSelectOpen, searchFocused = not model.searchSelectOpen }, Cmd.none )

        OnSearchSelect link ->
            ( { model | curSearchEngine = link }, Cmd.none )

        OnSearchInput input ->
            ( { model | keyword = input }, Cmd.none )

        OnSearch ->
            ( model
            , let
                -- 利用 link 更新搜索用的地址
                updateSearchLink search keyword =
                    search.url |> String.replace "%s" keyword

                searchUrl =
                    updateSearchLink model.curSearchEngine model.keyword
              in
              searchUrl |> newWindow
            )

        OnTick newTime ->
            ( { model | time = newTime }, Cmd.none )

        AdjustTimeZone zone ->
            ( { model | zone = zone }, Cmd.none )

        OnDrawerOpen b ->
            ( { model | drawerOpen = b, searchEngines = Array.map trimLink model.searchEngines }, saveToStorage <| dataToJson model.searchEngines )

        OnEntryInput index type_ str ->
            let
                item =
                    Maybe.withDefault initLink (Array.get index model.searchEngines)

                newItem =
                    case type_ of
                        URL ->
                            { item | url = str }

                        Name ->
                            { item | name = str }

                        ICON ->
                            { item | icon = Just str }
            in
            ( { model | searchEngines = Array.set index newItem model.searchEngines }, Cmd.none )

        OnEntryAdd ->
            ( { model | searchEngines = Array.push initLink model.searchEngines }, Cmd.none )

        OnEntryRemove index ->
            ( { model | searchEngines = removeFromArray index model.searchEngines }, Cmd.none )

        ChangePage page ->
            ( { model | page = page }, Task.perform (\i -> GetViewportHeight i page) Dom.getViewport )

        GetViewportHeight vp page ->
            let
                th =
                    case page of
                        Search ->
                            0

                        Nav ->
                            vp.viewport.height
            in
            ( { model
                | scrolling = True
                , targetHeight = th
                , viewportHeight = vp.viewport.y
                , scrollStep = (th - vp.viewport.y) / (model.scrollTime / model.scrollTimeStep)
              }
            , Cmd.none
            )

        Scroll _ ->
            let
                isScroll =
                    if round (abs (model.viewportHeight - model.targetHeight)) <= 1 then
                        False

                    else
                        True
            in
            ( { model
                | viewportHeight = model.viewportHeight + model.scrollStep
                , scrolling = isScroll
              }
            , Task.perform (\_ -> NoOp) (Dom.setViewport 0 (model.viewportHeight + model.scrollStep))
            )

        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS
-- 更新时间


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.scrolling then
        Sub.batch [ Time.every 1000 OnTick, Time.every model.scrollTimeStep Scroll ]

    else
        Time.every 1000 OnTick



-- PORTS


port newWindow : String -> Cmd msg


port receiver : (E.Value -> msg) -> Sub msg


port saveToStorage : E.Value -> Cmd msg



-- VIEW


view : Model -> Html Msg
view model =
    let
        arrowVisible =
            if model.scrolling then
                "hidden"

            else
                "visible"

        ( sclass, nclass ) =
            case model.page of
                Search ->
                    ( "page show", "page hidden" )

                Nav ->
                    ( "page hidden", "page show" )
    in
    div []
        [ div [ class "bg", style "background-image" "url(img/chuttersnap-JH0wCegJsrQ-unsplash.jpg)" ] []
        , timebar model
        , div [ class "container" ]
            [ -- Page1
              div [ class sclass ]
                [ div [ class "main" ]
                    [ lazy searchbar model
                    , lazy searchSelect model
                    ]
                , span [ class "button-arrow to-nav", onClick (ChangePage Nav), style "visibility" arrowVisible ] [ Icons.chevronsDown ]
                ]

            -- Page2
            , div [ class nclass ]
                [ div [ class "main" ] [ lazy nav model ]
                , span [ class "button-arrow to-nav", onClick (ChangePage Search), style "visibility" arrowVisible ] [ Icons.chevronsUp ]
                ]
            ]
        , settingBtn
        , lazy drawer model
        ]


settingBtn : Html Msg
settingBtn =
    button [ class "gear", onClick (OnDrawerOpen True) ] [ Icons.settings ]


drawer : Model -> Html Msg
drawer model =
    let
        translate =
            if model.drawerOpen then
                "translateX(0)"

            else
                "translateX(-100%)"
    in
    div [ class "drawer", style "transform" translate ]
        [ button [ class "drawer__close", onClick (OnDrawerOpen False) ] [ Icons.x ]
        , div [ class "drawer-content" ]
            [ h3 []
                [ text "搜索引擎设置"
                , button [ class "drawer-entry__add", onClick OnEntryAdd ] [ Icons.plusSquare ]
                ]
            , Keyed.node "ul" [] (Array.toList <| Array.indexedMap keyedLink model.searchEngines)
            , h3 [] [ text "关于" ]
            , div [ class "drawer-about" ]
                [ div [ class "drawer-about__repo" ] [ Icons.github, a [ href "https://github.com/owlzou/start-page", target "_blank" ] [ text "owlzou / start-page" ] ]
                , backgroundCredit
                ]
            ]
        ]


keyedLink : Int -> Link -> ( String, Html Msg )
keyedLink index link =
    ( String.fromInt index, lazy (renderEntry index) link )


renderEntry : Int -> Link -> Html Msg
renderEntry index link =
    li [ class "drawer-entry" ]
        [ input [ placeholder "名称", type_ "text", value link.name, onInput (OnEntryInput index Name) ]
            []
        , input [ placeholder "搜索链接", type_ "text", value link.url, onInput (OnEntryInput index URL) ]
            []
        , case link.icon of
            Just icon ->
                Icons.svgIcon icon

            Nothing ->
                span [] []
        , input [ placeholder "SVG 图标 Path", type_ "text", value <| Maybe.withDefault "" link.icon, onInput (OnEntryInput index ICON) ]
            []
        , button [ class "drawer-entry__delete", onClick (OnEntryRemove index) ] [ Icons.minusSquare ]
        ]


timebar : Model -> Html msg
timebar model =
    let
        fillNumber str =
            if String.length str < 2 then
                "0" ++ str

            else
                str

        hour =
            fillNumber <| String.fromInt (Time.toHour model.zone model.time)

        minute =
            fillNumber <| String.fromInt (Time.toMinute model.zone model.time)

        day =
            fillNumber <| String.fromInt (Time.toDay model.zone model.time)

        month =
            toSimpleMonth (Time.toMonth model.zone model.time)

        year =
            String.fromInt (Time.toYear model.zone model.time)

        week =
            toWeekDay (Time.toWeekday model.zone model.time)
    in
    div [ class "timebar" ]
        [ div [ class "timebar__time" ]
            [ text <| String.join " " <| String.split "" <| String.join ":" [ hour, minute ] ]
        , div [ class "timebar__hr" ]
            []
        , div [ class "timebar__date" ]
            [ text <| String.join " " <| String.split "" <| String.join "/" [ year, month, day ] ]
        , div [ class "timebar__hr" ]
            []
        , div [ class "timebar__week" ]
            [ text <| String.join " " <| String.split "" <| week ]
        ]


searchbar : Model -> Html Msg
searchbar model =
    let
        op =
            if model.searchFocused then
                "1"

            else
                "0.3"
    in
    div [ class "searchbar-wrap" ]
        [ div [ class "searchbar", style "opacity" op ]
            [ div [ class "searchbar__select", onClick OnSearchSelectOpen ]
                [ case model.curSearchEngine.icon of
                    Just path ->
                        Icons.svgIcon path

                    Nothing ->
                        span [] [ text model.curSearchEngine.name ]
                ]
            , input
                [ class "searchbar__input"
                , type_ "text"
                , value model.keyword
                , onFocus (OnSearchbarFocus True)
                , onBlur (OnSearchbarFocus False)
                , onInput OnSearchInput
                , onEnter OnSearch
                ]
                []
            , button [ class "searchbar__btn", onClick OnSearch ]
                [ Icons.search ]
            ]
        ]


searchSelect : Model -> Html Msg
searchSelect model =
    let
        render lks =
            li []
                [ a [ onClick (OnSearchSelect lks), title lks.name ]
                    [ case lks.icon of
                        Just icon ->
                            Icons.svgIcon icon

                        Nothing ->
                            span [] [ text lks.name ]
                    ]
                ]

        keyedRender lks =
            ( lks.name, lazy render lks )

        op =
            if model.searchSelectOpen then
                "1"

            else
                "0"
    in
    div [ class "searchbar-list", style "opacity" op ]
        [ Keyed.node "ul" [] (Array.toList <| Array.map keyedRender model.searchEngines)
        ]


nav : Model -> Html msg
nav model =
    let
        render lks =
            case lks.icon of
                Just icon ->
                    li [] [ Icons.svgIcon icon, a [ href lks.url, target "_blank" ] [ text lks.name ] ]

                Nothing ->
                    li [] [ a [ href lks.url, target "_blank" ] [ text lks.name ] ]

        keyedRender lks =
            ( lks.name, lazy render lks )
    in
    div [ class "nav" ]
        [ Keyed.node "ul" [] (Array.toList (Array.map keyedRender model.navs)) ]


backgroundCredit : Html Msg
backgroundCredit =
    footer []
        [ span []
            [ text "Photo by "
            , a [ href "https://unsplash.com/@chuttersnap?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText", target "_blank" ]
                [ text "CHUTTERSNAP" ]
            , text " on "
            , a [ href "https://unsplash.com/s/photos/cityscape?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText", target "_blank" ]
                [ text "Unsplash" ]
            ]
        ]



-- Helper


onEnter : Msg -> Html.Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                D.succeed msg

            else
                D.fail "fail"
    in
    on "keydown" (D.andThen isEnter keyCode)



-- 工具：移除array中指定位置的元素


removeFromArray : Int -> Array a -> Array a
removeFromArray index arr =
    let
        start =
            Array.slice 0 index arr

        end =
            Array.slice (index + 1) (Array.length arr + 1) arr
    in
    Array.append start end



-- 月份转换


toSimpleMonth : Time.Month -> String
toSimpleMonth m =
    case m of
        Time.Jan ->
            "01"

        Time.Feb ->
            "02"

        Time.Mar ->
            "03"

        Time.Apr ->
            "04"

        Time.May ->
            "05"

        Time.Jun ->
            "06"

        Time.Jul ->
            "07"

        Time.Aug ->
            "08"

        Time.Sep ->
            "09"

        Time.Oct ->
            "10"

        Time.Nov ->
            "11"

        Time.Dec ->
            "12"


toWeekDay : Time.Weekday -> String
toWeekDay weekday =
    case weekday of
        Time.Mon ->
            "Monday"

        Time.Tue ->
            "Tuesday"

        Time.Wed ->
            "Wednesday"

        Time.Thu ->
            "Thursday"

        Time.Fri ->
            "Friday"

        Time.Sat ->
            "Saturday"

        Time.Sun ->
            "Sunday"
