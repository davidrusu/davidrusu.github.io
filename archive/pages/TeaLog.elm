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

log : List LogEntry
log = [ -- { tea = { name = "Buddha's Hand 'Fo Shou' Wu Yi Rock"
--                 , category = Oolong
--                 , region = Fujian
--                 , flavours = []
--                 , season = Spring
--                 , year = 2015
--                 , url = Just 
--                 }
--         , date = "2015-12-24"
--         , vendor = YunnanSourcing
--         , rating = 
--         , review = """
-- leafs a bit Milky smelling
-- """
--         },
        { tea = { name = "Da Hu Sai Village Wild Arbor Black Tea of Yunnan"
                , category = Black
                , region = Yunnan
                , flavours = []
                , season = Autumn
                , year = Just 2015
                , url = Just "http://yunnansourcing.com/en/yunnan-black-teas/3696-da-hu-sai-village-wild-arbor-black-tea-of-yunnan-autumn-2015.html"
                }
        , date = "2016-1-10"
        , vendor = YunnanSourcing
        , rating = 8
        , review = """
Ok, first review of 2016, let's go!
This one is one of the black teas that came in the December batch of the Yunnan Sourcing Dark Tea Club, the tea leafs are a dark grey with some blond strands. They don't seem to have much of an aroma, I tried crushing some of the leafs to see if increasing the surface area would help, but no, not much of a scent, just a little hint of flowers.

The tea liquour is a very dark reddish brown, almost opaque, I'm not sure if it's the opaqueness, but the tea seems to have a bit more viscosity than other teas. As for the aroma, it is more pronounced once brewed, it's a flowery scent. The tea, feels a bit viscous and has a bit of a tang with hints of flowers, it's got a nice, simple flavour. The tea is quite smooth, the slight viscosity probably helps with this. Overall, it's a comfortable and yummy tea, it'll warm you right up :)

The leafs also last a good number of brews, I was able to squeeze 6 cups out a batch.
"""
        }
      , { tea = { name = "Iron Goddess of Mercy"
                , category = Oolong
                , region = Fujian
                , flavours = []
                , season = UnknownSeason
                , year = Nothing
                , url = Just "http://shop.distinctlytea.com/store/product/3400/IRON-GODDESS-OF-MERCY-50G/"
                }
        , date = "2015-12-18"
        , vendor = DistinctlyTea
        , rating = 7
        , review = """
This tea has been sitting in the pantry for over a year now, I found it tucked away in the back and decided to give it a try. It seems to be a common meme among oolongs tea to be have a name referencing iron or rock, the last two oolongs I had were 'Iron Arhat' and 'Wu Yi Rock' (didn't write a log for this one yet).

The leafs from this one has a bit of a musty smell, not sure if that's just cause they're old. It's a rolled leaf that unfurls during the infusion process. The tea does leave a bit of a iron taste in the mouth, I didn't get that from the 'Iron Arhat' tea. It has a lighter taste than the other oolongs so it's probably not as oxidized.

The taste is good, but doesn't survive as many infusions as some of the other oolongs, I got 2 good infusions out of the leafs.
"""
        }
      , { tea = { name = "Mi Lan Xiang * Roasted AA Grade Dan Cong"
                , category = Oolong
                , region = Yunnan
                , flavours = []
                , season = Autumn
                , year = Just 2014
                , url = Just "http://yunnansourcing.com/en/oolongtea/3245-roasted-aa-grade-dan-cong-oolong-tea-mi-lan-xiang.html"
                }
        , date = "2015-12-15"
        , vendor = YunnanSourcing
        , rating = 7
        , review = """
This one is also from Octobers batch from Yunnan Sourcing's dark tea club.

This Oolong starts a bit bitter but after 2-3 brews quickly becomes a wonderfully mellow tea. I infused the same leaves over 7 times and it still had a good taste.

I like drinking this tea when I'm coding as the same leafs last a long time.
"""
        }
      , { tea = { name = "Menghai 7592 501"
                , category = PuErh Ripe
                , region = Yunnan
                , flavours = []
                , season = Winter
                , year = Just 2005
                , url = Just "http://yunnansourcing.com/en/menghaiteafactory/3624-2005-menghai-7592-501-ripe-pu-erh-tea-cake.html"
                }
        , date = "2015-12-15"
        , vendor = YunnanSourcing
        , rating = 9
        , review = """
I got this tea in Octobers batch of the Yunnan Sourcing Dark Tea club. I really liked this tea, it was my first ripe pu-erh and was totally different from any other tea I've tried.

The cake is a dark matte brown with a smokey smell, almost like smoked bacon. Once brewed the smell changes completely, a friend described it as sweat, but I find it to be more of an earthy nutty smell. The color of the tea is a dark nearly opaque purple brown. The tea has an incredibly nutty taste, it's sooo nutty, tastes like your drinking walnuts. I was really not expecting it to be so nutty.

I have another ripe pu-erh that just came in from December's batch of the Dark Tea club, I'm looking forward to trying it.
"""
        }
      , { tea = { name = "Tieluohan 'Iron Arhat' Premium Wu Yi Shan Rock"
                , category = Oolong
                , region = WuyiMountains
                , flavours = []
                , season = Spring
                , year = Just 2015
                , url = Just "http://yunnansourcing.com/en/wuyimountainrockoolongs/3625-tie-luo-han-iron-arhat-premium-wu-yi-shan-rock-oolong-tea.html"
                }
        , date = "2015-12-14"
        , vendor = YunnanSourcing
        , rating = 9
        , review = """
This was one of two oolongs that came in Octobers batch of the Yunnan Sourcing dark tea club. It was a great first batch for me from this tea club, I'm really happy with the teas I got but it's a little expensive so I'll probably stop after next months batch

This tea had some really nice leafs, long, matte black with a musky aroma. The tea itself is very mellow with no bitterness what so ever, it has a slightly rocky taste and leaves a bit of a tacky texture in the mouth. I can get about 5 brews out this tea before it's lost it's character.

*I love oolongs!*
"""
      },
      { tea = { name = "Wild Tree Purple Varietal Black Tea of Dehong"
                , category = Black
                , region = Yunnan
                , flavours = []
                , season = Spring
                , year = Just 2013
                , url = Just "http://yunnansourcing.com/en/yunnan-black-teas/2384-light-roast-wild-tree-purple-varietal-black-tea-of-dehong-spring-2013.html"
                }
        , date = "2015-11-19"
        , vendor = YunnanSourcing
        , rating = 7
        , review = "This is a good flavoured black tea, it has a slightly flowery taste but not too much, one of my favourite  black teas so far"
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
        , rating = 6
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

type Region = Keemun
            | Yunnan
            | Fujian
            | LapsangSouchong
            | Assam
            | DarjeelingDistrict
            | Nilgiri
            | Ceylon
            | Sumatra
            | Kenya
            | Java
            | Nepal
            | WuyiMountains
            | UnknownRegion

type PuErhCategory = Maocha | Raw | Ripe | AgedRaw

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
                        ModifyHeader headerAction -> { model | header = Header.update headerAction model.header }

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
                      UnknownRegion      -> "I don't know which region this tea is from"
                      LapsangSouchong    -> "Lapsang souchong"
                      DarjeelingDistrict -> "Darjeeling District"
                      WuyiMountains      -> "Wuyi Mountains"
                      _                  -> toString region

viewTeaCategory category =
  case category of
    PuErh puerhType -> case puerhType of
                         Maocha -> "Maocha"
                         Raw -> "Raw Pu-erh"
                         Ripe -> "Ripe Pu-erh"
                         AgedRaw -> "Aged Raw Pu-erh"
    Blend blends ->
      let
        listPart =
          String.join ", "
                  <| List.map viewTeaCategory
                  <| List.take (List.length blends - 1) blends
        lastPart = case last blends of
                     Just category -> " and " ++ viewTeaCategory category
                     Nothing -> ""
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
    div [ class "tea_description" ] [ u [] [ teaName ]
             , br [] []
             , text <| viewTeaCategory tea.category ++ ", " ++ viewRegion tea.region
             ]

inline = Display.display Display.InlineBlock

viewStar = div [ style [ ("margin-right", "2px")
                       , ("display", "inline-block") ]] [text "★"]
         
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
          [ div [ class "log_entry_header"]
                  [ div [style <| ([] |> inline) ] [text log.date]
                  , div [style <| ([] |> Float.float Float.Right) ] [ viewRating address log.rating ] ]
          , viewTea address log.tea
          , toHtml log.review
          , viewVender address log.vendor
          ]
viewTeaLog address model =
  div [ class "list" ] <| List.map (viewLogEntry address)  model.log

view : Signal.Address Action -> Model -> Html
view address model =
  div [ ] [ css "../style.css"
          , Header.view (Signal.forwardTo address ModifyHeader) model.header
          , div [ class "content" ]  [ viewTeaLog address model ]
          ]

actionMailbox : Signal.Mailbox Action
actionMailbox = Signal.mailbox NoOp
                     
models = foldp update init actionMailbox.signal

main = map (view actionMailbox.address) models
