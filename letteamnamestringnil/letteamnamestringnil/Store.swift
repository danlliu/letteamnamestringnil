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
            guard let csheet = obj["sheet"] as? [String:Any] else {
                return Player(id: playerId, isDM: isDM, csheet: nil)
            }
            return Player(id: playerId, isDM: isDM, csheet: CharacterSheet(json: csheet))
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
