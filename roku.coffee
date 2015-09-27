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
    '$timeout'
    ($scope, $meteor, $timeout) ->

      $scope.possibleMovesClass = 
        getArrowAttacks: () ->
          [
            # {position:
            #   x: 4
            #   y: 3}
            # {position:
            #   x: 3
            #   y: 2}
          ]
        getSwordAttacks: () ->
          [
            # {position:
            #   x: 2
            #   y: 2}
            # {position:
            #   x: 3
            #   y: 3}
          ]
        getMoves: () ->
          [
            {position:
              x: 2
              y: 1}
            {position:
              x: 1
              y: 1}
            {position:
              x: 0
              y: 1}
          ]
      $scope.possibleMoves = 
        arrowAttacks: $scope.possibleMovesClass.getArrowAttacks()
        swordAttacks: $scope.possibleMovesClass.getSwordAttacks()
        moves: $scope.possibleMovesClass.getMoves()
      # $scope.game = $meteor.call 'getLastGame'
      $scope.games = $meteor.collection(Games);
      $scope.game = {}
      # $scope.game = 
      #   activePlayer: 0
      #   board:
      #     gameTokens: [
      #       {
      #         position:
      #           x: 0
      #           y: 0
      #         playerId: 2
      #         health: 6
      #       }
      #       {
      #         position:
      #           x: 0
      #           y: 1
      #         playerId: 1
      #         health: 5
      #       }
      #       {
      #         position:
      #           x: 1
      #           y: 0
      #         playerId: 1
      #         health: 5
      #       }
      #       {
      #         position:
      #           x: 2    
      #           y: 0
      #         playerId: 1
      #         health: 5
      #       }
      #     ]
      console.log '$scope.game'
      console.log $scope.game

      $scope.selectGameToken = (tokenId) ->
        tokens = $scope.game.board.gameTokens
        for token in tokens
          token.selected = false
        tokens[tokenId].selected = true
        $scope.selectedGameToken
        console.log $scope.game.board.gameTokens[tokenId].position
        $scope.possibleMovesClass = $meteor.call 'getPossibleActions', $scope.game, $scope.game.board.gameTokens[tokenId].position


      # $scope.attack = (attackerPos, targetPos) ->
      #   console.log 'attack:'
      #   console.log attackerPos
      #   console.log targetPos

      $scope.attack = () ->
        console.log 'angriff'

      $scope.move = () ->
        console.log 'move'

      $scope.newGame = () ->
        $meteor.call 'newGame'
        $scope.game = $scope.games[$scope.games.length - 1]

        return
      $scope.hexPosToPixel = (pos) ->
        hexPosToPixel(pos)

      init = () ->
        # $timeout (() ->
        #   $scope.game = $scope.games[$scope.games.length - 1]
        # ), 100)
        $timeout ->
          $scope.game = $scope.games[$scope.games.length - 1]
          console.log $scope.game
        ,500

      init()
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
    RokuGame = Meteor.npmRequire('roku-game')
    game = RokuGame.createNewGame()
    console.log game
    Games.insert game
  getLastGame: () ->
    lastGame = Games.find({}, {sort: {_id: -1}, limit: 1});
  getPossibleActions: (game, position) ->
    RokuGame = Meteor.npmRequire('roku-game')
    possibleActions = RokuGame.getPossibleActions(game, position)
    console.log 'possibleActions' 
    console.log possibleActions 
    return possibleActions
    # RokuGame.getPossibleActions(game, position)

