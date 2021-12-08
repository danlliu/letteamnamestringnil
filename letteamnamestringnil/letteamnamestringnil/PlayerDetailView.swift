import SwiftUI

struct PlayerDetailView: View {
    
    var partyCode: String
    var username: String

    init(partyCode: String, username: String) {
        self.partyCode = partyCode
        self.username = username
    }


    // TODO: get UI
    @State private var names = [
        "character": "Eaydan Falconmoon",
        "class": "Fighter"
    ]
    @State private var race = "Human"
    @State private var level = 4
    @State private var xp = 0
    @State private var maxHP = 28
    @State private var curHP = 28
    @State private var prof = "+4"
    @State private var speed = "30"
    @State private var initiative = "+5"
    @State private var ac = "12"
    @State private var alignment = 2
    
    // This should be @State or similar, but I think there's a bug in the Swift
    //  runtime that causes a crash if we do that
    @State private var scores = [
        "strength": 10,
        "dexterity": 8,
        "constitution": 6,
        "intelligence": 8,
        "wisdom": 7,
        "charisma": -5
    ]
    
    var body: some View {
        if #available(iOS 15.0, *) {
            VStack {
                Group {
                    Text("Party Code".uppercased())
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top)
                    Text(partyCode)
                        .padding(.bottom)
                }
                //            Spacer()
                Group {
                    Text(names["character"]!)
                    Text("\(names["class"]!), \(race)")
                }
                Text("HP \(curHP)/\(maxHP)")
                Spacer()
                Group {
                    VStack {
                        HStack {
                            Text("Level \(level) (\(xp) XP)")
                        }
                        .padding()
                        HStack {
                            
                            VStack {
                                Text("Proficiency")
                                    .font(.caption)
                                Text(prof)
                            }
                            VStack {
                                Text("Speed")
                                    .font(.caption)
                                Text(speed)
                            }
                            VStack {
                                Text("Initiative")
                                    .font(.caption)
                                Text(initiative)
                            }
                            VStack {
                                Text("Armor Class")
                                    .font(.caption)
                                Text(ac)
                            }
                        }
                    }
                    List {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("STR\t\(scores["strength"]!)")
                                Text("DEX\t\(scores["dexterity"]!)")
                                Text("CON\t\(scores["constitution"]!)")
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("INT \t\(scores["intelligence"]!)")
                                Text("WIS\t\(scores["wisdom"]!)")
                                Text("CHR\t\(scores["charisma"]!)")
                            }
                        }
                        //TODO: what even is this
                        //NavigationLink(destination: )
                    }
                }
            }
            .task {
                guard let id = await Store.shared.getID() else {
                    return
                }
                let response = await Store.shared.getPlayerData(code: partyCode, playerId: id)
                if let sheet = response?.csheet {
                    names["character"] = sheet.basicInfo.name
                    names["class"] = sheet.basicInfo.className
                    race = sheet.basicInfo.race
                    level = sheet.stats.level
                    xp = sheet.stats.xp
                    maxHP = sheet.stats.maxHP
                    curHP = sheet.stats.curHP
                    prof = "\(sheet.stats.profBonus)"
                    speed = "\(sheet.stats.speed)"
                    initiative = "\(sheet.stats.initiative)"
                    ac = "\(sheet.stats.ac)"
                    alignment = sheet.basicInfo.alignment
                    scores = sheet.stats.abilityScores
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct PlayerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerDetailView(partyCode: "E44W", username: "tuna_player_485")
    }
}
