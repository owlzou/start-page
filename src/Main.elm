port module Main exposing (main)

import Array exposing (Array)
import Browser
import Browser.Dom as Dom
import Data exposing (Link, SaveData, dataToString, defaultNav, defaultSearchEngine, initLink, jsonToData, trimLink)
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Html exposing (Html, a, button, div, footer, h3, input, li, span, text)
import Html.Attributes exposing (class, href, placeholder, style, target, title, type_, value)
import Html.Events exposing (keyCode, on, onBlur, onClick, onFocus, onInput)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy, lazy2, lazy3)
import Icons
import Json.Decode as D
import Json.Encode as E
import Platform exposing (sendToApp)
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
    , time : Time.Posix
    , zone : Time.Zone
    , drawer : Drawer
    , curSearchEngine : Link
    , viewportHeight : Float
    , targetHeight : Float
    , scrollStep : Float
    , scrollTime : Float
    , scrollTimeStep : Float
    , scrolling : Bool
    , page : Page
    }


type alias Drawer =
    { open : Bool
    , searchEngines : Array Link
    , navs : Array Link
    , saveData : Bool
    }


init : E.Value -> ( Model, Cmd Msg )
init val =
    case D.decodeValue jsonToData val of
        Ok v ->
            let
                dr =
                    { searchEngines = v.search, navs = v.navs, open = False, saveData = True }
            in
            ( { initModel | drawer = dr }, Task.perform AdjustTimeZone Time.here )

        Err _ ->
            ( initModel, Task.perform AdjustTimeZone Time.here )


