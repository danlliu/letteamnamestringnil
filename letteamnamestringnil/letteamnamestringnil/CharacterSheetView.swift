//
//  CharacterSheetView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

struct CharacterSheetView: View {
    
    @State var race: String = ""
    
    var body: some View {
        VStack {
            Text("Character Sheet")
                .font(.largeTitle)
            
            Divider()
            Group {
                Text("Character Information")
                    .font(.headline)
                VStack {
                    TextField("Character Race", text: $race)
                        .border(.gray, width: 1)
                }.padding(16)
            }
            Divider()
            Group {
                Text("Ability Scores")
                    .font(.headline)
                VStack {
                    TextField("Character Race", text: $race)
                        .border(.gray, width: 1)
                }.padding(16)
            }
            Divider()
            Group {
                Text("Other Stats")
                    .font(.headline)
                VStack {
                    TextField("Character Race", text: $race)
                        .border(.gray, width: 1)
                }.padding(16)
            }
        }
    }
}

struct CharacterSheetView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterSheetView()
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
