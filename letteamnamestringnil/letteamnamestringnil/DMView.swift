//
//  DMView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

struct DMView: View {
    @State var partyCode: String = "placeholder"
    @State var username: String = "tuna_player_485"

    init(partyCode: String, username: String) {
        self.partyCode = partyCode
        self.username = username
    }

    @State private var players: [Player] = []
    @State private var friendlys: [NPC] = []
    @State private var monsters: [NPC] = []

    var body: some View {
        VStack {
            Text("Party code")
            Text(partyCode)
                    .font(.title2)
            NavigationLink(destination: PlayerView(partyCode: partyCode, username: username)) {
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
                    ForEach(players, id:\.self) { (player: Player) in
                        NavigationLink(destination: PlayerView(partyCode: partyCode, username: player.username)) {
                            VStack(alignment: .leading) {
                                Text(player.username)
                                        .font(.headline)
                                Text("Lvl. \(player.csheet!.stats.level) \(player.csheet!.basicInfo.className)")
                                        .font(.subheadline)
                            }
                        }
                    }
                }
                Section(header: Text("Friendly NPCs")) {
                    ForEach(friendlys, id: \.self) { (friendly: NPC) in
                        VStack(alignment: .leading) {
                            Text(friendly.csheet!.basicInfo.name)
                                    .font(.headline)
                            Text("Lvl. \(friendly.csheet!.stats.level) \(friendly.csheet!.basicInfo.className)")
                                    .font(.subheadline)
                        }
                    }
                }
                Section(header: Text("Monster NPCs")) {
                    ForEach(monsters, id: \.self) { (monster: NPC) in
                        VStack(alignment: .leading) {
                            Text(monster.csheet!.basicInfo.name)
                                    .font(.headline)
                            Text("Lvl. \(monster.csheet!.stats.level) \(monster.csheet!.basicInfo.className)")
                                    .font(.subheadline)
                        }
                    }
                }
                NavigationLink(destination: AddNPCView(partyCode: partyCode)) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add NPC")
                    }
                }
            }
                    .listStyle(.grouped)
        }
                .task {
                    let party = Store.shared.getPartyInfo(code: partyCode)
                    for player in party.players {
                        let p = Store.shared.getPlayerData(code: partyCode, player: player.username)
                        players.append(p)
                    }
                    let npcs = Store.shared.getNPCs(code: partyCode)
                    for npc in npcs {
                        let n = Store.shared.getNPCData(code: partyCode, npcid: npc)
                        if n.csheet!.basicInfo.isFriendly {
                            friendlys.append(n)
                        } else {
                            monsters.append(n)
                        }
                    }
                }
    }

    func switchRoles() {
        //TODO: backend logic to turn a DM into a player
        print("switching roles...")
        let response = Store.shared.getPlayerData(code: partyCode, player: username)
        Store.shared.postPlayerData(code: partyCode, player: username, isDM: false, csheet: response.csheet)
    }
}

@available(iOS 15.0, *)
struct DMView_Previews: PreviewProvider {
    static var previews: some View {
        DMView()
    }
}