initModel : Model
initModel =
    { -- 搜索栏
      searchFocused = False
    , searchSelectOpen = False
    , keyword = ""

    --导航
    -- 时间
    , time = Time.millisToPosix 0
    , zone = Time.utc

    --抽屉
    , drawer =
        { open = False
        , searchEngines = defaultSearchEngine
        , navs = defaultNav
        , saveData = False
        }
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
    | DeleteInput
      -- 时间
    | OnTick Time.Posix
    | AdjustTimeZone Time.Zone
      -- 抽屉
    | OnDrawerOpen Bool
    | OnEntryInput Page Int EntryInput String
    | OnEntryAdd Page
    | OnEntryRemove Page Int
    | SwitchSaveOption
      -- 滚动
    | ChangePage Page
    | GetViewportHeight Dom.Viewport Page
    | Scroll Time.Posix
      -- 导入导出
    | Import
    | JSONLoaded File
    | Send String
    | Export
    | Reload E.Value
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

        DeleteInput ->
            ( { model | keyword = "" }, Cmd.none )

        OnTick newTime ->
            ( { model | time = newTime }, Cmd.none )

        AdjustTimeZone zone ->
            ( { model | zone = zone }, Cmd.none )

        OnDrawerOpen b ->
            let
                drawer_ =
                    { open = b, searchEngines = Array.map trimLink model.drawer.searchEngines, navs = Array.map trimLink model.drawer.navs, saveData = model.drawer.saveData }
            in
            ( { model | drawer = drawer_ }
            , if model.drawer.saveData then
                saveToStorage <| { search = model.drawer.searchEngines, navs = model.drawer.navs }

              else
                Cmd.none
            )

        OnEntryInput page index type_ str ->
            let
                item =
                    case page of
                        Search ->
                            Maybe.withDefault initLink (Array.get index model.drawer.searchEngines)

                        Nav ->
                            Maybe.withDefault initLink (Array.get index model.drawer.navs)

                newItem =
                    case type_ of
                        URL ->
                            { item | url = str }

                        Name ->
                            { item | name = str }

                        ICON ->
                            { item | icon = Just str }

                drawer_ =
                    model.drawer
            in
            case page of
                Search ->
                    ( { model | drawer = { drawer_ | searchEngines = Array.set index newItem drawer_.searchEngines } }, Cmd.none )

                Nav ->
                    ( { model | drawer = { drawer_ | navs = Array.set index newItem drawer_.navs } }, Cmd.none )

        OnEntryAdd page ->
            let
                drawer_ =
                    model.drawer
            in
            case page of
                Search ->
                    ( { model | drawer = { drawer_ | searchEngines = Array.push initLink drawer_.searchEngines } }, Cmd.none )

                Nav ->
                    ( { model | drawer = { drawer_ | navs = Array.push initLink drawer_.navs } }, Cmd.none )

        OnEntryRemove page index ->
            let
                drawer_ =
                    model.drawer
            in
            case page of
                Search ->
                    ( { model | drawer = { drawer_ | searchEngines = removeFromArray index drawer_.searchEngines } }, Cmd.none )

                Nav ->
                    ( { model | drawer = { drawer_ | navs = removeFromArray index drawer_.navs } }, Cmd.none )

        SwitchSaveOption ->
            let
                drawer_ =
                    model.drawer
            in
            ( { model | drawer = { drawer_ | saveData = not drawer_.saveData } }, Cmd.none )

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

        Import ->
            ( model, importJSON )

        Export ->
            ( model, exportJSON { search = model.drawer.searchEngines, navs = model.drawer.navs } model.zone model.time )

        JSONLoaded file ->
            ( model, Task.perform Send (File.toString file) )

        Send str ->
            ( model, send str )

        Reload val ->
            let
                data : SaveData
                data =
                    case D.decodeValue jsonToData val of
                        Ok d ->
                            d

                        Err log ->
                            { search = Array.fromList [ { name = "Error", url = "", icon = Nothing } ], navs = Array.empty }

                newDrawer =
                    { searchEngines = data.search, navs = data.navs, open = model.drawer.open, saveData = model.drawer.saveData }
            in
            ( { initModel | drawer = newDrawer }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


exportJSON : SaveData -> Time.Zone -> Time.Posix -> Cmd msg
exportJSON savedata zone time =
    Download.string ("lunastart_" ++ getTimeString zone time ++ ".json") "application/json" (dataToString savedata)


importJSON : Cmd Msg
importJSON =
    Select.file [ "application/json" ] JSONLoaded



-- SUBSCRIPTIONS
-- 更新时间


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.scrolling then
        Sub.batch [ Time.every 1000 OnTick, receiver Reload, Time.every model.scrollTimeStep Scroll ]

    else
        Sub.batch [ Time.every 1000 OnTick, receiver Reload ]



-- PORTS


port newWindow : String -> Cmd msg


port receiver : (E.Value -> msg) -> Sub msg


port send : String -> Cmd msg


port saveToStorage : SaveData -> Cmd msg



-- port export : SaveData -> Cmd msg
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
                    [ lazy3 searchbar model.curSearchEngine model.searchFocused model.keyword
                    , lazy2 searchSelect model.drawer.searchEngines model.searchSelectOpen
                    ]
                , span [ class "button-arrow to-nav", onClick (ChangePage Nav), style "visibility" arrowVisible ] [ Icons.chevronsDown ]
                ]

            -- Page2
            , div [ class nclass ]
                [ div [ class "main" ] [ lazy nav model.drawer.navs ]
                , span [ class "button-arrow to-nav", onClick (ChangePage Search), style "visibility" arrowVisible ] [ Icons.chevronsUp ]
                ]
            ]
        , settingBtn
        , lazy drawer model.drawer
        ]


settingBtn : Html Msg
settingBtn =
    button [ class "gear", onClick (OnDrawerOpen True) ] [ Icons.settings ]


drawer : Drawer -> Html Msg
drawer d =
    let
        translate =
            if d.open then
                "translateX(0)"

            else
                "translateX(-100%)"

        checkbox =
            if d.saveData then
                Icons.checkSquare

            else
                Icons.square
    in
    div [ class "drawer", style "transform" translate ]
        [ button [ class "drawer__close", onClick (OnDrawerOpen False) ] [ Icons.x ]
        , div [ class "drawer-content" ]
            [ div [ style "padding " "1rem" ]
                [ -- 设置
                  h3 [] [ text "存储" ]
                , div [ class "drawer-save" ] [ button [ onClick SwitchSaveOption ] [ checkbox ], text "将设置保存在 localStorage" ]
                , div [ style "display" "flex" ]
                    [ button [ onClick Import, class "l-button" ] [ Icons.upload, text "导入" ]
                    , button [ onClick Export, class "l-button" ] [ Icons.download, text "导出" ]
                    ]

                --搜索
                , h3 []
                    [ text "搜索引擎设置"
                    , button [ class "drawer-entry__add", onClick (OnEntryAdd Search) ] [ Icons.plusSquare ]
                    ]
                , Keyed.node "ul" [] (Array.toList <| Array.indexedMap (keyedLink Search) d.searchEngines)

                -- 导航
                , h3 []
                    [ text "导航设置"
                    , button [ class "drawer-entry__add", onClick (OnEntryAdd Nav) ] [ Icons.plusSquare ]
                    ]
                , Keyed.node "ul" [] (Array.toList <| Array.indexedMap (keyedLink Nav) d.navs)

                -- 关于
                , h3 [] [ text "关于" ]
                , div [ class "drawer-about" ]
                    [ div [ style "display" "flex" ]
                        [ div [ class "drawer-about__repo", class "l-button" ] [ Icons.github, a [ href "https://github.com/owlzou/start-page", target "_blank" ] [ text "owlzou / start-page" ] ]
                        ]
                    , backgroundCredit
                    ]
                ]
            ]
        ]


