import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)
import Header
import Spiral
import Signal.Extra exposing (foldp')
          
basePath = "https://davidrusu.github.io"
projectsPath = "https://github.com/davidrusu" -- basePath ++ "/projects.html"
statsPath = "http://davidrusu.github.io/mastery/" -- basePath ++ "/stats.html"
teasPath = basePath ++ "/teas.html"

type alias Model = { header : Header.Model
                   , spiral : Spiral.Model }

initHeader = Header.init 
               ("David Rusu", basePath)
               [ ("Projects", projectsPath)
               , ("Stats", statsPath)
               , ("Tea Log", teasPath) ] -1

init = { header = initHeader
       , spiral = Spiral.init }
 
type Action = NoOp | ModifyHeader Header.Action | Spiral Spiral.Model

actionMailbox : Signal.Mailbox Action
actionMailbox = mailbox NoOp

update : Action -> Model -> Model
update action model = case action of
                        NoOp           -> model
                        ModifyHeader a -> { model | header <- Header.update a model.header }
                        Spiral spiral  -> { model | spiral <- spiral }

viewHeader a m = Header.view (Signal.forwardTo a ModifyHeader) m.header

view address model =
  div
    [class "content"]
    [ viewHeader address model
    , div
        [ class "greeter" ]
        [ fromElement (Spiral.view model.spiral) ]
    ]

spiralSignal = Signal.map (Spiral) Spiral.modelSignal

modelSignal = foldp' update (\a -> update a init)  <| Signal.merge spiralSignal actionMailbox.signal

main = Signal.map (view actionMailbox.address) modelSignal
