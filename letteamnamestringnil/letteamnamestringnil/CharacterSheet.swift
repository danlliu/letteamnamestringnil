//
//  Player.swift
//  letteamnamestringnil
//
//  Created by Alexis Covacha on 10/31/21.
//

import Foundation
import SwiftUI

class CharacterSheet: ObservableObject {

    @Published var basicInfo: PlayerBasicInfo
    @Published var stats: PlayerStats
    @Published var skills: Skills
    @Published var attacks: String
    @Published var spellcasting: [String: Any]
    @Published var spells: [Spells]
    @Published var inventory: PlayerInventory
    @Published var background: PlayerBackgroundInfo
    @Published var notes: String = ""

//    @Published var hitDice: [Int: Int]
    
    init () {
        self.basicInfo = PlayerBasicInfo(characterInfo: [:])
        self.stats = PlayerStats(stats: [:])
        self.skills = Skills(sk: [:])
        self.attacks = ""
        self.spellcasting = [:]
        self.spells = []
        self.inventory = PlayerInventory(equipment: "", darkGifts: "", treasure: "")
        self.background = PlayerBackgroundInfo(background: "", backstory: "", proficiencies: "", features: "", featuresAndTraits: "", allies: "", personality: Personality(json: [:]))
        self.notes = ""
        
    }

    init(json: [String: Any]) {

        var character: [String: Any] = [:]
        character["name"]      = json["name"]
        character["class"]     = json["class"]
        character["race"]      = json["race"]
        character["alignment"] = json["alignment"]
        character["age"] = json["age"]
        character["eyes"] = json["eyes"]
        character["height"] = json["height"]
        character["weight"] = json["weight"]
        character["isNPC"]      = json["is_npc"]
        character["isFriendly"] = json["is_friendly"]

        var stats: [String: Any] = json["stats"] as! [String: Any]
        stats["ac"]            = json["armor_class"]
        stats["initiative"]    = json["initiative"]
        stats["maxHP"]         = json["max_hp"]
        stats["curHP"]         = json["cur_hp"]
        stats["tmpHP"]         = json["tmp_hp"]
        stats["hitDice"]       = json["hit_dice"]
        stats["level"]         = json["level"]
        stats["xp"]            = json["experience_points"]
        stats["speed"]         = json["speed"]
        stats["abilityScores"] = json["abilities"]
        stats["perception"]    = json["passive_wisdom"]
        stats["inspiration"]   = json["inspiration"]
        stats["profBonus"]     = json["proficiency_bonus"]
        stats["savingThrows"]  = json["saving"]
        stats["deathSaveSuccess"] = json["death_save_success"]
        stats["deathSaveFailure"] = json["death_save_failure"]

        let personality = Personality(json: json)
        let spellsData = (json["spells"] as! [String: Any])["by_level"] as! [[String: Any]]

        self.basicInfo = PlayerBasicInfo(characterInfo: character)
        self.stats = PlayerStats(stats: stats)
        self.skills = Skills(sk: json["skills"] as! [String: Bool])
        self.attacks = json["attacks"] as! String
        self.inventory = PlayerInventory(equipment: json["equipment"] as? String ?? "",
                                         darkGifts: json["dark_gifts"] as? String ?? "",
                                         treasure: json["treasure"] as? String ?? "")
        self.background = PlayerBackgroundInfo(
            background: json["background"] as! String,
            backstory: json["backstory"] as! String,
            proficiencies: json["other_proficiencies_Skills"] as! String,
            features: json["features"] as! String,
            featuresAndTraits: json["features_and_traits"] as! String,
                allies: json["allies"] as! String,
            personality: personality
        )
        self.notes = json["notes"] as! String
        self.spellcasting = json["spells"] as! [String: Any]
        self.spells = []

        for level in spellsData {
            for spell in level["spells"] as! [[String: Any]] {
                self.spells.append(Spells(name: spell["name"] as! String,
                        charges: spell["charges"] as! Int))
            }
        }
    }

    func toDictionary() -> [String:Any] {
        // TODO IMPLEMENT
        return [:]
    }

}

struct PlayerBasicInfo: Hashable {
    var name: String
    var className: String
    var isNPC: Bool
    var isFriendly: Bool
    var race: String
    var alignment: Int

