//
//  GameSettingsView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 23/10/2025.
//

import SwiftUI

struct GameSettingsView: View {
    @State private var playersInTeam = 2 // Start with a default
    @State private var numberOfTeams = 2
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    HStack {
                        Text("Number of Team")
                        Picker("Number of Players", selection: $numberOfTeams) {
                            ForEach(2...3, id: \.self) { number in
                                Text("\(number)").tag(number)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: .infinity, maxHeight: 70)
                    }
                    HStack {
                        Text("Players in team")
                        Picker("Number of Players", selection: $playersInTeam) {
                            ForEach(2...12, id: \.self) { number in
                                Text("\(number)").tag(number)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity, maxHeight: 70)
                    }
                }
                .padding(.top, 40)
                NavigationLink(destination: SequenceGameView(numberOfPlayers: playersInTeam, numberOfTeams: numberOfTeams), label: {
                    
                    Text("Start Game\(numberOfTeams) \(playersInTeam)")
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.wood))
                        .foregroundColor(.black)
                    
                })
                Spacer()
            }
            .navigationTitle("Sequence Game")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    GameSettingsView()
}
