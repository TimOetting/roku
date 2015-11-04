# onReady = ->
#   angular.bootstrap document, [ 'roku-app' ]
Games = new (Mongo.Collection)('games')
if Meteor.isClient
  angular.module 'roku-app', [ 'angular-meteor' ]
  # if Meteor.isCordova
  #   angular.element(document).on 'deviceready', onReady
  # else
  #   angular.element(document).ready onReady
  angular.module('roku-app').controller('GameCtrl', [
    '$scope'
    '$meteor'
    '$timeout'
    ($scope, $meteor, $timeout) ->
      $scope.selectedGameTokenId = {}
      console.log '$meteor'
      console.log $meteor
      $scope.$meteorSubscribe 'games'
      .then ()->
          $scope.game = $scope.games['0']
          console.log '$scope.game'
          console.log $scope.game
      $scope.games = $meteor.collection ()->
        Games.find()

      $scope.selectGameToken = (tokenId) ->
        tokens = $scope.game.board.gameTokens
        for token in tokens
          token.selected = false
        tokens[tokenId].selected = true
        $scope.selectedGameTokenId = tokenId
        console.log 'Token ausgewählt:'
        console.log tokens[tokenId]
        # $scope.possibleActions = tokens[tokenId].possibleActions

      $scope.attack = (attackerId, attack) ->
        console.log 'angriff'
        $meteor.call 'attack', angular.copy($scope.game), attackerId, attack.targetId

      $scope.move = (x,y) ->
        console.log 'move'
        newPos = 
          x: x
          y: y
        $meteor.call 'move', angular.copy($scope.game), $scope.selectedGameTokenId, newPos

      $scope.newGame = () ->
        $meteor.call 'newGame'
        .then ()->
          $meteor.call('getLastGame')
          .then (data)->
            $scope.game = data
          , (error) ->
            console.log error

      $scope.hexPosToPixel = (pos) ->
        hexPosToPixel(pos)

  ]).controller('GameTokenCtrl', [
    '$scope'
    '$meteor'
    ($scope, $meteor) ->
      $scope.gameToken.weapons = []
      $scope.$watch 'gameToken.position', (newValue, oldValue) ->
        $scope.gameToken.weapons = []
        $scope.gameToken.pixPos = hexPosToPixel($scope.gameToken.position)
        mapSidesToWeapons = ->
          for side in $scope.gameToken.sides
            side.weaponName = 'shield' if side.weapon is 0
            side.weaponName = 'sword' if side.weapon is 1
            side.weaponName = 'arrow' if side.weapon is 2
        mapSidesToWeapons()
      , true
      # $scope.$watch 'gameToken.possibleActions.moves', (newValue, oldValue) ->
      #   fixLength(newValue)
      # , true
      $scope.$watch 'gameToken.possibleActions', (newValue, oldValue) ->
        fixLength(newValue.moves)
        fixLength(newValue.swordAttacks)
        fixLength(newValue.arrowAttacks)
      , true

  ]).directive('gameToken', () ->
    restrict: 'E'
    templateUrl: 'gameToken.ng.html'
    controller: 'GameTokenCtrl'
  ).directive('gameTokenBaseSvg', () ->
    restrict: 'E'
    templateUrl: 'gameTokenBaseSvg.ng.html'
  ).directive('gameTokenWeaponArrowSvg', () ->
    restrict: 'E'
    templateUrl: 'gameTokenWeaponArrow.ng.html'
  ).directive('gameTokenWeaponSwordSvg', () ->
    restrict: 'E'
    templateUrl: 'gameTokenWeaponSword.ng.html'
  ).directive('gameTokenWeaponShieldSvg', () ->
    restrict: 'E'
    templateUrl: 'gameTokenWeaponShield.ng.html'
  ).directive('uiSwordAttackButton', () ->
    restrict: 'E'
    templateUrl: 'uiSwordActionButton.ng.html'
  ).directive('uiArrowAttackButton', () ->
    restrict: 'E'
    templateUrl: 'uiArrowActionButton.ng.html'
  ).directive('uiMoveButton', () ->
    restrict: 'E'
    templateUrl: 'uiMoveActionButton.ng.html'
  )

fixLength = (a) ->
  count = 0
  for move, i in a
    if move?
      count = i+1
  a.length = count #Beim überschreiben des Gameobjects wurde length nicht aktualisiert. Aus Gründen.

hexPosToPixel = (pos) ->
  posX = 75 * 3/2 * pos.x
  posY = 75 * Math.sqrt(3) * pos.y
  if (Math.abs(pos.x) % 2 == 1)
    posY += (75 * Math.sqrt(3)) / 2
  pixPos =
    x: posX
    y: posY

Meteor.methods
  newGame: (id) ->
    if Meteor.isServer
      RokuGame = Meteor.npmRequire('roku-game')
      game = RokuGame.createNewGame()
      Games.insert game
  attack: (game, attackerId, targetId) ->
    if Meteor.isServer
      RokuGame = Meteor.npmRequire('roku-game')
      game = RokuGame.attack(game, attackerId, targetId)
      Games.update game._id, {
        $set: game
      }
  move: (game, tokenId, position) ->
    if Meteor.isServer
      RokuGame = Meteor.npmRequire('roku-game')
      game = RokuGame.move(game, tokenId, position)
      Games.update game._id, {
        $set: game
      }
  getLastGame: () ->
    # lastGame = Games.find({}, {sort: {_id: -1}, limit: 1});
    lastGame = Games.findOne({}, {sort: {createdAt: -1, limit: 1}});

if Meteor.isServer
  Meteor.publish 'games', ()->
    # return Games.findOne({}, {sort: {createdAt: -1, limit: 1}});
    # Games.find()
    Games.find({_id: 'EmjtsA7g9g4Mhe9YD'})

