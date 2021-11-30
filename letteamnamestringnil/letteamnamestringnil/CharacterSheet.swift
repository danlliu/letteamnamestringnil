//
//  Player.swift
//  letteamnamestringnil
//
//  Created by Alexis Covacha on 10/31/21.
//

import Foundation
import SwiftUI

//class CharacterSheet: ObservableObject {
//    
//    @Published var id: String
//    @Published var basicInfo: PlayerBasicInfo
//    @Published var stats: PlayerStats
//    @Published var skills: [String: Bool]
//    @Published var attacks: String
//    @Published var spellcasting: [String: Any]
//    @Published var spells: [Spells]
//    @Published var inventory: PlayerInventory
//    @Published var background: PlayerBackgroundInfo
//    
////    @Published var hitDice: [Int: Int]
//    
//    init(json: [String: Any]) {
//
//        var character: [String: Any] = [:]
//        character["name"]      = json["name"]
//        character["class"]     = json["class"]
//        character["race"]      = json["race"]
//        character["alignment"] = json["alignment"]
//        
//        var stats: [String: Any] = json["stats"] as! [String: Any]
//        stats["level"]         = json["level"]
//        stats["xp"]            = json["experiencePoints"]
//        stats["abilityScores"] = json["abilityScores"]
//        stats["perception"]    = json["passiveWisdom"]
//        stats["inspiration"]   = json["inspiration"]
//        stats["profBonus"]     = json["proficiencyBonus"]
//        stats["savingThrows"]  = json["savingThrows"]
//        
//        let personality = Personality(json: json["personality"] as! [String: String])
//        let spellsData = json["spells"] as! [[String: Any]]
//        
//        self.id = json["id"] as! String
//        self.basicInfo = PlayerBasicInfo(characterInfo: character)
//        self.stats = PlayerStats(stats: stats)
//        self.skills = json["skills"] as! [String: Bool]
//        self.attacks = json["attacks"] as! String
//        self.inventory = PlayerInventory(equipment: json["equipment"] as! String,
//                                         darkGifts: json["darkGifts"] as! String,
//                                         treasure: json["trearuse"] as! String)
//        self.background = PlayerBackgroundInfo(
//            background: json["background"] as! String,
//            backstory: json["backstory"] as! String,
//            proficiencies: json["otherProficienciesAndSkills"] as! String,
//            features: json["featuresAndTraits"] as! String,
//            personality: personality,
//            appearance: json["appearance"] as! [String: Any]
//        )
//        self.spellcasting = json["spellcasting"] as! [String: Any]
//        self.spells = []
//        
//        for (spell) in spellsData {
//            self.spells.append(Spells(name: spell["name"] as! String,
//                   components: spell["components"] as! String,
//                   level: spell["level"] as! Int,
//                   description: spell["description"] as! String))
//        }
//        
//        
//        
//        
//    }
//    
//}
//
//struct PlayerBasicInfo: Hashable {
//    var name: String
//    var className: String
//    var race: String
//    var alignment: Int
//    
//    init(characterInfo: [String: Any]) {
//        self.name      = characterInfo["name"] as! String
//        self.className = characterInfo["class"] as! String
//        self.race      = characterInfo["race"] as! String
//        self.alignment = characterInfo["alignemnt"] as! Int
//    }
//}
//
//struct PlayerStats: Hashable {
//    var level: Int
//    var xp: Int
//    var maxHp: Int
//    var curHp: Int
//    var abilityScores: [String: Int]
//    var perception: Int
//    var inspiration: Int
//    var proficiencyBonus: Int
//    var savingThrows: [String: Bool]
//    
//    init(stats: [String: Any]) {
//        self.level = stats["level"] as! Int
//        self.xp = stats["xp"] as! Int
//        self.maxHp = stats["maxHP"] as! Int
//        self.curHp = stats["curHP"] as! Int
//        self.abilityScores = stats["abilityScores"] as! [String: Int]
//        self.perception = stats["perception"] as! Int
//        self.inspiration = stats["inspiration"] as! Int
//        self.proficiencyBonus = stats["profBonus"] as! Int
//        self.savingThrows = stats["savingThrows"] as! [String: Bool]
//    }
//    
//}
//
//struct Spells: Hashable {
//    var name: String
//    var components: String
//    var level: Int
//    var description: String
//    
//    static func == (lhs: Spells, rhs: Spells) -> Bool {
//        return (lhs.name == rhs.name &&
//                lhs.components == rhs.components &&
//                lhs.level == rhs.level &&
//                lhs.description == rhs.description)
//    }
//}
//
//
//struct PlayerBackgroundInfo {
//    var background: String
//    var backstory: String
//    var proficiencies: String
//    var features: String
//    var personality: Personality
//    var appearance: [String: Any]
//}
//
//struct Personality: Hashable {
//    var traits: String?
//    var ideals: String?
//    var bonds: String?
//    var flaws: String?
//    
//    init(json: [String: String]) {
//        traits = json["traits"]
//        ideals = json["ideals"]
//        bonds  = json["bonds"]
//        flaws  = json["flaws"]
//    }
//}
//
//struct PlayerInventory: Hashable {
//    var equipment: String
//    var darkGifts: String
//    var treasure: String
//}


