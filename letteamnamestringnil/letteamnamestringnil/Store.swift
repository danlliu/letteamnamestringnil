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
    @Published private var user = Player()
//    private let nFields = Mirror(reflecting: Chatt()).children.count
    
    private let serverUrl = "https://3.139.99.112/"
    
    @MainActor
    func getUser() async {

        guard let apiUrl = URL(string: serverUrl+"user/") else {
            print("getUser: Bad URL")
            return
        }

        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getChatts: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }

            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getUser: failed JSON deserialization")
                return
            }
            
//            let chattsReceived = jsonObj["chatts"] as? [[String?]] ?? []
//
//            self.chatts = [Chatt]()
//            for chattEntry in chattsReceived {
//                if chattEntry.count == self.nFields {
//                    self.chatts.append(Chatt(username: chattEntry[0],
//                                             message: chattEntry[1],
//                                             timestamp: chattEntry[2]))
//                } else {
//                    print("getChatts: Received unexpected number of fields: \(chattEntry.count) instead of \(self.nFields).")
//                }
//            }
        } catch {
            print("getUser: NETWORKING ERROR")
        }
    }
    
    func postChatt(/*_ chatt: Chatt*/) async {
//        let jsonObj = ["chatterID": ChatterID.shared.id,
//                       "message": chatt.message]
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
//            print("postChatt: jsonData serialization error")
//            return
//        }
//
//        guard let apiUrl = URL(string: serverUrl+"postauth/") else {
//            print("postChatt: Bad URL")
//            return
//        }
//
//        var request = URLRequest(url: apiUrl)
//        request.httpMethod = "POST"
//        request.httpBody = jsonData
//
//        do {
//            let (_, response) = try await URLSession.shared.data(for: request)
//
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
//                print("postChatt: HTTP STATUS: \(httpStatus.statusCode)")
//                return
//            }
//        } catch {
//            print("postChatt: NETWORKING ERROR")
//        }
    }
        
        
    
//    // concurrency only available in 15.0 or newer
//    @available(iOS 15.0.0, *)
//    func addUser() async -> Bool {
//        guard let idToken = idToken else {
//            return
//        }
//
//        let jsonObj = ["clientID": "YOUR_APP'S_CLIENT_ID",
//                    "idToken" : idToken]
//
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
//            print("addUser: jsonData serialization error")
//            return
//        }
//
//        guard let apiUrl = URL(string: serverUrl+"adduser/") else {
//            print("addUser: Bad URL")
//            return
//        }
//
//        var request = URLRequest(url: apiUrl)
//        request.httpMethod = "POST"
//        request.httpBody = jsonData
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
//                print("addUser: HTTP STATUS: \(httpStatus.statusCode)")
//                return
//            }
//
//            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
//                print("addUser: failed JSON deserialization")
//                return
//            }
//
//            ChatterID.shared.id = jsonObj["chatterID"] as? String
//            ChatterID.shared.expiration = Date()+(jsonObj["lifetime"] as! TimeInterval)
//
//            guard let _ = ChatterID.shared.id else {
//                return
//            }
//            // will save() chatterID later
//        } catch {
//            print("addUser: NETWORKING ERROR")
//        }
//    }
    
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

struct Player: Hashable {
    var playerInfo: PlayerAccountInfo
    var characterName: String
    var playerClass: String
    var playerAlignment: String
    var level: Int
    //can add more as desired
    
    init(playerInfo: PlayerAccountInfo = PlayerAccountInfo(),
         characterName: String = "", playerClass: String = "",
         playerAlignment: String = "", level: Int = -1) {
        self.playerInfo = playerInfo
        self.characterName = characterName
        self.playerClass = playerClass
        self.playerAlignment = playerAlignment
        self.level = level
    }
    
}

/
 
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
