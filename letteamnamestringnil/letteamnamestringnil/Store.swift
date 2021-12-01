//
//  Model.swift
//  letteamnamestringnil
//
//  Created by Alexis Covacha on 10/31/21.
//

import Foundation

// concurrency only available in 15.0 or newer
@available(iOS 15.0.0, *)

final class Store: ObservableObject {
    static let shared = Store()
    private init() {}
    
//    @Published private(set) var chatts = [Chatt]()
//    @Published private var user = Player()
//    private let nFields = Mirror(reflecting: Chatt()).children.count
    
    private let serverUrl = "https://3.139.99.112/"

    @MainActor
    func login(username: String, password: String) async {
        _ = await apiRequest(path: "users/", method: "POST", body: ["username": username, "password": password])
    }

    @MainActor
    func createAccount(username: String, password: String) async {
        _ = await apiRequest(path: "users/", method: "PUT", body: ["username": username, "password": password])
    }

    @MainActor
    func getUser() async -> PlayerAccountInfo {
        let response = await apiRequest(path: "users/", method: "GET", body: nil)
        switch (response) {
        case .object (let obj):
            return PlayerAccountInfo(id: obj["id"] as! Int, username: obj["username"] as! String)
        default:
            exit(1) // shouldn't get here
        }
    }

    @MainActor
    func getParties() async -> [String] {
        let response = await apiRequest(path: "parties/", method: "GET", body: nil)
        switch (response) {
        case .array (let arr):
            return arr;
        default:
            exit(1)
        }
    }

    @MainActor
    func createParty() async {
        _ = await apiRequest(path: "parties/", method: "POST", body: nil)
    }

    @MainActor
    func joinParty(code: String) async {
        _ = await apiRequest(path: "parties/join/", method: "POST", body: ["code": code])
    }

    @MainActor
    func getPartyInfo(code: String) async -> Party {
        let response = await apiRequest(path: "parties/\(code)/", method: "GET", body: nil)
        switch (response) {
        case .object (let obj):
            let code = obj["code"] as! String
            let playersObj = obj["players"] as! [[String:Any]]
            let players = playersObj.map { PlayerAccountInfo(id: $0["id"] as! Int, username: $0["username"] as! String) }
            return Party(code: code, players: players)
        default:
            exit(1)
        }
    }

    @MainActor
    func getNPCs(code: String) async -> [String] {
        let response = await apiRequest(path: "parties/\(code)/npcs/", method: "GET", body: nil)
        switch (response) {
        case .array (let arr):
            return arr
        default:
            exit(1)
        }
    }

    @MainActor
    func makeNPC(code: String, sheet: CharacterSheet?) async {
        let response = await apiRequest(path: "parties/\(code)/npcs/", method: "POST", body: nil)
        switch (response) {
        case .object (let obj):
            let id = obj["id"] as! String
            await postNPCData(code: code, npcid: id, csheet: sheet)
        default:
            exit(1)
        }
    }

    @MainActor
    func getPlayerData(code: String, player: String) async -> Player {
        let response = await apiRequest(path: "parties/\(code)/members/\(player)/", method: "GET", body: nil)
        switch (response) {
        case .object (let obj):
            let isDM = obj["isDM"] as! Bool
            if obj["sheet"] == nil {
                return Player(username: player, isDM: isDM, csheet: nil)
            }
            let csheet = obj["sheet"] as! [String:Any]

            return Player(username: player, isDM: isDM, csheet: CharacterSheet(json: csheet))
        default:
            exit(1)
        }
    }

    @MainActor
    func getNPCData(code: String, npcid: String) async -> NPC {
        let response = await apiRequest(path: "parties/\(code)/members/\(npcid)/", method: "GET", body: nil)
        switch (response) {
        case .object (let obj):
            let isDM = false
            if obj["sheet"] == nil {
                return NPC(npcid: npcid, csheet: nil)
            }
            let csheet = obj["sheet"] as! [String:Any]

            return NPC(npcid: npcid, csheet: CharacterSheet(json: csheet))
        default:
            exit(1)
        }
    }

    @MainActor
    func postPlayerData(code: String, player: String, isDM: Bool, csheet: CharacterSheet?) async {
        _ = await apiRequest(path: "parties/\(code)/members/\(player)/", method: "POST", body: [
            "isDM": isDM,
            "sheet": csheet!.toDictionary()
        ])
    }

    @MainActor
    func postNPCData(code: String, npcid: String, csheet: CharacterSheet?) async {
        _ = await apiRequest(path: "parties/\(code)/npcs/\(npcid)", method: "POST", body: [
            "sheet": csheet!.toDictionary()
        ])
    }

    // inspired by https://stackoverflow.com/questions/40034034/swift-function-returning-two-different-types/40034233
    enum ApiResult {
        case object([String:Any])
        case array([String])
    }
    
    @MainActor
    func apiRequest(path: String, method: String, body: [String:Any]?) async -> ApiResult {

        guard let apiUrl = URL(string: serverUrl+path) else {
            print("getData: Bad URL")
            return ApiResult.array([])
        }

        var request = URLRequest(url: apiUrl)
        request.httpMethod = method
        if let b = body {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: b) else {
                print("Couldn't serialize object")
                return ApiResult.array([])
            }
            request.httpBody = jsonData
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getData: HTTP STATUS: \(httpStatus.statusCode)")
                return ApiResult.array([])
            }

            if let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] {
                return ApiResult.object(jsonObj)
            } else if let jsonArr = try? JSONSerialization.jsonObject(with: data) as? [String] {
                return ApiResult.array(jsonArr)
            } else {
                print("getData: failed JSON deserialization")
                return ApiResult.array([])
            }
        } catch {
            print("getUser: NETWORKING ERROR")
            return ApiResult.array([])
        }
    }
    
}