    init(characterInfo: [String: Any]) {
        self.name      = characterInfo["name"] as? String ?? ""
        self.className = characterInfo["clss"] as? String ?? ""
        self.race      = characterInfo["race"] as? String ?? ""
        self.alignment = characterInfo["alignment"] as? Int ?? 0
        self.isNPC = characterInfo["isNPC"] as? Bool ?? false
        self.isFriendly = characterInfo["isFriendly"] as? Bool ?? false
    }
}

struct PlayerStats: Hashable {
    var ac: Int
    var initiative: Int
    var maxHP, curHP, tmpHP: Int
    var hitDice: Int
    var level: Int
    var xp: Int
    var speed: Int
    var abilityScores: [String:Int]
    var perception: Int
    var inspiration: Int
    var profBonus: Int
    var savingThrows: SavingThrows
    var deathSaveSuccess: Int
    var deathSaveFailure: Int

    init(stats: [String: Any]) {
        ac = stats["ac"] as? Int ?? 0
        initiative = stats["initiative"] as? Int ?? 0
        maxHP = stats["maxHP"] as? Int ?? 0
        curHP = stats["curHP"] as? Int ?? 0
        tmpHP = stats["tmpHP"] as? Int ?? 0
        hitDice = stats["hitDice"] as? Int ?? 0
        level = stats["level"] as? Int ?? 0
        xp = stats["xp"] as? Int ?? 0
        speed = stats["speed"] as? Int ?? 0
        abilityScores = stats["abilityScores"] as? [String:Int] ?? [:]
        perception = stats["perception"] as? Int ?? 0
        inspiration = stats["inspiration"] as? Int ?? 0
        profBonus = stats["profBonus"] as? Int ?? 0
        savingThrows = SavingThrows(st: stats["savingThrows"] as? [String:Bool] ?? [:])
        deathSaveSuccess = stats["deathSaveSuccess"] as? Int ?? 0
        deathSaveFailure = stats["deathSaveFailure"] as? Int ?? 0
    }

}

struct Spells: Hashable {
    var name: String = ""
    var charges: Int = 0
}


struct PlayerBackgroundInfo {
    var background: String = ""
    var backstory: String = ""
    var proficiencies: String = ""
    var features: String = ""
    var featuresAndTraits: String = ""
    var allies: String = ""
    var personality: Personality = Personality(json: [:])
}

struct Personality: Hashable {
    var traits: String
    var ideals: String
    var bonds: String
    var flaws: String

    init(json: [String: Any]) {
        traits = json["traits"] as? String ?? ""
        ideals = json["ideals"] as? String ?? ""
        bonds  = json["bonds"] as? String ?? ""
        flaws  = json["flaws"] as? String ?? ""
    }
}

struct PlayerInventory: Hashable {
    var equipment: String = ""
    var darkGifts: String = ""
    var treasure: String = ""
}

struct SavingThrows: Hashable {
    var str, dex, con, int, wis, char: Bool

    init(st: [String: Bool]) {
        str = st["strength"] ?? false
        dex = st["dexterity"] ?? false
        con = st["constitution"] ?? false
        int = st["intelligence"] ?? false
        wis = st["wisdom"] ?? false
        char = st["charisma"] ?? false
    }
}

struct Skills: Hashable {
    var acrobatics, animalHandling, arcana, athletics, deception, history, insight,
        intimidation, investigation, medicine, nature, perception, performance, persuasion,
        religion, sleightOfHand, stealth, survival: Bool

    init(sk: [String: Bool]) {
        acrobatics = sk["acrobatics"] ?? false
        animalHandling = sk["animal_handling"] ?? false
        arcana = sk["arcana"] ?? false
        athletics = sk["athletics"] ?? false
        deception = sk["deception"] ?? false
        history = sk["history"] ?? false
        insight = sk["insight"] ?? false
        intimidation = sk["intimidation"] ?? false
        investigation = sk["investigation"] ?? false
        medicine = sk["medicine"] ?? false
        nature = sk["nature"] ?? false
        perception = sk["perception"] ?? false
        performance = sk["performance"] ?? false
        persuasion = sk["persuasion"] ?? false
        religion = sk["religion"] ?? false
        sleightOfHand = sk["sleight_of_hand"] ?? false
        stealth = sk["stealth"] ?? false
        survival = sk["survival"] ?? false
    }
}
