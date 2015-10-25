onReady = ->
  angular.bootstrap document, [ 'roku-app' ]

Games = new (Mongo.Collection)('games')
if Meteor.isClient
  angular.module 'roku-app', [ 'angular-meteor' ]
  if Meteor.isCordova
    angular.element(document).on 'deviceready', onReady
  else
    angular.element(document).ready onReady
  angular.module('roku-app').controller('GameCtrl', [
    '$scope'
    '$meteor'
    '$timeout'
    ($scope, $meteor, $timeout) ->
      $scope.selectedGameTokenId = {}
      $scope.possibleMoves = {}
      $scope.games = $meteor.collection(Games);
      $scope.game = {}

      console.log '$scope.game'
      console.log $scope.game

      $scope.selectGameToken = (tokenId) ->
        tokens = $scope.game.board.gameTokens
        for token in tokens
          token.selected = false
        tokens[tokenId].selected = true
        $scope.selectedGameTokenId = tokenId
        $meteor.call('getPossibleActions', $scope.game, $scope.game.board.gameTokens[tokenId].position).then(
          (data) ->
            $scope.possibleMoves = data
          ,
          (err) ->
            console.log 'failed', err
        )

      $scope.attack = () ->
        console.log 'angriff'

      $scope.move = (x,y) ->
        console.log 'move',x,y
        newPos = 
          x: x
          y: y
        tokens = $scope.game.board.gameTokens
        tokens[$scope.selectedGameTokenId].position = newPos
        # tokens[$scope.selectedGameTokenId].pixPos = hexPosToPixel(newPos)
        $scope.possibleMoves = {}

      $scope.newGame = () ->
        $meteor.call 'newGame'
        $scope.game = $scope.games[$scope.games.length - 1]

      $scope.hexPosToPixel = (pos) ->
        hexPosToPixel(pos)

      # $scope.$watch 'game', (neu, old) ->
      #   console.log 'change game'
      # , true  

      $scope.$watch 'game.board.gameTokens', (neu, old) ->
        console.log 'change tokens'
        console.log neu
        console.log old
      , true  

      init = () ->
        $timeout ->
          $scope.game = $scope.games[$scope.games.length - 1]
          console.log $scope.game
        ,200

      init()
  ]).controller('GameTokenCtrl', [
    '$scope'
    '$meteor'
    ($scope, $meteor) ->
      $scope.pixPos = hexPosToPixel($scope.gameToken.position)
      # $scope.$apply ->
      # $scope.pixPos = ->
      #   posX = 75 * 3/2 * $scope.gameToken.position.x
      #   posY = 75 * Math.sqrt(3) * $scope.gameToken.position.y
      #   if (Math.abs($scope.gameToken.position.x) % 2 == 1)
      #     posY += (75 * Math.sqrt(3)) / 2
      #   pixPos =
      #     x: posX
      #     y: posY
      # $scope.pixPos = $scope.gameToken.position * 150
      $scope.gameToken.weapons = []
      $scope.$watch 'gameToken', (newValue, oldValue) ->
        console.log 'gameToken Directive change', newValue
      , true
      $scope.$watch 'gameToken.position', (newValue, oldValue) ->
        console.log 'changepos', newValue

        $scope.gameToken.weapons = []
        # $scope.$apply ->
        $scope.pixPos = hexPosToPixel($scope.gameToken.position)
        # $scope.pixPos = $scope.gameToken.position * 150
        mapSidesToWeapons = ->
          for side in $scope.gameToken.sides
            $scope.gameToken.weapons.push 'shield' if side is 0
            $scope.gameToken.weapons.push 'sword' if side is 1
            $scope.gameToken.weapons.push 'arrow' if side is 2

        mapSidesToWeapons()
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
    RokuGame = Meteor.npmRequire('roku-game')
    game = RokuGame.createNewGame()
    Games.insert game
  getLastGame: () ->
    lastGame = Games.find({}, {sort: {_id: -1}, limit: 1});
  getPossibleActions: (game, position) ->
    if Meteor.isServer
      RokuGame = Meteor.npmRequire('roku-game')
      possibleActions = RokuGame.getPossibleActions(game, position.x, position.y)
      console.log 'possibleActionso'
      console.log possibleActions
      return possibleActions 
  moveFromTo: (from, to) ->
    console.log 'someMethod on server'
      # RokuGame.getPossibleActions(game, position)

