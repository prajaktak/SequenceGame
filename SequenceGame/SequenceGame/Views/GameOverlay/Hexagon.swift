//
//  Hexagon.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//

//
import SwiftUI

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
           var path = Path()
           let width = rect.width
           let height = rect.height
           let cornerCut = min(width, height) * 0.22   // length of the short angled edges

           // Go clockwise starting at top-left inner corner
           path.move(to: CGPoint(x: cornerCut, y: 0))           // top-left inner
           path.addLine(to: CGPoint(x: width - cornerCut, y: 0))    // top (wide)
           path.addLine(to: CGPoint(x: width, y: height / 2))            // right tip (short angled)
           path.addLine(to: CGPoint(x: width - cornerCut, y: height))    // bottom-right inner
           path.addLine(to: CGPoint(x: cornerCut, y: height))        // bottom (wide)
           path.addLine(to: CGPoint(x: 0, y: height / 2))            // left tip (short angled)
           path.closeSubpath()
           return path
       }
}
