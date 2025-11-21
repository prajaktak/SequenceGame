//
//  SeatingRingOverlay.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//

import SwiftUI

struct SeatingRingOverlay: View {
    let seats: [Seat]                  // 1-based index
    let players: [Player]
    let currentPlayerIndex: Int

    var body: some View {
        GeometryReader { geometry in
            let minimumSide = min(geometry.size.width, geometry.size.height)
            let ringRadius: CGFloat = minimumSide * (minimumSide < 500 ? 0.42 : 0.46)
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let bottomAngle = CGFloat.pi / 2
            let currentSeatAngle: CGFloat = {
                if let seatOfCurrent = seats.first(where: { ($0.index - 1) == currentPlayerIndex }) {
                    return seatOfCurrent.angleRadian
                }
                return 0
            }()
            let angleOffset = bottomAngle - currentSeatAngle

            ZStack {
                ForEach(seats, id: \.id) { seat in
                    if let player = players[safe: seat.index - 1] {
                        let isCurrent = (seat.index - 1) == currentPlayerIndex
                        let adjustedAngle = seat.angleRadian + angleOffset
                        let seatCenterX = centerX + ringRadius * cos(adjustedAngle)
                        let seatCenterY = centerY + ringRadius * sin(adjustedAngle)

                        SeatView(
                            name: player.name,
                            teamColor: ThemeColor.getTeamColor(for: player.team.color),
                            handCount: player.cards.count,
                            isCurrent: isCurrent
                        )
                        .position(x: seatCenterX, y: seatCenterY)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview("SeatingRingOverlay – 4 players") {
    let teamBlue = Team(color: TeamColor.blue, numberOfPlayers: 2)
    let teamGreen = Team(color: TeamColor.green, numberOfPlayers: 2)

    let players = [
        Player(name: "Prajakta", team: teamGreen, isPlaying: true, cards: []),
        Player(name: "Alex", team: teamBlue, isPlaying: false, cards: []),
        Player(name: "Sam", team: teamGreen, isPlaying: false, cards: []),
        Player(name: "Riley", team: teamBlue, isPlaying: false, cards: [])
    ]

    let seats = SeatingLayout.computeSeats(for: players.count)

    ZStack {
        RoundedRectangle(cornerRadius: 12).fill(ThemeColor.backgroundGame)
        SeatingRingOverlay(
            seats: seats,
            players: players,
            currentPlayerIndex: 0
        )
        .padding(16)
        .frame(width: 260, height: 260)
    }
    .padding(12)
}

#Preview("SeatingRingOverlay – 6 players") {    let teamBlue = Team(color: TeamColor.blue, numberOfPlayers: 3)
    let teamGreen = Team(color: TeamColor.green, numberOfPlayers: 3)

    let players = (0..<6).map { playerIndex in
        let assignedTeam = playerIndex % 2 == 0 ? teamGreen : teamBlue
        return Player(
            name: "P\(playerIndex + 1)",
            team: assignedTeam,
            isPlaying: playerIndex == 3,
            cards: []
        )
    }

    let seats = SeatingLayout.computeSeats(for: players.count)

    ZStack {
        RoundedRectangle(cornerRadius: 12).fill(ThemeColor.backgroundGame)
        SeatingRingOverlay(
            seats: seats,
            players: players,
            currentPlayerIndex: 3
        )
        .padding(16)
        .frame(width: 300, height: 300)
    }
    .padding(12)
}
