module TeaLog (Model, init, Action, update, view, main) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)
import Date exposing (..)
import Markdown exposing (..)

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
                 , region : Region }

type Vendor = DistinctlyTea | YunnanSourcing
               
type alias LogEntry = { date : String
                      , tea : Tea
                      , vendor : Vendor
                      , review : String
                      , rating : Int
                      , price : Float -- price per 50 grams
                      }


type alias Model = { log : List LogEntry }

init = { log = [
          { date = "2015-10-26"
          , tea = { name = "himalayan"
                  , category = Blend [ White, Green, Darjeeling UnknownSeason, Herbal ]
                  , region = UnknownRegion
                  }
          , vendor = DistinctlyTea
          , rating = 3
          , price = 2
          , review = """

Not very memorable, tries to do to much, it's even got curry leaves 

"""} ] }

type Action = NoOp

update : Action -> Model -> Model
update action model = case action of
                        NoOp -> model

viewTea : Signal.Address Action -> Tea -> Html
viewTea address tea = div [] [ text tea.name
                             , text <| toString tea.category
                             , text <| toString tea.region
                             ]
                                
viewLogEntry : Signal.Address Action -> LogEntry -> Html
viewLogEntry address log = div [] [ text log.date
                                  , text <| toString log.vendor
                                  , text <| toString log.rating
                                  , text <| toString log.price
                                  , viewTea address log.tea
                                  , toHtml log.review
                                  ]

view : Signal.Address Action -> Model -> Html
view address model = div [] <| List.map (viewLogEntry address)  model.log

actionMailbox : Signal.Mailbox Action
actionMailbox = Signal.mailbox NoOp
                     
models = foldp update init actionMailbox.signal

main = map (view actionMailbox.address) models
