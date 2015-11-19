module TeaLog (Model, init, Action, update, view, main) where
import String
import Header
import Utils exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)
import Date exposing (..)
import Markdown exposing (..)
import Css
import Css.Flex as Flex
import Css.Float as Float
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
import Css.Border.Bottom as BorderBottom
import Css.Position as Position
import Color exposing (..)

log = [ { tea = { name = "Monks Blend"
                , category = Black
                , region = Ceylon
                , flavours = [ Vanilla, Grenadine ]
                }
        , date = "2015-11-03"
        , vendor = DistinctlyTea
        , url = Nothing
        , rating = 7
        , review = "One of the first teas I really got into, the latest batch isn't as good as the what it was a year ago, it's a bit more bitter now"
        }
      , { tea = { name = "Himalayan"
                , category = Blend [ White, Green, Darjeeling UnknownSeason, Herbal ]
                , region = UnknownRegion
                , flavours = [ Corn, Curry, Pineapple ]
                }
        , date = "2015-10-26"
        , vendor = DistinctlyTea
        , url = Nothing
        , rating = 3
        , review = "Not very good, also not a very good aftertaste, I blame the big ingredients list "
        }
      ]

type Flavour = Vanilla | Grenadine | Corn | Curry | Pineapple

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
                 , flavours : List Flavour
                 }

type Vendor = DistinctlyTea | YunnanSourcing
               
type alias LogEntry = { date : String
                      , tea : Tea
                      , vendor : Vendor
                      , review : String
                      , rating : Int
                      , url : Maybe String
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
                      UnknownRegion -> ", I don't know where this tea is from :("
                      _             -> " from the " ++ toString region ++ " region"

viewTeaCategory category = case category of
                             Darjeeling UnknownSeason -> "Darjeeling"
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
viewTea address tea = div [  ] [ u [] [text tea.name]
                               , br [] []
                               , text <| "A " ++ viewTeaCategory tea.category ++ " tea " ++ viewRegion tea.region
                               ]
inline = Display.display Display.InlineBlock

viewStar = div [ style [ ("margin", "2px")
                       , ("display", "inline-block") ]] [text "☆"]
         
viewRating : Signal.Address Action -> Int -> Html
viewRating address rating = div [] <| List.repeat rating viewStar
viewVender address vender = div [] [text <| "I got this tea from " ++ toString vender]
                            
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
