onReady = ->
  angular.bootstrap document, [ 'roku-app' ]
  return

Games = new (Mongo.Collection)('games')
if Meteor.isClient
  angular.module 'roku-app', [ 'angular-meteor' ]
  if Meteor.isCordova
    angular.element(document).on 'deviceready', onReady
  else
    angular.element(document).ready onReady
  angular.module('roku-app').controller 'GameCtrl', [
    '$scope'
    '$meteor'
    ($scope, $meteor) ->
      $scope.games = $meteor.collection(Games);

      $scope.newGame = (id) ->
        $meteor.call 'newGame', id
        return
  ]
Meteor.methods
  newGame: (id) ->
    Games.insert
      id: id
      activePlayer: 0
      board: {}
      players: []
    return