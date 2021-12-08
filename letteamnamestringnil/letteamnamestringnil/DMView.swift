//
//  DMView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

struct DMView: View {
    @State var partyCode: String
    @State var username: String

    init(partyCode: String, username: String) {
        self.partyCode = partyCode
        self.username = username
    }

    @State private var players: [Player] = []
    @State private var friendlys: [NPC] = []
    @State private var monsters: [NPC] = []
    
    @State var goSwitch = false

    var body: some View {
        if #available(iOS 15.0, *) {
            VStack {
                Text("Party code")
                Text(partyCode)
                    .font(.title2)
                
                NavigationLink(destination: PlayerView(partyCode: partyCode, username: username), isActive: $goSwitch) {
                    EmptyView()
                }.hidden()
                
                List {
                    Section(header: Text("Widgets")) {
                        WidgetSubview(title: "HP", color: .pink, render: {cs in
                            return "\(cs.stats.curHP)"
                        }, players: $players)
                    }
                    Section(header: Text("Players")) {
                        ForEach(players, id: \.id) { (player: Player) in
                            if !player.isDM && player.csheet != nil {
                                NavigationLink(destination: PlayerDetailView(partyCode: partyCode, playerID: player.id)) {
                                    VStack(alignment: .leading) {
                                        Text(player.username)
                                            .font(.headline)
                                        Text("Lvl. \(player.csheet!.stats.level) \(player.csheet!.basicInfo.className)")
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                    }
                    Section(header: Text("Friendly NPCs")) {
                        ForEach(friendlys, id: \.npcid) { (friendly: NPC) in
                            VStack(alignment: .leading) {
                                Text(friendly.csheet!.basicInfo.name)
                                    .font(.headline)
                                Text("Lvl. \(friendly.csheet!.stats.level) \(friendly.csheet!.basicInfo.className)")
                                    .font(.subheadline)
                            }
                        }
                    }
                    Section(header: Text("Monster NPCs")) {
                        ForEach(monsters, id: \.npcid) { (monster: NPC) in
                            VStack(alignment: .leading) {
                                Text(monster.csheet!.basicInfo.name)
                                    .font(.headline)
                                Text("Lvl. \(monster.csheet!.stats.level) \(monster.csheet!.basicInfo.className)")
                                    .font(.subheadline)
                            }
                        }
                    }
                    NavigationLink(destination: AddNPCView(partyCode: partyCode, username: username)) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add NPC")
                        }
                    }
                }
                .listStyle(.grouped)
            }
            .task {
                players = []
                friendlys = []
                monsters = []
                let party = await Store.shared.getPartyInfo(code: partyCode)
                for player in party.players {
                    guard let p = await Store.shared.getPlayerData(code: partyCode, playerId: player.id) else {
                        continue
                    }
                    players.append(p)
                }
                let npcs = await Store.shared.getNPCs(code: partyCode)
                for npc in npcs {
                    guard let n = await Store.shared.getNPCData(code: partyCode, npcid: npc), n.csheet != nil else {
                        continue
                    }
                    if n.csheet!.basicInfo.isFriendly {
                        friendlys.append(n)
                    } else {
                        monsters.append(n)
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }

    @available(iOS 15.0.0, *)
    func switchRoles() async {
        print("switching roles...")
        guard let id = await Store.shared.getID() else {
            return
        }
        guard let response = await Store.shared.getPlayerData(code: partyCode, playerId: id) else {
            return
        }
        if response.csheet != nil {
            await Store.shared.postPlayerData(code: partyCode, playerId: id, isDM: false, csheet: response.csheet)
        } else {
            await Store.shared.postPlayerData(code: partyCode, playerId: id, isDM: false, csheet: nil)
        }
    }
}
