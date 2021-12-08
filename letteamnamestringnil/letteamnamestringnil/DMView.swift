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
    
    @State private var synergy: [[String]] = []
    
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
                List {
                    Section(header: ListHeader(title: "Spell Synergy")) {
                        if synergy.isEmpty {
                            Text("No spells found")
                        }
                        ForEach(synergy, id: \.self) { spell in
                            if spell[3] == "ATK" {
                                HStack {
                                    Image(systemName: "scope")
                                    Text(spell[2]).font(Font.system(size: 10))
                                    Text("lvl \(spell[0]) (\(spell[1]))").font(Font.system(size: 8))
                                    Text("\(spell[3]) \(spell[5]) \(spell[4])").font(Font.system(size: 8))
                                    Text("range \(spell[6])").font(Font.system(size: 8))
                                }
                            } else if spell[3] == "HEAL" {
                                HStack {
                                    Image(systemName: "heart")
                                    Text(spell[2]).font(Font.system(size: 10))
                                    Text("lvl \(spell[0]) (\(spell[1]))").font(Font.system(size: 8))
                                    Text(spell[4]).font(Font.system(size: 8))
                                    Text("range \(spell[5])").font(Font.system(size: 8))
                                }
                            } else if spell[3] == "DEF" {
                                HStack {
                                    Image(systemName: "checkerboard.shield")
                                    Text(spell[2]).font(Font.system(size: 10))
                                    Text("lvl \(spell[0]) (\(spell[1]))").font(Font.system(size: 8))
                                    Text("defensive spell").font(Font.system(size: 8))
                                }
                            } else if spell[3] == "UTIL" {
                                HStack {
                                    Image(systemName: "gear.circle")
                                    Text(spell[2]).font(Font.system(size: 10))
                                    Text("lvl \(spell[0]) (\(spell[1]))").font(Font.system(size: 8))
                                    Text("utility spell").font(Font.system(size: 8))
                                }
                            }
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
                
                synergy = await Store.shared.getSynergy(code: partyCode) as? [[String]] ?? []
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
