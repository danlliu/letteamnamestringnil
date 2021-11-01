//
//  DMView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

struct DMView: View {
    @State private var partyCode: String = "placeholder"
    @State private var players: [Player] = [Player(name: "bob", playerClass: "elf", playerAlignment: "chaotic good", level: 2),
                                            Player(name: "alice", playerClass: "dragonborn", playerAlignment: "chaotic evil", level: 7)]
    
    var body: some View {
        VStack {
            Text("Party code")
            Text(partyCode)
                .font(.title2)
            NavigationLink(destination: GenerateCharacter()) {
                Text("Switch to player")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .simultaneousGesture(TapGesture().onEnded(switchRoles)) //TODO: do we want this to be this easy?
            .background(Color.blue)
            .cornerRadius(10)
            .padding()
            
            List {
                Section(header: Text("Players")) {
                    ForEach(players, id:\.self) { player in
                        NavigationLink(destination: PlayerView()) { //TODO: need more info about where to go
                            VStack(alignment: .leading) {
                                Text(player.name)
                                    .font(.headline)
                                Text("Lvl. \(player.level) \(player.playerClass)")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                Section(header: Text("Friendly NPCs")) {
                    
                }
                Section(header: Text("Monster NPCs")) {
                    
                }
            }
            .listStyle(.grouped)
        }
    }
    
    func getGameData() {
        //TODO: I am lonely! I need a database!
        //fill in the state variables
    }
    
    func switchRoles() {
        //TODO: backend logic to turn a DM into a player
        print("switching roles...")
    }
}

struct Player: Hashable {
    var name: String
    var playerClass: String
    var playerAlignment: String
    var level: Int
    //can add more as desired
}
