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
    @State private var friendlys: [NPC] = [NPC(name: "Jinx", npcClass: "wizard", npcAlignment: "chaotic good", level: 5)]
    @State private var monsters: [NPC] = [NPC(name: "Mine orc", npcClass: "orc", npcAlignment: "lawful evil", level: 2)]
    
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
                    ForEach(friendlys, id: \.self) { friendly in
                        VStack(alignment: .leading) {
                            Text(friendly.name)
                                .font(.headline)
                            Text("Lvl. \(friendly.level) \(friendly.npcClass)")
                                .font(.subheadline)
                        }
                    }
                }
                Section(header: Text("Monster NPCs")) {
                    ForEach(monsters, id: \.self) { monster in
                        VStack(alignment: .leading) {
                            Text(monster.name)
                                .font(.headline)
                            Text("Lvl. \(monster.level) \(monster.npcClass)")
                                .font(.subheadline)
                        }
                    }
                }
                NavigationLink(destination: AddNPCView()) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add NPC")
                    }
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

struct NPC: Hashable {
    var name: String
    var npcClass: String
    var npcAlignment: String
    var level: Int
    //can add more as desired
}

@available(iOS 15.0, *)
struct DMView_Previews: PreviewProvider {
    static var previews: some View {
        DMView()
    }
}
