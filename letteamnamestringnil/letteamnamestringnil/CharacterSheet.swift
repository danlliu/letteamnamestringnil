//
//  Player.swift
//  letteamnamestringnil
//
//  Created by Alexis Covacha on 10/31/21.
//

import Foundation
import SwiftUI

class CharacterSheet: ObservableObject {
    
    @Published public var id: String
    @Published public var basicInfo: PlayerBasicInfo
    @Published public var stats: PlayerStats
    @Published public var skills: PlayerSkills
    @Published public var attacks: String
    @Published public var spellcasting: [String: Any]
    @Published public var spells: [Spells]
    @Published public var inventory: PlayerInventory
    @Published public var background: PlayerBackgroundInfo
    @Published public var notes: String
    
//    @Published var hitDice: [Int: Int]
    
    init(json: [String: Any]) {

        var character: [String: Any] = [:]
        character["name"]      = json["name"]
        character["class"]     = json["class"]
        character["race"]      = json["race"]
        character["alignment"] = json["alignment"]
        
        var stats: [String: Any] = json["stats"] as! [String: Any]
        stats["level"]         = json["level"]
        stats["xp"]            = json["experiencePoints"]
        stats["abilityScores"] = json["abilityScores"]
        stats["perception"]    = json["passiveWisdom"]
        stats["inspiration"]   = json["inspiration"]
        stats["profBonus"]     = json["proficiencyBonus"]
        stats["savingThrows"]  = json["savingThrows"]
        
        let personality = Personality(json: json["personality"] as! [String: String])
        let spellsData = json["spells"] as! [[String: Any]]
        
        id = json["id"] as! String
        basicInfo = PlayerBasicInfo(characterInfo: character)
        self.stats = PlayerStats(stats: stats)
        skills = PlayerSkills(skills: json["skills"] as! [String: Bool])
        attacks = json["attacks"] as! String
        inventory = PlayerInventory(equipment: json["equipment"] as! String,
                                         darkGifts: json["darkGifts"] as! String,
                                         treasure: json["trearuse"] as! String)
        background = PlayerBackgroundInfo(
            background: json["background"] as! String,
            backstory: json["backstory"] as! String,
            proficiencies: json["otherProficienciesAndSkills"] as! String,
            features: json["featuresAndTraits"] as! String,
            personality: personality,
            appearance: json["appearance"] as! [String: Any]
        )
        spellcasting = json["spellcasting"] as! [String: Any]
        spells = []
        notes = json["notes"] as! String

        for (spell) in spellsData {
            spells.append(Spells(name: spell["name"] as! String,
                   components: spell["components"] as! String,
                   level: spell["level"] as! Int,
                   description: spell["description"] as! String))
        }

    }
    
}

struct PlayerSkills: Hashable {
    var acrobatics: Bool
    var animalHandling: Bool
    var arcana: Bool
    var athletics: Bool
    var deception: Bool
    var history: Bool
    var insight: Bool
    var intimidation: Bool
    var investigation: Bool
    var medicine: Bool
    var nature: Bool
    var perception: Bool
    var performance: Bool
    var persuasion: Bool
    var religion: Bool
    var sleightOfHand: Bool
    var stealth: Bool
    var survival: Bool

    init(skills: [String: Bool]) {
        acrobatics = skills["acrobatics"]!
        animalHandling = skills["animalHandling"]!
        arcana = skills["arcana"]!
        athletics = skills["athletics"]!
        deception = skills["deception"]!
        history = skills["history"]!
        insight = skills["insight"]!
        intimidation = skills["intimidation"]!
        investigation = skills["investigation"]!
        medicine = skills["medicine"]!
        nature = skills["nature"]!
        perception = skills["perception"]!
        performance = skills["performance"]!
        persuasion = skills["persuasion"]!
        religion = skills["religion"]!
        sleightOfHand = skills["sleightOfHand"]!
        stealth = skills["stealth"]!
        survival = skills["survival"]!
    }
}

struct PlayerBasicInfo: Hashable {
    var name: String
    var className: String
    var race: String
    var alignment: Int

    init(characterInfo: [String: Any]) {
        name      = characterInfo["name"] as! String
        className = characterInfo["class"] as! String
        race      = characterInfo["race"] as! String
        alignment = characterInfo["alignment"] as! Int
    }
}

struct SavingThrows: Hashable {
    var str: Bool
    var dex: Bool
    var con: Bool
    var int: Bool
    var wis: Bool
    var char: Bool

    init(savingThrows: [String: Bool]) {
        str = savingThrows["strength"]!
        dex = savingThrows["dexterity"]!
        con = savingThrows["constitution"]!
        int = savingThrows["intelligence"]!
        wis = savingThrows["wisdom"]!
        char = savingThrows["charisma"]!
    }
}

struct PlayerStats: Hashable {
    var level: Int
    var xp: Int
    var maxHp: Int
    var curHp: Int
    var abilityScores: [String: Int]
    var perception: Int
    var inspiration: Int
    var proficiencyBonus: Int
    var savingThrows: SavingThrows
    
    init(stats: [String: Any]) {
        level = stats["level"] as! Int
        xp = stats["xp"] as! Int
        maxHp = stats["maxHP"] as! Int
        curHp = stats["curHP"] as! Int
        abilityScores = stats["abilityScores"] as! [String: Int]
        perception = stats["perception"] as! Int
        inspiration = stats["inspiration"] as! Int
        proficiencyBonus = stats["profBonus"] as! Int
        savingThrows = SavingThrows(savingThrows: stats["savingThrows"] as! [String: Bool])
    }
    
}

struct Spells: Hashable {
    var name: String
    var components: String
    var level: Int
    var description: String
    
    static func == (lhs: Spells, rhs: Spells) -> Bool {
        (lhs.name == rhs.name &&
                lhs.components == rhs.components &&
                lhs.level == rhs.level &&
                lhs.description == rhs.description)
    }
}


struct PlayerBackgroundInfo {
    var background: String
    var backstory: String
    var proficiencies: String
    var features: String
    var personality: Personality
    var appearance: [String: Any]
}

struct Personality: Hashable {
    var traits: String
    var ideals: String
    var bonds: String
    var flaws: String
    
    init(json: [String: String]) {
        traits = json["traits"] ?? ""
        ideals = json["ideals"] ?? ""
        bonds  = json["bonds"] ?? ""
        flaws  = json["flaws"] ?? ""
    }
}

struct PlayerInventory: Hashable {
    var equipment: String
    var darkGifts: String
    var treasure: String
}