struct PlayerAccountInfo: Hashable {
    var id: Int
    var username: String
//    var email:
    
    init(id: Int = -1, username: String = "") {
        self.id = id
        self.username = username
    }
    
}

struct Party: Hashable {
    var code: String
    var players: [PlayerAccountInfo]
}

struct Player {

    var username: String
    var isDM: Bool
    var csheet: CharacterSheet?
    //can add more as desired
    
    init(username: String, isDM: Bool,
         csheet: CharacterSheet?) {
        self.username = username
        self.isDM = isDM
        self.csheet = csheet
    }
    
}

struct NPC {
    
    var npcid: String
    var csheet: CharacterSheet?

}

/*
 
 {
         "isDM": False,
         "sheet": {
             "name": "exampleName",
             "class": "artificer",
             "level": 3,
             "race": "Aasimar",
             "background": "Sage",
             "alignment": 2,
             "experiencePoints": 8,
             "abilityScores": {
                 "strength": -1,
                 "dexterity": 2,
                 "constitution": 1,
                 "intelligence": 4,
                 "wisdom": 1,
                 "charisma": 1,
             },
             "inspiration": 0,
             "proficiencyBonus": 2,
             "savingThrows": {
                 "strength": False,
                 "dexterity": False,
                 "constitution": True,
                 "intelligence": True,
                 "wisdom": False,
                 "charisma": False,
             },
             "skills": {
                 "acrobatics": False,
                 "animalHandling": False,
                 "arcana": True,
                 "athletics": False,
                 "deception": False,
                 "history": True,
                 "insight": False,
                 "intimidation": False,
                 "investigation": False,
                 "medicine": False,
                 "nature": False,
                 "perception": True,
                 "performance": False,
                 "persuasion": False,
                 "religion": False,
                 "sleightOfHand": True,
                 "stealth": False,
                 "survival": False,
             },
             "passiveWisdom": 13,
             "otherProficienciesAndSkills": "Common\nCelestial",
             "stats": {
                 "armorClass": 14,
                 "initiative": 2,
                 "speed": 30,
                 "maxHP": 18,
                 "curHP": 18,
                 "tempHP": 0,
                 "hitDice": "3d8",
                 "deathSaveSuccess": 0,
                 "deathSaveFailure": 0
             },
             "attacks": "Example attacks here",
             "equipment": """Hand-axe (1d6 slashing)
                Spear (1d6 piercing)
                Light crossbow (1d8 piercing, 20 ammo)
                Scale mail (AC 14, stealth disadv)
                Thieves' tools
                Backpack
                Crowbar
                Hammer
                10 pitons
                10 torches
                Tinderbox
                10 days of rations
                Waterskin
                Soft of hempen rope""",
             "personality": {
                 "traits": "Example traits here",
                 "ideals": "Example ideals here",
                 "bonds": "Example bonds here",
                 "flaws": "Example flaws here",
             },
             "featuresAndTraits": """Darkvision
                Celestial resistance
                Healing hands
                 touch, +HP = level, 1/LR
                Radiant consumption
                 light 10ft, dim light 20ft
                 ceil(level/2) radiant dmg in 10ft (incl. self)
                 extra radiant dmg/attack: +level, 1/turn""",
             "appearance": {
                 "age": 28,
                 "eyes": "blue",
                 "height": "5ft 11in",
                 "weight": "160lbs",
             },
             "backstory": "Example backstory here",
             "darkGifts": "Example darkgifts here",
             "features": "Example features here",
             "allies": "Example allies here",
             "treasure": "Example treasure here",
             "spellcasting": {
                 "ability": 18,
                 "dc": 14,
                 "attackBonus": 6,
                 "level1Slots": 3,
                 "level2Slots": 0,
                 "level3Slots": 0,
                 "level4Slots": 0,
                 "level5Slots": 0,
                 "level6Slots": 0,
                 "level7Slots": 0,
                 "level8Slots": 0,
                 "level9Slots": 0,
             },
             "spells": [
                 {
                     "name": "Light",
                     "components": ['V', 'M'],
                     "level": 0,
                     "description": "",
                     "prepared": None,
                 },
                 {
                     "name": "Fire Bolt",
                     "components": ['V', 'S'],
                     "level": 0,
                     "description": "ranged spell 1d10, inst., 120ft",
                     "prepared": None,
                 },
                 {
                     "name": "Magic Stone",
                     "components": ['V', 'S'],
                     "level": 0,
                     "description": "1-3 pebbles, blud 1d6 + spell mod, 60ft, BA",
                     "prepared": None,
                 },
                 {
                     "name": "Faerie Fire",
                     "components": ['V'],
                     "level": 1,
                     "description": "20ft cube B1/Gr/Vi 10ft light, 60ft",
                     "prepared": False,
                 },
                 {
                     "name": "Purify Food and Drink",
                     "components": ['V', 'S'],
                     "level": 1,
                     "description": "5ft sphere, 10ft",
                     "prepared": False,
                 },
                 {
                     "name": "Tasha' Caustic Brew",
                     "components": ['V', 'S', 'M'],
                     "level": 1,
                     "description": "30ft x 5ft, 2d4 acid",
                     "prepared": False,
                 },
                 {
                     "name": "Healing Word",
                     "components": ['V'],
                     "level": 1,
                     "description": "+HP = 1d4 + spell, 60ft, BA",
                     "prepared": True,
                 },
                 {
                     "name": "Ray of Sickness",
                     "components": ['V', 'S'],
                     "level": 1,
                     "description": "ranged spell, 2d8 poison, 60ft",
                     "prepared": True,
                 },
             ]
         }
     }
 
 */
