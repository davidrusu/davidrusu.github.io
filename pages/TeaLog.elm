module TeaLog (Model, init, Action, update, view, main) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)
import Date exposing (..)
import Markdown exposing (..)
import Css
import Css.Flex as Flex
import Css.Display as Display
import Css.Background as Background
import Css.Shadow as Shadow
import Css.Text as Text
import Css.Font as Font
import Css.Padding as Padding
import Css.Margin as Margin
import Css.Dimension as Dim
import Css.Border.Style as BorderStyle
import Css.Border.Top as BorderTop
import Color exposing (..)

log = [ { date = "2015-10-26"
        , tea = { name = "himalayan"
                , category = Blend [ White, Green, Darjeeling UnknownSeason, Herbal ]
                , region = UnknownRegion
                }
        , vendor = DistinctlyTea
        , rating = 3
        , price = 2
        , review = "Not very memorable, tries to do to much, it's even got curry leaves"
        }
      , { date = "2015-10-26"
        , tea = { name = "himalayan"
                , category = Blend [ White, Green, Darjeeling UnknownSeason, Herbal ]
                , region = UnknownRegion
                }
        , vendor = DistinctlyTea
        , rating = 3
        , price = 2
        , review = "Not very memorable, tries to do to much, it's even got curry leaves"
        }
      ]


type Season = EasterFlush | SpringFlush | AutumnFlush | UnknownSeason

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
              | Darjeeling Season
              | Herbal
              | Blend (List Category)
              
type alias Tea = { name : String
                 , category : Category
                 , region : Region
                 }

type Vendor = DistinctlyTea | YunnanSourcing
               
type alias LogEntry = { date : String
                      , tea : Tea
                      , vendor : Vendor
                      , review : String
                      , rating : Int
                      , price : Float -- price per 50 grams
                      }


type alias Model = { log : List LogEntry }
                 
init = { log = log }

type Action = NoOp

update : Action -> Model -> Model
update action model = case action of
                        NoOp -> model

centered styles =
  styles
    |> Display.display Display.Flex
    |> Flex.justifyContent Flex.JCCenter
    |> Flex.alignItems Flex.AICenter
                                
viewTea : Signal.Address Action -> Tea -> Html
viewTea address tea = div [  ] [ text tea.name
                               , br [] []
                               , text <| toString tea.category
                               , text <| toString tea.region
                               ]
                      
viewLogEntry : Signal.Address Action -> LogEntry -> Html
viewLogEntry address log =
  let styles =
        []
          |> Font.size 12
          |> Padding.all 10 0 10 0
          |> Margin.all 10 10 10 10
          |> BorderTop.style BorderStyle.Solid
  in
    div [ style styles ] [ div [] [text log.date]
                         , text <| toString log.vendor
                         , text <| toString log.rating
                         , text <| toString log.price
                         , viewTea address log.tea
                         , toHtml log.review
                         ]

view : Signal.Address Action -> Model -> Html
view address model =
  let styles =
        []
          |> centered
  in
    div [ style styles ] [ div [] <| List.map (viewLogEntry address)  model.log ]

actionMailbox : Signal.Mailbox Action
actionMailbox = Signal.mailbox NoOp
                     
models = foldp update init actionMailbox.signal

main = map (view actionMailbox.address) models
