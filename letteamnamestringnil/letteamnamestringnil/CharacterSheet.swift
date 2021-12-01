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
            personality: personality,
            appearance: json["appearance"] as! [String: Any]
        )
        self.notes = json["notes"] as! String
        self.spellcasting = json["spellcasting"] as! [String: Any]
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
        self.name      = characterInfo["name"] as! String
        self.className = characterInfo["clss"] as! String
        self.race      = characterInfo["race"] as! String
        self.alignment = characterInfo["alignment"] as! Int
        self.isNPC = characterInfo["isNPC"] as! Bool
        self.isFriendly = characterInfo["isFriendly"] as! Bool
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
        ac = stats["ac"] as! Int
        initiative = stats["initiative"] as! Int
        maxHP = stats["maxHP"] as! Int
        curHP = stats["curHP"] as! Int
        tmpHP = stats["tmpHP"] as! Int
        hitDice = stats["hitDice"] as! Int
        level = stats["level"] as! Int
        xp = stats["xp"] as! Int
        speed = stats["speed"] as! Int
        abilityScores = stats["abilityScores"] as! [String:Int]
        perception = stats["perception"] as! Int
        inspiration = stats["inspiration"] as! Int
        profBonus = stats["profBonus"] as! Int
        savingThrows = SavingThrows(st: stats["savingThrows"] as! [String:Bool])
        deathSaveSuccess = stats["deathSaveSuccess"] as! Int
        deathSaveFailure = stats["deathSaveFailure"] as! Int
    }

}

struct Spells: Hashable {
    var name: String
    var charges: Int
}


struct PlayerBackgroundInfo {
    var background: String
    var backstory: String
    var proficiencies: String
    var features: String
    var featuresAndTraits: String
    var allies: String
    var personality: Personality
    var appearance: [String: Any]
}

struct Personality: Hashable {
    var traits: String?
    var ideals: String?
    var bonds: String?
    var flaws: String?

    init(json: [String: Any]) {
        traits = json["traits"] as? String
        ideals = json["ideals"] as? String
        bonds  = json["bonds"] as? String
        flaws  = json["flaws"] as? String
    }
}

struct PlayerInventory: Hashable {
    var equipment: String
    var darkGifts: String
    var treasure: String
}

struct SavingThrows: Hashable {
    var str, dex, con, int, wis, char: Bool

    init(st: [String: Bool]) {
        str = st["strength"]!
        dex = st["dexterity"]!
        con = st["constitution"]!
        int = st["intelligence"]!
        wis = st["wisdom"]!
        char = st["charisma"]!
    }
}

struct Skills: Hashable {
    var acrobatics, animalHandling, arcana, athletics, deception, history, insight,
        intimidation, investigation, medicine, nature, perception, performance, persuasion,
        religion, sleightOfHand, stealth, survival: Bool

    init(sk: [String: Bool]) {
        acrobatics = sk["acrobatics"]!
        animalHandling = sk["animal_handling"]!
        arcana = sk["arcana"]!
        athletics = sk["athletics"]!
        deception = sk["deception"]!
        history = sk["history"]!
        insight = sk["insight"]!
        intimidation = sk["intimidation"]!
        investigation = sk["investigation"]!
        medicine = sk["medicine"]!
        nature = sk["nature"]!
        perception = sk["perception"]!
        performance = sk["performance"]!
        persuasion = sk["persuasion"]!
        religion = sk["religion"]!
        sleightOfHand = sk["sleight_of_hand"]!
        stealth = sk["stealth"]!
        survival = sk["survival"]!
    }
}
