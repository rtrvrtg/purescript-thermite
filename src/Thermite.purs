module Thermite
  ( simpleSpec
  , componentWillMount
  , createClass
  , displayName
  , render
  ) where

import DOM

import Data.Maybe

import Control.Monad.Eff

import Thermite.Html
import Thermite.Internal
import Thermite.Types
import Thermite.Action

simpleSpec :: forall m state props action. state -> PerformAction props action m -> Render state props action -> Spec m state props action
simpleSpec initialState performAction render = simpleSpecImpl
    { initialState: initialState
    , performAction: performAction
    , render: render
    , componentWillMount: Nothing
    , displayName: Nothing
    }

foreign import componentWillMount """
function componentWillMount(action) {
  return function(spec) {
    spec.componentWillMount = action;
    return spec;
  }
}
""" :: forall m state props action
    .  action
    -> Spec m state props action
    -> Spec m state props action

foreign import displayName """
function displayName(displayName) {
  return function(spec) {
    spec.displayName = displayName;
    return spec;
  }
}
""" :: forall m state props action
    .  String
    -> Spec m state props action
    -> Spec m state props action

createClass :: forall eff state props action. Spec (Action eff state) state props action -> ComponentClass props eff
createClass = createClassImpl runAction maybe

render :: forall props eff. ComponentClass props eff -> props -> Eff (dom :: DOM | eff) Unit
render = renderImpl

foreign import simpleSpecImpl """
function simpleSpecImpl(specRecord) {
  return {
    initialState:       specRecord.initialState,
    performAction:      specRecord.performAction,
    render:             specRecord.render,
    componentWillMount: specRecord.componentWillMount,
    displayName:        specRecord.displayName
  };
}
""" :: forall m state props action
    .  SpecRecord m state props action
    -> Spec m state props action
