import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)
import Header

basePath = "https://davidrusu.github.io"
projectsPath = "https://github.com/davidrusu" -- basePath ++ "/projects.html"
statsPath = "http://davidrusu.github.io/mastery/" -- basePath ++ "/stats.html"
teasPath = basePath ++ "/teas.html"
               
type alias Model = { header : Header.Model }

initHeader = Header.init 
               ("David Rusu", basePath)
               [ ("Projects", projectsPath)
               , ("Stats", statsPath)
               , ("Tea Log", teasPath) ] -1

init = { header = initHeader }

type Action = NoOp | ModifyHeader Header.Action

actionMailbox : Signal.Mailbox Action
actionMailbox = mailbox NoOp

update : Action -> Model -> Model
update action model = case action of
                        NoOp -> model

viewHeader a m =
  Header.view (Signal.forwardTo a ModifyHeader) m.header

view address model =
  div
    [class "content"]
    [ viewHeader address model
    , div
        [class "greeter"]
        [ text "hey ;)"]
    ]
models = Signal.foldp update init actionMailbox.signal

main = Signal.map (view actionMailbox.address) models
