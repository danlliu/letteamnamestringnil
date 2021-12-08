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
    @State var username = "tuna_player_485"
    
//    @EnvironmentObject var charSheet: CharacterSheet
//    @EnvironmentObject var party: [IndividualPlayerView]

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
    
    init(partyCode: String = "", username: String = "") {
        self._partyCode = State(wrappedValue: partyCode)
        self._username = State(wrappedValue: username)
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
                        NavigationLink(destination: PlayerDetailView(partyCode: partyCode, username: username)) {
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
            }
                    .task {
                        guard let id = await Store.shared.getID() else {
                            return
                        }
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
            // Image(systemName: "")
            Text(title)
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(partyCode: "E44W")
    }
}

/*
 
 // TODO: Delete
 private var json: [String: Any] = [
     "name": "Eayadon Falconmoon",
     "class": "Fighter",
     "level": 3,
     "race": "Human",
     "background": "Noble",
     "alignment": 2,
     "experiencePoints": 1416,
     "abilityScores": [
         "strength": 16,
         "dexterity": 9,
         "constitution": 15,
         "intelligence": 11,
         "wisdom": 13,
         "charisma": 14,
     ],
     "inspiration": 0,
     "proficiencyBonus": 2,
     "savingThrows": [
         "strength": true,
         "dexterity": false,
         "consitution": true,
         "intelligence": false,
         "widsom": false,
         "charisma": false,
     ],
     "skills": [
         "acrobatics": false,
         "animalHandling": false,
         "arcana": false,
         "athletics": true,
         "deception": false,
         "history": true,
         "insight": false,
         "intimidation": false,
         "investigation": false,
         "medicine": false,
         "nature": false,
         "perception": true,
         "performance": false,
         "persuasion": true,
         "religion": false,
         "sleightOfHand": false,
         "stealth": false,
         "survival": false,
     ],
     "passiveWisdom": 13,
     "otherProficienciesAndSkills": "Proficiencies: All armors, shields, simple weapons, martial weapons, playing cards\nLanguages: Common, Draconic, Dwarvish",
     "stats": [
         "armorClass": 17,
         "initiative": -1,
         "speed": 30,
         "maxHP": 28,
         "curHP": 28,
         "tempHP": 12,
         "hitDice": "1d10",
         "deathSaveSuccess": 0,
         "deathSaveFailure": 0,
     ],
     "attacks": "Javelin throw\n+5 ATK Bonus\nDamage:1d6 + 3 piercing",
     "equipment": "Chain mail, greataxe, 3 javelins,        backpack, blanket, tinderbox, 2 days of rations, waterskin, set of fine clothes, signet ring, scroll of pedigree",
     "personality": [
         "traits": "My flattery makes those I talk to feel wonderful and important. Also, I don’t like to get dirty, and I won’t be caught dead in unsuitable accommodations.",
         "ideals": "Responsiblity. It's the duty of a noble to protect the common people, not bully them.",
         "bonds": "My greataxe is a family heirloom, and it's by far my most preious possession",
         "flaws": "I have a hard time resisting the allure of wealth, especially gold. Wealth can help me restore my legacy.",
     ],
     "featuresAndTraits": "Second Wind. You have a limited well of stamina you can draw on to protect yourself from harm. You can use a bonus action to regain hit points equal to 1d10 + your fighter level. Once you use this feature, you must finish a short or long rest before you can use it again.",
     "appearance": [],
     "backstory": "Your family is no stranger to wealth, power, and privilege. I nthe glory days of Neverwinter, your parnts were the count and countess of Corlinn Hill, a large estate located in the hills northeast of the city. But MOunt Hotenow erupted thirty years ago, devastating Neverwinter and erasing Corlinn Hill from the map. Instaead of growing up on an estate, you were raised in a small but comfortable town housein in Waterdeep. As an adult, yo ustand to inherit a meaningless title and little else.",
     "darkGifts": "",
     "features": "",
     "allies": "",
     "treasure": "",
     "spellcasting": [],
     "spells": []
 ]
 
 */

