//
//  ShimmerBorderView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 16/11/2025.
//

import SwiftUI

public struct ShimmerBorder<Content: View>: View {
    public var content: Content
    public var shimmerBorderSettings: ShimmerBorderSettings
    @State private var dashPhase: CGFloat = 0
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self.shimmerBorderSettings = ShimmerBorderSettings(teamColor: .blue,
                                                           frameWidth: 100,
                                                           frameHeight: 100,
                                                           dashArray: [40, 400],
                                                           dashPhasePositive: 220,
                                                           dashPhaseNegative: -220,
                                                           animationDuration: 0.1,
                                                           borderWidth: GameConstants.cardBorderWidth)
    }
    public init (shimmerBorderSetting: ShimmerBorderSettings, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.shimmerBorderSettings = shimmerBorderSetting
    }
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: GameConstants.cardBorderWidth)
                .foregroundStyle(.clear)
            RoundedRectangle(cornerRadius: GameConstants.cardBorderWidth)
                .strokeBorder(style: StrokeStyle(lineWidth: shimmerBorderSettings.borderWidth,
                                                 lineCap: .round,
                                                 lineJoin: .round,
                                                 dash: shimmerBorderSettings.dashArray,
                                                 dashPhase: dashPhase))
                .foregroundStyle(ThemeColor.getTeamOverlayColor(for: shimmerBorderSettings.teamColor))
                content
        }
        .frame(width: shimmerBorderSettings.frameWidth, height: shimmerBorderSettings.frameHeight)
        .onAppear {
            withAnimation(.linear(duration: shimmerBorderSettings.animationDuration).repeatForever(autoreverses: false)) {
                dashPhase = shimmerBorderSettings.dashPhasePositive
            }
        }
    }
}

#Preview("Shimmering Sequence Highlight - Blue") {
    let shimmerBorderSetting = ShimmerBorderSettings(teamColor: ThemeColor.teamBlue,
                                                     frameWidth: 32,
                                                     frameHeight: 54,
                                                     dashArray: [20, 150],
                                                     dashPhasePositive: 170,
                                                     dashPhaseNegative: -170,
                                                     animationDuration: 2.0,
                                                     borderWidth: 2)
    TileView(isCard: true, color: .blue, isChipVisible: false)
        .frame(width: 32, height: 54)
        .border(ThemeColor.teamBlue, width: 2)
        .overlay {
            ShimmerBorder(shimmerBorderSetting: shimmerBorderSetting) {
                Color.clear
                    .frame(width: 32, height: 54)
            }
        }
    
}
#Preview("Shimmering Sequence Highlight - Green") {
    let shimmerBorderSetting = ShimmerBorderSettings(teamColor: ThemeColor.teamGreen,
                                                     frameWidth: 32,
                                                     frameHeight: 54,
                                                     dashArray: [20, 150],
                                                     dashPhasePositive: 170,
                                                     dashPhaseNegative: -170,
                                                     animationDuration: 2.0,
                                                     borderWidth: 2)
    TileView(isCard: true, color: .blue, isChipVisible: false)
        .frame(width: 32, height: 54)
        .border(ThemeColor.teamGreen, width: 2)
        .overlay {
            ShimmerBorder(shimmerBorderSetting: shimmerBorderSetting) {
                Color.clear
                    .frame(width: 32, height: 54)
            }
        }
    
}
#Preview("Shimmering Sequence Highlight - Red") {
    let shimmerBorderSetting = ShimmerBorderSettings(teamColor: ThemeColor.teamRed,
                                                     frameWidth: 32,
                                                     frameHeight: 54,
                                                     dashArray: [20, 150],
                                                     dashPhasePositive: 170,
                                                     dashPhaseNegative: -170,
                                                     animationDuration: 2.0,
                                                     borderWidth: 3)
    TileView(isCard: true, color: .blue, isChipVisible: false)
        .frame(width: 32, height: 54)
        .border(ThemeColor.teamRed, width: 3)
        .overlay {
            ShimmerBorder(shimmerBorderSetting: shimmerBorderSetting) {
                Color.clear
                    .frame(width: 32, height: 54)
            }
        }
    
}