keyedLink : Page -> Int -> Link -> ( String, Html Msg )
keyedLink page index link =
    ( String.fromInt index, lazy (renderEntry page index) link )


renderEntry : Page -> Int -> Link -> Html Msg
renderEntry page index link =
    li [ class "drawer-entry" ]
        [ input [ placeholder "名称", type_ "text", value link.name, onInput (OnEntryInput page index Name) ]
            []
        , input [ placeholder "链接", type_ "text", value link.url, onInput (OnEntryInput page index URL) ]
            []
        , case link.icon of
            Just icon ->
                Icons.svgIcon icon

            Nothing ->
                span [] []
        , input [ placeholder "SVG 图标 Path", type_ "text", value <| Maybe.withDefault "" link.icon, onInput (OnEntryInput page index ICON) ]
            []
        , button [ class "drawer-entry__delete", onClick (OnEntryRemove page index) ] [ Icons.minusSquare ]
        ]


timebar : Model -> Html msg
timebar model =
    let
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


searchbar : Link -> Bool -> String -> Html Msg
searchbar curSearchEngine searchFocused keyword =
    let
        op =
            if searchFocused then
                "1"

            else
                "0.3"
    in
    div [ class "searchbar-wrap" ]
        [ div [ class "searchbar", style "opacity" op ]
            [ div [ class "searchbar__select", onClick OnSearchSelectOpen ]
                [ case curSearchEngine.icon of
                    Just path ->
                        Icons.svgIcon path

                    Nothing ->
                        span [] [ text curSearchEngine.name ]
                ]
            , input
                [ class "searchbar__input"
                , type_ "text"
                , value keyword
                , onFocus (OnSearchbarFocus True)
                , onBlur (OnSearchbarFocus False)
                , onInput OnSearchInput
                , onEnter OnSearch
                ]
                []
            , if String.length keyword > 0 then
                button [ class "searchbar__delete", onClick DeleteInput ] [ Icons.delete ]

              else
                span [] []
            , button [ class "searchbar__btn", onClick OnSearch ] [ Icons.search ]
            ]
        ]


searchSelect : Array Link -> Bool -> Html Msg
searchSelect searchEngines searchSelectOpen =
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
            if searchSelectOpen then
                "1"

            else
                "0"
    in
    div [ class "searchbar-list", style "opacity" op ]
        [ Keyed.node "ul" [] (Array.toList <| Array.map keyedRender searchEngines)
        ]


nav : Array Link -> Html msg
nav navs =
    let
        render lks =
            case lks.icon of
                Just icon ->
                    li [] [ a [ href lks.url, target "_blank" ] [ Icons.svgIcon icon, text lks.name ] ]

                Nothing ->
                    li [] [ a [ href lks.url, target "_blank" ] [ text lks.name ] ]

        keyedRender lks =
            ( lks.name, lazy render lks )
    in
    div [ class "nav" ]
        [ Keyed.node "ul" [] (Array.toList (Array.map keyedRender navs)) ]


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


fillNumber : String -> String
fillNumber str =
    if String.length str < 2 then
        "0" ++ str

    else
        str


getTimeString : Time.Zone -> Time.Posix -> String
getTimeString zone time =
    let
        second =
            fillNumber <| String.fromInt (Time.toSecond zone time)

        hour =
            fillNumber <| String.fromInt (Time.toHour zone time)

        minute =
            fillNumber <| String.fromInt (Time.toMinute zone time)

        day =
            fillNumber <| String.fromInt (Time.toDay zone time)

        month =
            toSimpleMonth (Time.toMonth zone time)

        year =
            String.fromInt (Time.toYear zone time)
    in
    year ++ month ++ day ++ hour ++ minute ++ second
