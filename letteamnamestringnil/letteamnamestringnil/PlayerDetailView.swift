//
//  PlayerDetailView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/31/21.
//

import SwiftUI

struct PlayerDetailView: View {
    
    var partyCode = "E44W"
    var username = "tuna_player_485"

    init(partyCode: String, username: String) {
        self.partyCode = partyCode
        self.username = username

        // TODO: fetch
    }
    
    @State private var characterName = "Eaydan Falconmoon"
    @State private var className = "Fighter"
    @State private var race = "Human"
    @State private var level = 4
    @State private var maxHP = 28
    @State private var tempHP = 28
    @State private var prof = "+4"
    @State private var speed = "30"
    @State private var initiative = "+5"
    @State private var ac = "12"
    @State private var alignment = 2
    
    var body: some View {
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
                Text(characterName)
                Text("\(className), \(race)")
            }
            Text("HP \(tempHP)/\(maxHP)")
            Spacer()
            Group {
                VStack {
                    HStack {
                        Text("Level 10 (1416 XP)")
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
                            Text("STR\t10")
                            Text("DEX\t8")
                            Text("CON\t6")
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("INT \t8")
                            Text("WIS\t7")
                            Text("CHR\t-5")
                        }
                    }
                    HStack {
                        Text("Add Skill")
                        Spacer()
                        Button(action: addSkill) {
                            Image(systemName: "pencil")
                                .foregroundColor(Color.red)
                        }
                    }
                    HStack {
                        Text("Add attack/spell")
                        Spacer()
                        Button(action: addSkill) {
                            Image(systemName: "pencil")
                                .foregroundColor(Color.red)
                        }
                    }
                }
            }
        }
    }
    
    func addSkill() {
        // TODO: implement
    }
}

struct PlayerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerDetailView(partyCode: "E44W", username: "tuna_player_485")
    }
}
