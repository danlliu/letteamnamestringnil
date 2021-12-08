//
//  PlayerView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

struct PlayerView: View {
    // partyCode, characterName, className, raceName, level, maxHP, tempHP, alignment, stats,
    
    @State var partyCode = "E44W"
    @State var username = "TunaWizard485"
    @State var id = -1

    // TODO: Fetch
    @State private var players: [Player] = []

    // TODO: Fetch

    @State private var hasCS = false

    @State private var friendlyNPCs: [NPC] = []
    @State private var monsterNPCs: [NPC] = []
    
    @State private var characterName = "Eaydan Falconmoon"
    @State private var className = "Fighter"
    @State private var race = "Human"
    @State private var level = 4
    @State private var maxHP = 28
    @State private var tempHP = 28
    @State private var prof = "+4"
    @State private var speed = "30"
    @State private var initiative = "+5"
    @State private var ac = "12"
    @State private var alignment = 2
    
    @State private var synergy: [[String]]
    
    init(partyCode: String, username: String) {
        self.partyCode = partyCode
        self.username = username
        self.synergy = []
    }
    
    var body: some View {
        if #available(iOS 15.0, *) {
            VStack {
                Group {
                    Text("Party Code".uppercased())
                            .font(.caption)
                            .foregroundColor(.gray)
                    Text(partyCode)
                            .padding(.bottom)
                }
                if (hasCS) {
                Group {
                    Text(characterName)
                            .font(.title)
                    Text("Level \(level) \(race), \("CG")") // TODO: alignment # to string
                            .font(.title2)
                    Text("HP \(tempHP)/\(maxHP)")
                            .padding(.bottom)
                            .font(.title3)
                }

                Group {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Proficiency")
                                    .font(.caption)
                            Text(prof)
                        }
                        VStack {
                            Text("Speed")
                                    .font(.caption)
                            Text(speed)
                        }
                        VStack {
                            Text("Initiative")
                                    .font(.caption)
                            Text(initiative)
                        }
                        VStack {
                            Text("Armor Class")
                                    .font(.caption)
                            Text(ac)
                        }
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        NavigationLink(destination: PlayerDetailView(partyCode: partyCode, playerID: id)) {
                            Text("View")
                                    .padding(8)
                                    .background(Color.blue)
                        }
                        NavigationLink(destination: CharacterSheetView(partyCode: partyCode, username: username)) {
                            Text("Edit")
                                    .padding(8)
                                    .background(Color.blue)
                        }
                        Spacer()
                    }
                            .padding()
                            .foregroundColor(Color.white)
                            .cornerRadius(4)
                }
                }
                else {
                    NavigationLink(destination: GenerateCharacter(partyCode: partyCode, username: username)) {
                        Text("Create character sheet")
                    }
                }

                List {
                    Section(header: ListHeader(title: "Players")) {
                        ForEach(players, id: \.id) { player in
                            IndividualPlayerView(player: player)
                        }
                    }
                    Section(header: ListHeader(title: "Friendly NPCs")) {
                        if friendlyNPCs.isEmpty {
                            Text("No friendly NPCs")
                        }
                        ForEach(friendlyNPCs, id: \.npcid) { friendly in
                            IndividualNPCView(npc: friendly)
                        }
                    }

                    //                Section(header: ListHeader(title: "Monster NPCs")) {
                    //                    if monsterNPCs.isEmpty {
                    //                        Text("No monster NPCs")
                    //                    }
                    //                    ForEach(monsterNPCs, id: \.self) { monster in
                    //                        IndividualPlayerView(player: monster)
                    //                    }
                    //                }
                }
                        .listStyle(GroupedListStyle())
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
            }.task {
                players = []
                let party = await Store.shared.getPartyInfo(code: partyCode)
                for player in party.players {
                    guard let p = await Store.shared.getPlayerData(code: partyCode, playerId: player.id) else {
                        continue
                    }
                    players.append(p)
                }
            }
            .task {
                guard let theID = await Store.shared.getID() else {
                    return
                }
                id = theID
                let response = await Store.shared.getPlayerData(code: partyCode, playerId: id)
                if let cs = response?.csheet {
                    hasCS = true
                    characterName = cs.basicInfo.name
                    className = cs.basicInfo.className
                    race = cs.basicInfo.race
                    level = cs.stats.level
                    maxHP = cs.stats.maxHP
                    tempHP = cs.stats.curHP
                    prof = "\(cs.stats.profBonus)"
                    speed = "\(cs.stats.speed)"
                    initiative = "\(cs.stats.initiative)"
                    ac = "\(cs.stats.ac)"
                    alignment = cs.basicInfo.alignment
                } else {
                    hasCS = false
                }
                
                synergy = await Store.shared.getSynergy(code: partyCode) as? [[String]] ?? []
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct IndividualPlayerView: View {
    
    var player: Player
    
    var body: some View {
        if player.username != "" {
            HStack {
                VStack(alignment: .leading) {
                    Text(player.username)
                    Text("Lvl \(player.csheet!.stats.level), \(player.csheet!.basicInfo.className), \(player.csheet!.basicInfo.alignment)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
    //            NavigationLink(destination: PlayerView()) {
    //                Text("View")
    //                .foregroundColor(Color.white)
    //                .background(Color.blue)
    //            }
            }
        }
    }
}

struct IndividualNPCView: View {
    
    var npc: NPC
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(npc.csheet!.basicInfo.name)
                Text("Lvl \(npc.csheet!.stats.level), \(npc.csheet!.basicInfo.className), \(npc.csheet!.basicInfo.alignment)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
//            NavigationLink(destination: PlayerView()) {
//                Text("View")
//                .foregroundColor(Color.white)
//                .background(Color.blue)
//            }
        }
    }
}

struct ListHeader: View {
    var title: String
    var body: some View {
        HStack {
            Text(title)
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(partyCode: "E44W", username: "TunaWizard485")
    }
}
