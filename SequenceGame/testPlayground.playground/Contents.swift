import UIKit

var greeting = "Hello, playground"

let aiPlayer = Player.aiPlayer(name: "AI Player 1", team: testTeam, difficulty: .easy)
print(aiPlayer.isAI) // Should print: true
print(aiPlayer.aiDifficulty)
