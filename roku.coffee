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
  angular.module('roku-app').controller('GameCtrl', [
    '$scope'
    '$meteor'
    ($scope, $meteor) ->
      $scope.games = $meteor.collection(Games);
      console.log '$scope.games'
      console.log $scope.games

      $scope.possibleMovesClass = 
        getArrowAttacks: () ->
          [
            {position:
              x: 4
              y: 3}
            {position:
              x: 3
              y: 2}
          ]
        getSwordAttacks: () ->
          [
            {position:
              x: 2
              y: 2}
            {position:
              x: 3
              y: 3}
          ]
        getMoves: () ->
          [
            {position:
              x: 2
              y: 1}
            {position:
              x: 1
              y: 1}
          ]
      $scope.possibleMoves = 
        arrowAttacks: $scope.possibleMovesClass.getArrowAttacks()
        swordAttacks: $scope.possibleMovesClass.getSwordAttacks()
        moves: $scope.possibleMovesClass.getMoves()
      $scope.game = 
        activePlayer: 0
        board:
          gameTokens: [
            {
              position:
                x: 0
                y: 0
              playerId: 2
              health: 6
            }
            {
              position:
                x: 0
                y: 1
              playerId: 1
              health: 5
            }
            {
              position:
                x: 1
                y: 0
              playerId: 1
              health: 5
            }
            {
              position:
                x: 2    
                y: 0
              playerId: 1
              health: 5
            }
          ]

      $scope.selectGameToken = (tokenId) ->
        tokens = $scope.game.board.gameTokens
        for token in tokens
          token.selected = false
        tokens[tokenId].selected = true
        $scope.selectedGameToken

      # $scope.attack = (attackerPos, targetPos) ->
      #   console.log 'attack:'
      #   console.log attackerPos
      #   console.log targetPos

      $scope.attack = () ->
        console.log 'angriff'

      $scope.move = () ->
        console.log 'move'

      $scope.newGame = (id) ->
        $meteor.call 'newGame', id
        return
      $scope.hexPosToPixel = (pos) ->
        hexPosToPixel(pos)
  ]).controller('GameTokenCtrl', [
    '$scope'
    '$meteor'
    ($scope, $meteor) ->
      $scope.pixPos = hexPosToPixel($scope.gameToken.position)
  ]).directive('gameToken', () ->
    restrict: 'E'
    templateUrl: 'gameToken.ng.html'
    controller: 'GameTokenCtrl'    
    # scope:
    #   hexposx: '='
    #   hexposy: '='
    #   playerId: '='
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
    console.log '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>game'
    RokuGame = Meteor.npmRequire('roku-game')
    game = RokuGame.createNewGame()
    console.log game
    Games.insert game

