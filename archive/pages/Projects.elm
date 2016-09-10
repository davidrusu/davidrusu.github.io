module Projects (Model, init, Action, update, view, main) where
import String
import Header
import Utils exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)
import Date exposing (..)
import Markdown exposing (..)

projects : List Project
projects = [ { name = "Rooster Engine"
             , description = """Rooster Engine is a Game Engine + Physics Engine written entirely from the ground up. The physics engine features continuous collision detection which means you will never miss a collision no matter how fast or small your shapes are."""
             , tech = ["Game Engine", "Rigid Body Physics", "Continuous Collision Detection", "Java"]
             , url = Nothing
             , code = Nothing
             , thumbnail = "./rooster_engine.png"
             }
           , { name = "Off The Grid"
             , description = """Off The Grid is an iOS app for realtime offline collaboration. We used the iOS Multipeer Connectivity Framework to create a real time offline collaborative whiteboard. This project was completed in 36 hours at Hack Western 2 where we were awarded a top 6 finish."""
             , tech = ["iOS", "Multipeer Networking", "Swift", "P2P Networking"]
             , url = Just "http://devpost.com/software/off-the-grid-lhgj8q"
             , code = Just "https://github.com/davidozhang/off-the-grid"
             , thumbnail = "./off_the_grid.png"
             }
           , { name = "Type The Web"
             , description = """Type The Web is a Firefox add-on for improving your typing speed using the content of any website. I built this addon while I was learning the Colemak keyboard layout because I found the existing typing tutors tedious and boring. I wanted a something where I go on Hacker News and be able to type out the content."""
             , tech = ["Firfox Addon", "RamdaJS", "JavaScript"]
             , url = Just "https://addons.mozilla.org/en-US/firefox/addon/type-the-web/"
             , code = Just "https://github.com/davidrusu/type-the-web"
             , thumbnail = "./type_the_web.png"
             }
           , { name = "Laurier Course Graph"
             , description = """Laurier Course Graph is a website with an interactive graph of the dependencies between courses at Laurier. You can use it to quickly understand the structure of the graph and to plan your course selections."""
             , tech = ["ProcessingJS", "JavaScript", "Python"]
             , url = Just "https://davidrusu.github.io/LaurierCourseGraph"
             , code = Just "https://github.com/davidrusu/LaurierCourseGraph"
             , thumbnail = "./laurier_course_graph.png"
             }
           , { name = "Markov Chain Text Suggester"
             , description = """Ever wonder how your phone can predict what you are trying to type? Well it's a Markov Chain that's doing the heavy lifting. Here I implemented one such text suggester using a markov chain.

This was also an experiment in writing some non trivial algorithms in Elm, it was a great success, I really like Elm :)"""
             , tech = ["Elm", "Markov Chain"]
             , url = Just "https://davidrusu.github.io/markov_chain"
             , code = Just "https://github.com/davidrusu/markov_chain"
             , thumbnail = "./markov_chains.png"
             }
           ]

type alias Project = { name : String
                     , description : String
                     , tech : List String
                     , thumbnail : String
                     , url: Maybe String
                     , code : Maybe String
                     }
               
type alias Model = { projects : List Project
                   , header : Header.Model
                   }
                 
init = { projects = projects
       , header = Header.init
       }

type Action = NoOp | ModifyHeader Header.Action

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    ModifyHeader headerAction -> { model | header = Header.update headerAction model.header }

last : List a -> Maybe a
last xs = case xs of
            []  -> Nothing
            [x] -> Just x
            _::rest -> last rest

viewTag : Signal.Address Action -> String -> Html
viewTag address tag = div [ class "tag" ] [ text tag ]

viewTitle : Signal.Address Action -> Project -> Html
viewTitle address project =
  let
    name = case project.url of
             Nothing -> text project.name
             Just url -> a [ href url ] [ text project.name ]
    github = case project.code of
               Nothing -> div [] []
               Just code -> a [ class "icon_btn",  href code ] [ img [src "./GitHub-Mark-32px.png"] [] ]
    link = case project.url of
             Nothing -> div [] []
             Just url -> a [ class "icon_btn", href url ] [ img [src "./link_icon.png"] [] ]
  in
    div [ class "project_header" ]
          [ div [class "project_name"] [ name ]
          , div [class "project_links"] [link, github]
          ]

                             
                      
viewProject : Signal.Address Action -> Project -> Html
viewProject address project = 
    div [class "project"]
          [ img [class "project_logo", src project.thumbnail] []
          , div [class "project_details"]
                  [ viewTitle address project
                  , toHtml project.description
                  , div [class "tag-list"]
                          <| List.map (viewTag address) project.tech
                  ] 
          ]

view : Signal.Address Action -> Model -> Html
view address model =
    div [] [ css "../style.css"
           , Header.view (Signal.forwardTo address ModifyHeader) model.header
           , div
             [ class "content" ]
             [ div [] <| List.map (viewProject address)  model.projects ] ]

actionMailbox : Signal.Mailbox Action
actionMailbox = Signal.mailbox NoOp
                     
models = foldp update init actionMailbox.signal

main = map (view actionMailbox.address) models
