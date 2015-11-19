
import Utils exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)
import Header
import Curve
import Signal.Extra exposing (foldp')
          

type alias Model = { header : Header.Model
                   , curve : Curve.Model }


init = { header = Header.init
       , curve = Curve.init }
 
type Action = NoOp | ModifyHeader Header.Action | Curve Curve.Model

actionMailbox : Signal.Mailbox Action
actionMailbox = mailbox NoOp

update : Action -> Model -> Model
update action model = case action of
                        NoOp           -> model
                        ModifyHeader a -> { model | header <- Header.update a model.header }
                        Curve curve    -> { model | curve <- curve }

viewHeader a m = Header.view (Signal.forwardTo a ModifyHeader) m.header

view address model =
  div
    [class "content"]
    [ css "style.css"
    , viewHeader address model
    , div
        [ class "greeter" ]
        [ fromElement (Curve.view model.curve) ]
    ]

curveSignal = Signal.map (Curve) Curve.modelSignal

modelSignal = foldp' update (\a -> update a init)  <| Signal.mergeMany [ curveSignal, actionMailbox.signal ]

main = Signal.map (view actionMailbox.address) modelSignal
