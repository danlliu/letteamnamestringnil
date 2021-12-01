//
//  CharacterSheetView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import Combine
import SwiftUI

// https://stackoverflow.com/questions/57021722/swiftui-optional-textfield
func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

struct CharacterSheetView: View {

    var partyCode: String
    var username: String?
    var npcid: String?

    @State var csheet: CharacterSheet = CharacterSheet()
    @State var xpText: String = ""

    @State var newSpellName: String = ""
    @State var newSpellCasts: Int = 0

    init(partyCode: String, username: String) {
        self.partyCode = partyCode
        self.username = username
        self.npcid = nil
    }

    init(partyCode: String, npcid: String) {
        self.partyCode = partyCode
        self.username = nil
        self.npcid = npcid
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            VStack {
                Text("Character Sheet")
                    .font(.largeTitle)
                
                if csheet != nil {
                    Button(action: { Task {
                        if username != nil {
                            await Store.shared.postPlayerData(code: partyCode, player: username!, isDM: false, csheet: csheet)
                        } else {
                            await Store.shared.postNPCData(code: partyCode, npcid: npcid!, csheet: csheet)
                        }
                    } }) {
                        Text("Save changes")
                    }
                    
                    Group {
                        Divider()
                        Group {
                            Text("Character Information")
                                .font(.headline)
                            VStack {
                                HStack {
                                    Text("Character Name:")
                                    TextField("Character Name", text: $csheet.basicInfo.name)
                                        .border(.gray, width: 1)
                                }
                                HStack {
                                    Text("Character Class:")
                                    TextField("Character Class", text: $csheet.basicInfo.className)
                                        .border(.gray, width: 1)
                                }
                                HStack {
                                    Text("Character Level:")
                                    Stepper {
                                        Text("\(csheet.stats.level)")
                                    } onIncrement: {
                                        csheet.stats.level += 1
                                    } onDecrement: {
                                        csheet.stats.level -= 1
                                    }
                                }
                                HStack {
                                    Text("Character Race:")
                                    TextField("Character Race", text: $csheet.basicInfo.race)
                                        .border(.gray, width: 1)
                                }
                                HStack {
                                    Text("Character Background:")
                                    TextField("Character Background:", text: $csheet.background.background)
                                        .border(.gray, width: 1)
                                }
                                HStack {
                                    Text("Character Alignment:")
                                    VStack {
                                        HStack {
                                            Button(action: { () in csheet.basicInfo.alignment = 0 }) {
                                                Text("LG")
                                            }
                                            Button(action: { () in csheet.basicInfo.alignment = 1 }) {
                                                Text("LN")
                                            }
                                            Button(action: { () in csheet.basicInfo.alignment = 2 }) {
                                                Text("LE")
                                            }
                                        }
                                        HStack {
                                            Button(action: { () in csheet.basicInfo.alignment = 3 }) {
                                                Text("NG")
                                            }
                                            Button(action: { () in csheet.basicInfo.alignment = 4 }) {
                                                Text("TN")
                                            }
                                            Button(action: { () in csheet.basicInfo.alignment = 5 }) {
                                                Text("NE")
                                            }
                                        }
                                        HStack {
                                            Button(action: { () in csheet.basicInfo.alignment = 6 }) {
                                                Text("CG")
                                            }
                                            Button(action: { () in csheet.basicInfo.alignment = 7 }) {
                                                Text("CN")
                                            }
                                            Button(action: { () in csheet.basicInfo.alignment = 8 }) {
                                                Text("CE")
                                            }
                                        }
                                    }
                                }
                                HStack {
                                    Text("Experience Points:")
                                    TextField("Experience Points", text: $xpText)
                                        .border(.gray, width: 1)
                                        .keyboardType(.numberPad)
                                        .onReceive(Just(xpText)) { newValue in
                                            // adapted from https://stackoverflow.com/questions/58733003/swiftui-how-to-create-textfield-that-only-accepts-numbers
                                            let filtered = newValue.filter {
                                                "0123456789".contains($0)
                                            }
                                            if filtered != newValue {
                                                self.xpText = newValue
                                                csheet.stats.xp = Int(filtered)!
                                            }
                                        }
                                }
                            }.padding(16)
                        }
                        
                        Divider()
                        Group {
                            Text("Character Statistics")
                                .font(.headline)
                            VStack {
                                HStack {
                                    Text("STR")
                                    Stepper {
                                        let str = csheet.stats.abilityScores["strength"]!
                                        Text("\(str)")
                                    } onIncrement: {
                                        csheet.stats.abilityScores["strength"]! += 1
                                    } onDecrement: {
                                        csheet.stats.abilityScores["strength"]! -= 1
                                    }
                                }
                                HStack {
                                    Text("DEX")
                                    Stepper {
                                        let dex = csheet.stats.abilityScores["dexterity"]!
                                        Text("\(dex)")
                                    } onIncrement: {
                                        csheet.stats.abilityScores["dexterity"]! += 1
                                    } onDecrement: {
                                        csheet.stats.abilityScores["dexterity"]! -= 1
                                    }
                                }
                                HStack {
                                    Text("CON")
                                    Stepper {
                                        let con = csheet.stats.abilityScores["constitution"]!
                                        Text("\(con)")
                                    } onIncrement: {
                                        csheet.stats.abilityScores["constitution"]! += 1
                                    } onDecrement: {
                                        csheet.stats.abilityScores["constitution"]! -= 1
                                    }
                                }
                                HStack {
                                    Text("INT")
                                    Stepper {
                                        let int = csheet.stats.abilityScores["intelligence"]!
                                        Text("\(int)")
                                    } onIncrement: {
                                        csheet.stats.abilityScores["intelligence"]! += 1
                                    } onDecrement: {
                                        csheet.stats.abilityScores["intelligence"]! -= 1
                                    }
                                }
                                HStack {
                                    Text("WIS")
                                    Stepper {
                                        let wis = csheet.stats.abilityScores["wisdom"]!
                                        Text("\(wis)")
                                    } onIncrement: {
                                        csheet.stats.abilityScores["wisdom"]! += 1
                                    } onDecrement: {
                                        csheet.stats.abilityScores["wisdom"]! -= 1
                                    }
                                }
                                HStack {
                                    Text("CHAR")
                                    Stepper {
                                        let char = csheet.stats.abilityScores["charisma"]!
                                        Text("\(char)")
                                    } onIncrement: {
                                        csheet.stats.abilityScores["charisma"]! += 1
                                    } onDecrement: {
                                        csheet.stats.abilityScores["charisma"]! -= 1
                                    }
                                }
                            }.padding(16)
                            VStack {
                                HStack {
                                    Text("Inspiration: \(csheet.stats.inspiration)")
                                    Stepper {
                                        Text("\(csheet.stats.inspiration)")
                                    } onIncrement: {
                                        csheet.stats.inspiration += 1
                                    } onDecrement: {
                                        csheet.stats.inspiration -= 1
                                    }
                                }
                                HStack {
                                    Text("Proficiency Bonus: \(csheet.stats.profBonus)")
                                    Stepper {
                                        Text("\(csheet.stats.profBonus)")
                                    } onIncrement: {
                                        csheet.stats.profBonus += 1
                                    } onDecrement: {
                                        csheet.stats.profBonus -= 1
                                    }
                                }
                                
                                // Ability scores
                                VStack {
                                    Text("Saving Throws:")
                                    HStack {
                                        Toggle(isOn: $csheet.stats.savingThrows.str) {
                                            Text("STR")
                                        }
                                    }
                                    HStack {
                                        Toggle(isOn: $csheet.stats.savingThrows.dex) {
                                            Text("DEX")
                                        }
                                    }
                                    HStack {
                                        Toggle(isOn: $csheet.stats.savingThrows.con) {
                                            Text("CON")
                                        }
                                    }
                                    HStack {
                                        Toggle(isOn: $csheet.stats.savingThrows.int) {
                                            Text("INT")
                                        }
                                    }
                                    HStack {
                                        Toggle(isOn: $csheet.stats.savingThrows.wis) {
                                            Text("WIS")
                                        }
                                    }
                                    HStack {
                                        Toggle(isOn: $csheet.stats.savingThrows.char) {
                                            Text("CHAR")
                                        }
                                    }
                                }
                                
                                // Skills
                                VStack {
                                    Group {
                                        Toggle(isOn: $csheet.skills.acrobatics) {
                                            Text("Acrobatics")
                                        }
                                        Toggle(isOn: $csheet.skills.animalHandling) {
                                            Text("Animal Handling")
                                        }
                                        Toggle(isOn: $csheet.skills.arcana) {
                                            Text("Arcana")
                                        }
                                        Toggle(isOn: $csheet.skills.athletics) {
                                            Text("Athletics")
                                        }
                                        Toggle(isOn: $csheet.skills.deception) {
                                            Text("Deception")
                                        }
                                        Toggle(isOn: $csheet.skills.history) {
                                            Text("History")
                                        }
                                        Toggle(isOn: $csheet.skills.insight) {
                                            Text("Insight")
                                        }
                                        Toggle(isOn: $csheet.skills.intimidation) {
                                            Text("Intimidation")
                                        }
                                    }
                                    Group {
                                        Toggle(isOn: $csheet.skills.investigation) {
                                            Text("Investigation")
                                        }
                                        Toggle(isOn: $csheet.skills.medicine) {
                                            Text("Medicine")
                                        }
                                        Toggle(isOn: $csheet.skills.nature) {
                                            Text("Nature")
                                        }
                                        Toggle(isOn: $csheet.skills.perception) {
                                            Text("Perception")
                                        }
                                        Toggle(isOn: $csheet.skills.performance) {
                                            Text("Performance")
                                        }
                                        Toggle(isOn: $csheet.skills.persuasion) {
                                            Text("Persuasion")
                                        }
                                        Toggle(isOn: $csheet.skills.religion) {
                                            Text("Religion")
                                        }
                                        Toggle(isOn: $csheet.skills.sleightOfHand) {
                                            Text("Sleight of Hand")
                                        }
                                        Toggle(isOn: $csheet.skills.stealth) {
                                            Text("Stealth")
                                        }
                                        Toggle(isOn: $csheet.skills.survival) {
                                            Text("Survival")
                                        }
                                    }
                                }
                                
                                HStack {
                                    Text("Passive Perception: \(csheet.stats.perception)")
                                    Stepper {
                                        Text("\(csheet.stats.perception)")
                                    } onIncrement: {
                                        csheet.stats.perception += 1
                                    } onDecrement: {
                                        csheet.stats.perception -= 1
                                    }
                                }
                            }.padding(16)
                            
                            VStack {
                                Stepper {
                                    Text("Max HP: \(csheet.stats.maxHP)")
                                } onIncrement: {
                                    csheet.stats.maxHP += 1
                                } onDecrement: {
                                    csheet.stats.maxHP -= 1
                                }
                                Stepper {
                                    Text("Current HP: \(csheet.stats.curHP)")
                                } onIncrement: {
                                    csheet.stats.curHP += 1
                                } onDecrement: {
                                    csheet.stats.curHP -= 1
                                }
                                Stepper {
                                    Text("Temporary HP: \(csheet.stats.tmpHP)")
                                } onIncrement: {
                                    csheet.stats.curHP += 1
                                } onDecrement: {
                                    csheet.stats.curHP -= 1
                                }
                            }.padding(16)
                        }
                        
                        Divider()
                        Group {
                            Group {
                                Text("Personality Traits:")
                                TextEditor(text: $csheet.background.personality.traits)
                                    .border(.gray, width: 1)
                            }
                            Group {
                                Text("Ideals:")
                                TextEditor(text: $csheet.background.personality.ideals)
                                    .border(.gray, width: 1)
                            }
                            Group {
                                Text("Bonds:")
                                TextEditor(text: $csheet.background.personality.bonds)
                                    .border(.gray, width: 1)
                            }
                            Group {
                                Text("Flaws:")
                                TextEditor(text: $csheet.background.personality.flaws)
                                    .border(.gray, width: 1)
                            }
                            
                            Group {
                                Text("Attacks:")
                                TextEditor(text: $csheet.attacks)
                                    .border(.gray, width: 1)
                            }
                            Group {
                                Text("Equipment:")
                                TextEditor(text: $csheet.inventory.equipment)
                                    .border(.gray, width: 1)
                            }
                            Group {
                                Text("Proficiencies:")
                                TextEditor(text: $csheet.background.proficiencies)
                                    .border(.gray, width: 1)
                            }
                            Group {
                                Text("Features and Traits:")
                                TextEditor(text: $csheet.background.features)
                                    .border(.gray, width: 1)
                            }
                        }
                        
                        Divider()
                        Group {
                            Group {
                                Text("Dark Gifts:")
                                TextEditor(text: $csheet.inventory.darkGifts)
                                    .border(.gray, width: 1)
                            }
                            Group {
                                Text("Treasure:")
                                TextEditor(text: $csheet.inventory.treasure)
                                    .border(.gray, width: 1)
                            }
                            Group {
                                Text("Other Notes:")
                                TextEditor(text: $csheet.notes)
                            }
                        }
                        
                        Divider()
                        Group {
                            List {
                                ForEach(csheet.spells, id: \.name) { spell in
                                    HStack {
                                        Button(action: {() in
                                            csheet.spells = csheet.spells.filter({x in x.name != spell.name})
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                        VStack {
                                            Text("\(spell.name) (\(spell.charges))")
                                        }
                                    }
                                }
                            }
                            Divider()
                            Group {
                                TextField("Spell Name:", text: $newSpellName)
                                Stepper {
                                    Text("Spell Casts: \(newSpellCasts)")
                                } onIncrement: {
                                    newSpellCasts += 1
                                } onDecrement: {
                                    newSpellCasts -= 1
                                }
                                Button(action: {() in
                                    csheet.spells.append(Spells(
                                        name: newSpellName,
                                        charges: newSpellCasts))
                                }){
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                } else {
                    Text("loading...")
                }
            }
            .task {
                if username != nil {
                    let response = await Store.shared.getPlayerData(code: partyCode, player: username!)
                    csheet = response.csheet!
                } else {
                    let response = await Store.shared.getNPCData(code: partyCode, npcid: npcid!)
                    csheet = response.csheet!
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

//struct CharacterSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        CharacterSheetView(csheet: CharacterSheet(json: [
//            "name": "Eayadon Falconmoon",
//            "class": "Fighter",
//            "level": 3,
//            "race": "Human",
//            "background": "Noble",
//            "alignment": 2,
//            "experiencePoints": 1416,
//            "abilityScores": [
//                "strength": 16,
//                "dexterity": 9,
//                "constitution": 15,
//                "intelligence": 11,
//                "wisdom": 13,
//                "charisma": 14,
//            ],
//            "inspiration": 0,
//            "proficiencyBonus": 2,
//            "savingThrows": [
//                "strength": true,
//                "dexterity": false,
//                "consitution": true,
//                "intelligence": false,
//                "widsom": false,
//                "charisma": false,
//            ],
//            "skills": [
//                "acrobatics": false,
//                "animalHandling": false,
//                "arcana": false,
//                "athletics": true,
//                "deception": false,
//                "history": true,
//                "insight": false,
//                "intimidation": false,
//                "investigation": false,
//                "medicine": false,
//                "nature": false,
//                "perception": true,
//                "performance": false,
//                "persuasion": true,
//                "religion": false,
//                "sleightOfHand": false,
//                "stealth": false,
//                "survival": false,
//            ],
//            "passiveWisdom": 13,
//            "otherProficienciesAndSkills": "Proficiencies: All armors, shields, simple weapons, martial weapons, playing cards\nLanguages: Common, Draconic, Dwarvish",
//            "stats": [
//                "armorClass": 17,
//                "initiative": -1,
//                "speed": 30,
//                "maxHP": 28,
//                "curHP": 28,
//                "tempHP": 12,
//                "hitDice": "1d10",
//                "deathSaveSuccess": 0,
//                "deathSaveFailure": 0,
//            ],
//            "attacks": "Javelin throw\n+5 ATK Bonus\nDamage:1d6 + 3 piercing",
//            "equipment": "Chain mail, greataxe, 3 javelins,        backpack, blanket, tinderbox, 2 days of rations, waterskin, set of fine clothes, signet ring, scroll of pedigree",
//            "personality": [
//                "traits": "My flattery makes those I talk to feel wonderful and important. Also, I don’t like to get dirty, and I won’t be caught dead in unsuitable accommodations.",
//                "ideals": "Responsiblity. It's the duty of a noble to protect the common people, not bully them.",
//                "bonds": "My greataxe is a family heirloom, and it's by far my most preious possession",
//                "flaws": "I have a hard time resisting the allure of wealth, especially gold. Wealth can help me restore my legacy.",
//            ],
//            "featuresAndTraits": "Second Wind. You have a limited well of stamina you can draw on to protect yourself from harm. You can use a bonus action to regain hit points equal to 1d10 + your fighter level. Once you use this feature, you must finish a short or long rest before you can use it again.",
//            "appearance": [],
//            "backstory": "Your family is no stranger to wealth, power, and privilege. I nthe glory days of Neverwinter, your parnts were the count and countess of Corlinn Hill, a large estate located in the hills northeast of the city. But MOunt Hotenow erupted thirty years ago, devastating Neverwinter and erasing Corlinn Hill from the map. Instaead of growing up on an estate, you were raised in a small but comfortable town housein in Waterdeep. As an adult, yo ustand to inherit a meaningless title and little else.",
//            "darkGifts": "",
//            "features": "",
//            "allies": "",
//            "treasure": "",
//            "spellcasting": [],
//            "spells": [
//                [
//                    "name": "Faerie Fire",
//                    "components": "V",
//                    "level": 1,
//                    "description": "20ft cube Blue/Green/Violet, 10ft light, 60ft range"
//                ]
//            ],
//            "notes": ""
//        ]))
//    }
//}
//
///*
//
// // TODO: Delete
// private var json: [String: Any] = [
//     "name": "Eayadon Falconmoon",
//     "class": "Fighter",
//     "level": 3,
//     "race": "Human",
//     "background": "Noble",
//     "alignment": 2,
//     "experiencePoints": 1416,
//     "abilityScores": [
//         "strength": 16,
//         "dexterity": 9,
//         "constitution": 15,
//         "intelligence": 11,
//         "wisdom": 13,
//         "charisma": 14,
//     ],
//     "inspiration": 0,
//     "proficiencyBonus": 2,
//     "savingThrows": [
//         "strength": true,
//         "dexterity": false,
//         "consitution": true,
//         "intelligence": false,
//         "widsom": false,
//         "charisma": false,
//     ],
//     "skills": [
//         "acrobatics": false,
//         "animalHandling": false,
//         "arcana": false,
//         "athletics": true,
//         "deception": false,
//         "history": true,
//         "insight": false,
//         "intimidation": false,
//         "investigation": false,
//         "medicine": false,
//         "nature": false,
//         "perception": true,
//         "performance": false,
//         "persuasion": true,
//         "religion": false,
//         "sleightOfHand": false,
//         "stealth": false,
//         "survival": false,
//     ],
//     "passiveWisdom": 13,
//     "otherProficienciesAndSkills": "Proficiencies: All armors, shields, simple weapons, martial weapons, playing cards\nLanguages: Common, Draconic, Dwarvish",
//     "stats": [
//         "armorClass": 17,
//         "initiative": -1,
//         "speed": 30,
//         "maxHP": 28,
//         "curHP": 28,
//         "tempHP": 12,
//         "hitDice": "1d10",
//         "deathSaveSuccess": 0,
//         "deathSaveFailure": 0,
//     ],
//     "attacks": "Javelin throw\n+5 ATK Bonus\nDamage:1d6 + 3 piercing",
//     "equipment": "Chain mail, greataxe, 3 javelins,        backpack, blanket, tinderbox, 2 days of rations, waterskin, set of fine clothes, signet ring, scroll of pedigree",
//     "personality": [
//         "traits": "My flattery makes those I talk to feel wonderful and important. Also, I don’t like to get dirty, and I won’t be caught dead in unsuitable accommodations.",
//         "ideals": "Responsiblity. It's the duty of a noble to protect the common people, not bully them.",
//         "bonds": "My greataxe is a family heirloom, and it's by far my most preious possession",
//         "flaws": "I have a hard time resisting the allure of wealth, especially gold. Wealth can help me restore my legacy.",
//     ],
//     "featuresAndTraits": "Second Wind. You have a limited well of stamina you can draw on to protect yourself from harm. You can use a bonus action to regain hit points equal to 1d10 + your fighter level. Once you use this feature, you must finish a short or long rest before you can use it again.",
//     "appearance": [],
//     "backstory": "Your family is no stranger to wealth, power, and privilege. I nthe glory days of Neverwinter, your parnts were the count and countess of Corlinn Hill, a large estate located in the hills northeast of the city. But MOunt Hotenow erupted thirty years ago, devastating Neverwinter and erasing Corlinn Hill from the map. Instaead of growing up on an estate, you were raised in a small but comfortable town housein in Waterdeep. As an adult, yo ustand to inherit a meaningless title and little else.",
//     "darkGifts": "",
//     "features": "",
//     "allies": "",
//     "treasure": "",
//     "spellcasting": [],
//     "spells": []
// ]
//
// */
