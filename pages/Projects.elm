module Projects (Model, init, Action, update, view, main) where
import String
import Header
import Utils exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)
import Date exposing (..)
import Markdown exposing (..)

projects = [ { project = { name = "Wild Tree Purple Varietal Black Tea of Dehong"
                , category = Black
                , region = Yunnan
                , flavours = []
                , season = Spring
                , year = Just 2013
                , url = Just "http://yunnansourcing.com/en/yunnan-black-teas/2384-light-roast-wild-tree-purple-varietal-black-tea-of-dehong-spring-2013.html"
                }
        , date = "2015-11-19"
        , vendor = YunnanSourcing
        , rating = 9
        , review = "This is a good flavoured black tea, it has a slightly flowery taste but it's not overpowering, one of my favouritex black teas so far"
      }
      , { tea = { name = "Monks Blend"
                , category = Black
                , region = Ceylon
                , flavours = [ Vanilla, Grenadine ]
                , season = UnknownSeason
                , year = Nothing
                , url = Nothing
                }
        , date = "2015-11-03"
        , vendor = DistinctlyTea
        , rating = 7
        , review = "One of the first teas that made me start to appreciate teas, the latest batch isn't as good as the what it was a year 
ago"
      }
      , { tea = { name = "Himalayan"
                , category = Blend [ White, Green, Darjeeling, Herbal ]
                , region = UnknownRegion
                , flavours = [ Corn, Curry, Pineapple ]
                , season = UnknownSeason
                , year = Nothing
                , url = Nothing
                }
        , date = "2015-10-26"
        , vendor = DistinctlyTea
        , rating = 3
        , review = "Not very interesting, and the after taste isn't that great either "
        }
      ]

type Flavour = Vanilla | Grenadine | Corn | Curry | Pineapple

type Season = Spring | Summer | Autumn | Winter | UnknownSeason

type Region = Keemum
            | Yunnan
            | LapsangSouchong
            | Assam
            | DarjeelingDistrict
            | Nilgiri
            | Ceylon
            | Sumatra
            | Kenya
            | Java
            | Nepal
            | UnknownRegion

type PuErhCategory = Maocha | Raw | Ripened | AgedRaw

type Category = White
              | Yellow
              | Green
              | Oolong
              | Black
              | PuErh PuErhCategory
              | Darjeeling
              | Herbal
              | Blend (List Category)
              
type alias Tea = { name : String
                 , category : Category
                 , region : Region
                 , flavours : List Flavour
                 , season : Season
                 , year : Maybe Int
                 , url : Maybe String
                 }

type Vendor = DistinctlyTea | YunnanSourcing
               
type alias LogEntry = { date : String
                      , tea : Tea
                      , vendor : Vendor
                      , review : String
                      , rating : Int
                      }


type alias Model = { log : List LogEntry
                   , header : Header.Model }
                 
init = { log = log
       , header = Header.init }

type Action = NoOp | ModifyHeader Header.Action

update : Action -> Model -> Model
update action model = case action of
                        NoOp -> model

centered styles =
  styles
    |> Display.display Display.Flex
    |> Flex.justifyContent Flex.JCCenter
    |> Flex.alignItems Flex.AICenter

last : List a -> Maybe a
last xs = case xs of
            [] -> Nothing
            [x] -> Just x
            _::rest -> last rest
viewRegion region = case region of
                      UnknownRegion -> ", I don't know which region this tea is from"
                      _             -> " from the " ++ toString region ++ " region"

viewTeaCategory category = case category of
                             Blend blends ->
                               let
                                 listPart = String.join ", " <| List.map viewTeaCategory <| List.take (List.length blends - 1) blends
                                 lastPart = case last blends of
                                              Nothing -> ""
                                              Just cat -> " and " ++ viewTeaCategory cat
                               in
                                 "Blend of " ++ listPart ++ lastPart
                             _ -> toString category
       
viewTea : Signal.Address Action -> Tea -> Html
viewTea address tea =
  let
    teaName = case tea.url of
                Nothing -> text tea.name
                Just url -> a [ href url ] [ text tea.name ]
  in
    div [  ] [ u [] [ teaName ]
             , br [] []
             , text <| viewTeaCategory tea.category ++ " tea " ++ viewRegion tea.region
             ]
inline = Display.display Display.InlineBlock

viewStar = div [ style [ ("margin", "2px")
                       , ("display", "inline-block") ]] [text "☆"]
         
viewRating : Signal.Address Action -> Int -> Html
viewRating address rating = div [] <| List.repeat rating viewStar
viewVender address vender =
  let
    url = case vender of
            DistinctlyTea -> "http://distinctlytea.com/"
            YunnanSourcing -> "https://yunnansourcing.com/"
  in
    div [] [ text <| "I got this tea from "
           , a [href url] [text <| toString vender]
           ]
                            
viewLogEntry : Signal.Address Action -> LogEntry -> Html
viewLogEntry address log =
  let styles =
        [("borderTop", "1px solid black")]
          |> Font.size 12
          |> Padding.all 10 0 10 0
          |> Margin.all 10 10 10 10
  in
    div [ style styles ]
          [ div [style <| ([] |> BorderBottom.width 1 |> BorderBottom.color black)]
                  [ div [style <| ([] |> inline) ] [text log.date]
                  , div [style <| ([] |> Float.float Float.Right) ] [ viewRating address log.rating ] ]
          , viewTea address log.tea
          , toHtml log.review
          , viewVender address log.vendor
          ]

view : Signal.Address Action -> Model -> Html
view address model =
  let styles =
        []
          |> centered
  in
    div [] [ css "../style.css"
           , Header.view (Signal.forwardTo address ModifyHeader) model.header
           , div [ style styles ] [ div [] <| List.map (viewLogEntry address)  model.log ] ]

actionMailbox : Signal.Mailbox Action
actionMailbox = Signal.mailbox NoOp
                     
models = foldp update init actionMailbox.signal

main = map (view actionMailbox.address) models
