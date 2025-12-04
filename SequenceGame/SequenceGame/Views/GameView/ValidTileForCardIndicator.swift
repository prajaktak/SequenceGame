//
//  ValidTileForCardIndicator.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 20/11/2025.
//

import SwiftUI

/// Visual indicator for valid card placement positions using a shimmer border effect.
///
/// This indicator appears on card tiles (not empty corner tiles) when a player has selected
/// a card that can be played on that position. It uses a shimmer border animation to draw
/// attention to valid moves.
///
/// ## Visual Appearance
///
/// - **Border:** Animated shimmer border in the team's color
/// - **Animation:** Continuous shimmer effect around the tile perimeter
/// - **Width:** Uses `highlightBorderWidth` constant (3pt)
///
/// ## Usage
///
/// ```swift
/// .overlay {
///     if isValid {
///         CardTileValidIndicator(teamColor: teamColor, tileSize: tileSize)
///     }
/// }
/// ```
///
/// ## See Also
///
/// - `ShimmerBorder`: Provides the animated border effect
/// - `ShimmerBorderSettings`: Configuration for the shimmer animation

struct ValidTileForCardIndicator: View {
    let teamColor: Color
    
    /// The size of the tile this indicator surrounds
    let tileSize: (width: CGFloat, height: CGFloat)
    
    var body: some View {
        let shimmerBorderSettings = ShimmerBorderSettings(
            teamColor: teamColor,
            frameWidth: tileSize.width,
            frameHeight: tileSize.height,
            dashArray: [tileSize.width, 2 * tileSize.height + tileSize.width],
            dashPhasePositive: CGFloat(2.0 * (tileSize.width) + 2.0 * (tileSize.height)),
            dashPhaseNegative: CGFloat(-(2.0 * (tileSize.width) + 2.0 * (tileSize.height))),
            animationDuration: 2.0,
            borderWidth: GameConstants.highlightBorderWidth
        )
        
        ShimmerBorder(shimmerBorderSetting: shimmerBorderSettings) {
            Color.clear
                .frame(width: tileSize.width, height: tileSize.height)
        }
    }
}

#Preview("Blue Team Indicator") {
    ZStack {
        // Mock card tile background
        RoundedRectangle(cornerRadius: 4)
            .fill(.white)
            .overlay(
                Text("Q♠")
                    .font(.system(size: 24))
            )
            .frame(width: 60, height: 96)
        
        // Indicator overlay
        ValidTileForCardIndicator(
            teamColor: .blue,
            tileSize: (width: 60, height: 96)
        )
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}

#Preview("Red Team Indicator") {
    ZStack {
        // Mock card tile background
        RoundedRectangle(cornerRadius: 4)
            .fill(.white)
            .overlay(
                Text("7♥")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
            )
            .frame(width: 60, height: 96)
        
        // Indicator overlay
        ValidTileForCardIndicator(
            teamColor: .red,
            tileSize: (width: 60, height: 96)
        )
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}

#Preview("Green Team Indicator") {
    ZStack {
        // Mock card tile background
        RoundedRectangle(cornerRadius: 4)
            .fill(.white)
            .overlay(
                Text("K♦")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
            )
            .frame(width: 60, height: 96)
        
        // Indicator overlay
        ValidTileForCardIndicator(
            teamColor: .green,
            tileSize: (width: 60, height: 96)
        )
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}

#Preview("Small Tile Size") {
    ZStack {
        RoundedRectangle(cornerRadius: 2)
            .fill(.white)
            .frame(width: 32, height: 50)
        
        ValidTileForCardIndicator(
            teamColor: .blue,
            tileSize: (width: 32, height: 50)
        )
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
