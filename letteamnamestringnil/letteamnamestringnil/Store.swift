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
    
    private let serverUrl = "https://ec2-3-139-99-112.us-east-2.compute.amazonaws.com/"

    @MainActor
    func getID() async -> Int? {
        guard let response = await apiRequest(path: "user/", method: "GET", body: nil) else {
            return nil
        }
        switch (response) {
        case .object (let obj):
            print(obj)
            return obj["id"] as? Int
        default:
            return nil
        }
    }
    
    @MainActor
    func login(username: String, password: String) async -> Int {
        print("login: \(username) / \(password)")
        guard let response = await apiRequest(path: "user/", method: "POST", body: ["username": username, "password": password]) else {
            return -1
        }
        switch (response) {
        case .object (let obj):
            return obj["id"] as! Int
        default:
            return -1
        }
    }
    
    @MainActor
    func logout() async {
        let _ = await apiRequest(path: "logout/", method: "POST", body: nil)
    }

    @MainActor
    func createAccount(username: String, password: String) async -> Int {
        print("create: \(username) / \(password)")
        guard let response = await apiRequest(path: "user/", method: "PUT", body: ["username": username, "password": password]) else {
            return -1
        }
        switch (response) {
        case .object (let obj):
            return obj["id"] as! Int
        default:
            return -1
        }
    }

    @MainActor
    func getUser() async -> PlayerAccountInfo {
        guard let response = await apiRequest(path: "user/", method: "GET", body: nil) else {
            return PlayerAccountInfo(id: -1, username: "")
        }
        switch (response) {
        case .object (let obj):
            return PlayerAccountInfo(id: obj["id"] as! Int, username: obj["username"] as! String)
        default:
            return PlayerAccountInfo(id: -1, username: "")
        }
    }

    @MainActor
    func getParties() async -> [String] {
        guard let response = await apiRequest(path: "parties/", method: "GET", body: nil) else {
            return []
        }
        switch (response) {
        case .arrayStr (let arr):
            return arr;
        default:
            return []
        }
    }

    @MainActor
    func createParty() async -> String? {
        guard case let .object(obj) = await apiRequest(path: "parties/", method: "POST", body: nil) else {
            return nil
        }
        return obj["code"] as? String
    }

    @MainActor
    func joinParty(code: String) async -> ()? {
        guard await apiRequest(path: "parties/join/", method: "POST", body: ["code": code, "is_dm": false]) != nil else {
            return nil
        }
        return ()
    }

    @MainActor
    func getPartyInfo(code: String) async -> Party {
        guard let response = await apiRequest(path: "parties/\(code)/", method: "GET", body: nil) else {
            return Party(code: "Could not find party", players: [])
        }
        switch (response) {
        case .object (let obj):
            let code = obj["code"] as! String
            let playersObj = obj["members"] as! [[String:Any]]
            let players = playersObj.map { PlayerAccountInfo(id: $0["id"] as! Int, username: $0["username"] as! String) }
            return Party(code: code, players: players)
        default:
            return Party(code: "Could not find party", players: [])
        }
    }

    @MainActor
    func getNPCs(code: String) async -> [Int] {
        guard let response = await apiRequest(path: "parties/\(code)/npcs/", method: "GET", body: nil) else {
            return []
        }
        switch (response) {
        case .array (let arr):
            return arr
        default:
            return []
        }
    }

    @MainActor
    func makeNPC(code: String, sheet: CharacterSheet?) async -> Int? {
        guard let response = await apiRequest(path: "parties/\(code)/npcs/", method: "POST", body: nil) else {
            return nil
        }
        switch (response) {
        case .object (let obj):
            let id = obj["id"] as! Int
            await postNPCData(code: code, npcid: id, csheet: sheet)
            return id
        default:
            return nil
        }
    }

    @MainActor
    func getPlayerData(code: String, playerId: Int) async -> Player? {
        let response = await apiRequest(path: "parties/\(code)/members/\(playerId)/", method: "GET", body: nil)
        switch (response) {
        case .object (let obj):
            let isDM = obj["isDM"] as! Bool
            if obj["sheet"] == nil {
                return Player(id: playerId, isDM: isDM, csheet: nil)
            }
            let csheet = obj["sheet"] as? [String:Any] ?? nil

            if csheet == nil {
                return Player(id: playerId, isDM: isDM, csheet: nil)
            }
            return Player(id: playerId, isDM: isDM, csheet: CharacterSheet(json: csheet!))
        default:
            return nil
        }
    }

    @MainActor
    func getNPCData(code: String, npcid: Int) async -> NPC? {
        let response = await apiRequest(path: "parties/\(code)/npcs/\(npcid)/", method: "GET", body: nil)
        switch (response) {
        case .object (let obj):
            let csheet = obj["sheet"] as? [String:Any] ?? nil
            if csheet == nil {
                return NPC(npcid: npcid, csheet: nil)
            }
            return NPC(npcid: npcid, csheet: CharacterSheet(json: csheet!))
        default:
            return nil
        }
    }
    
    @MainActor
    func generatePlayerML(code: String, playerId: Int, className: String, alignment: Int?, race: String?, level: Int?, name: String?) async {
        let response = await apiRequest(path: "generate/", method: "POST", body: [
            "clss": className,
            "alignment": alignment ?? NSNull(),
            "race": race ?? NSNull(),
            "level": level ?? NSNull(),
            "name": name ?? NSNull(),
        ])
        switch (response) {
        case .object (var sheet):
            sheet["is_npc"] = false
            sheet["is_friendly"] = true
            _ = await apiRequest(path: "parties/\(code)/members/\(playerId)/", method: "POST", body: [
                "isDM": false,
                "sheet": sheet
            ])
        default:
            return
        }
    }
    
    @MainActor
    func generateNPCML(code: String, npcid: Int, className: String, alignment: Int?, race: String?, level: Int?, name: String?, friendly: Bool) async {
        let response = await apiRequest(path: "generate/", method: "POST", body: [
            "clss": className,
            "alignment": alignment ?? NSNull(),
            "race": race ?? NSNull(),
            "level": level ?? NSNull(),
            "name": name ?? NSNull(),
        ])
        switch (response) {
        case .object (var sheet):
            sheet["is_npc"] = true
            sheet["is_friendly"] = friendly
            _ = await apiRequest(path: "parties/\(code)/npcs/\(npcid)/", method: "POST", body: [
                "sheet": sheet
            ])
        default:
            return
        }
    }

    @MainActor
    func postPlayerData(code: String, playerId: Int, isDM: Bool, csheet: CharacterSheet?) async {
        if csheet == nil { return }
        _ = await apiRequest(path: "parties/\(code)/members/\(playerId)/", method: "POST", body: [
            "isDM": isDM,
            "sheet": csheet!.toDictionary()
        ])
    }

    @MainActor
    func postNPCData(code: String, npcid: Int, csheet: CharacterSheet?) async {
        if csheet == nil {
            return
        }
        _ = await apiRequest(path: "parties/\(code)/npcs/\(npcid)/", method: "POST", body: [
            "sheet": csheet!.toDictionary()
        ])
    }

    @MainActor
    func getSynergy(code: String) async -> [Any]? {
        let response = await apiRequest(path: "parties/\(code)/spells/", method: "GET", body: nil)
        switch (response) {
        case .arrayObj (let arr):
            return arr
        default:
            return nil
        }
    }
    
    // inspired by https://stackoverflow.com/questions/40034034/swift-function-returning-two-different-types/40034233
    enum ApiResult {
        case object([String:Any])
        case array([Int])
        case arrayStr([String])
        case arrayObj([Any])
    }
    
    @MainActor
    func apiRequest(path: String, method: String, body: [String:Any]?) async -> ApiResult? {

        guard let apiUrl = URL(string: serverUrl+path) else {
            print("API request: Bad URL")
            return nil
        }

        var request = URLRequest(url: apiUrl)
        request.httpMethod = method
        if let b = body {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: b) else {
                print("API request: Couldn't serialize object")
                return nil
            }
            request.httpBody = jsonData
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("API request: HTTP STATUS: \(httpStatus.statusCode)")
                print("path = \(path), method = \(method)")
                return nil
            }

            if let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] {
                return ApiResult.object(jsonObj)
            } else if let jsonArr = try? JSONSerialization.jsonObject(with: data) as? [Int] {
                return ApiResult.array(jsonArr)
            } else if let jsonArr = try? JSONSerialization.jsonObject(with: data) as? [String] {
                return ApiResult.arrayStr(jsonArr)
            } else if let jsonArr = try? JSONSerialization.jsonObject(with: data) as? [Any] {
                return ApiResult.arrayObj(jsonArr)
            } else {
                print("API request: failed JSON deserialization")
                return nil
            }
        } catch {
            print("API request: NETWORKING ERROR")
            return nil
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

    var id: Int
    var username: String
    var isDM: Bool
    var csheet: CharacterSheet?
    //can add more as desired
    
    init(id: Int, isDM: Bool,
         csheet: CharacterSheet?) {
        self.id = id
        self.username = csheet?.basicInfo.name ?? ""
        self.isDM = isDM
        self.csheet = csheet
    }
    
}

struct NPC {
    
    var npcid: Int
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
