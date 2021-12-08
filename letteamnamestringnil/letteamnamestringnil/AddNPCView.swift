//
//  AddNPCView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

struct AddNPCView: View {

    var partyCode: String
    var username: String

    init(partyCode: String, username: String) {
        self.partyCode = partyCode
        self.username = username
    }

    @State private var type: String = ""
    @State private var name: String = ""
    @State private var playerClass: String = "Select a class"
    @State private var playerAlignment: String = "Select an alignment"
    @State private var level: Int = 0
    
    @State private var goCSV = false
    @State private var newid = 0
    
    private var classes = ["Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Warlock", "Wizard"]
    private var alignments = ["Lawful good", "Neutral good", "Chaotic good", "Lawful neutral", "True neutral", "Chaotic neutral", "Lawful evil",
                                "Neutral evil", "Chaotic evil"]
    
    private var buttonPadding: CGFloat = 10
    
    var body: some View {
        VStack {
            List {
                HStack {
                    Text("Name")
                    TextField("Enter name here", text: $name)
                }
                HStack {
                    Text("Class")
                    VStack {
                        Menu(playerClass) {
                            ForEach(classes, id: \.self) { classOption in
                                Button(classOption, action: {playerClass = classOption})
                            }
                        }
                    }
                }
                HStack {
                    Text("Alignment")
                    VStack {
                        Menu(playerAlignment) {
                            ForEach(alignments, id: \.self) { alignmentOption in
                                Button(alignmentOption, action: {playerAlignment = alignmentOption})
                            }
                        }
                    }
                }
                Stepper("Level: \(level)", value: $level)
            }
            .listStyle(.plain)
            HStack {
                Button(action: {
                    type = "friendly"
                }) {
                    Text("Friendly NPC")
                        .foregroundColor((type == "friendly") ? Color.white : Color.blue)
                        .padding(buttonPadding)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 3)
                )
                .background((type == "friendly") ? Color.blue : Color.white)
                .cornerRadius(10)
                .padding()
                
                Button(action: {
                    type = "monster"
                }){
                    Text("Monster")
                        .foregroundColor((type == "monster") ? Color.white : Color.blue)
                        .padding(buttonPadding)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 3)
                )
                .background((type == "monster") ? Color.blue : Color.white)
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
            }
            
            Spacer()
            
            NavigationLink(destination: DMView(partyCode: partyCode, username: username)) {
                Text("Generate Random Character")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .disabled(blankEntry())
            .simultaneousGesture(TapGesture().onEnded{ if #available(iOS 15.0, *) {
                Task { await generateRandomNPC() }
            } else {
                // Fallback on earlier versions
            } })
            .background(blankEntry() ? Color.gray : Color.blue)
            .cornerRadius(10)
            
            Text("or")
                .padding()
            
            Button(action: { if #available(iOS 15.0, *) {
                Task {
                    let ncs = CharacterSheet(isNPC: true)
                    ncs.basicInfo.name = name
                    ncs.basicInfo.className = playerClass
                    ncs.basicInfo.alignment = alignments.firstIndex(of: playerAlignment)!
                    ncs.basicInfo.isFriendly = type == "friendly"
                    guard let newID = await Store.shared.makeNPC(code: partyCode, sheet: ncs) else {
                        return
                    }
                    self.newid = newID
                    goCSV = true
                }
            } else {
                // Fallback on earlier versions
            } }) {
                Text("Enter all information manually")
            }
            .disabled(blankEntry())
            .foregroundColor(blankEntry() ? Color.gray : Color.blue)

            NavigationLink(destination: CharacterSheetView(partyCode: partyCode, npcid: newid), isActive: $goCSV) {
                EmptyView()
            }.hidden()
            
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("New character")
            }
            ToolbarItem {
                NavigationLink(destination: DMView(partyCode: partyCode, username: username)) {
                    Text("Create")
                }
                .simultaneousGesture(TapGesture().onEnded( {
                    if #available(iOS 15.0.0, *) {
                        Task{ await Store.shared.makeNPC(code: partyCode, sheet: nil) }
                    } else {
                        // Fallback on earlier versions
                    } //TODO: check nil is handled ok elsewhere
                }))
            }
        }
    }
    
    func blankEntry() -> Bool {
        if(name == "" || playerClass == "Select a class" || playerAlignment == "Select an alignment" || type == "") {
            return true
        }
        return false
    }
    
    @available(iOS 15.0.0, *)
    func generateRandomNPC() async {
        //TODO: need database and ML
        guard let newID = await Store.shared.makeNPC(code: partyCode, sheet: nil) else {
            return
        }
        self.newid = newID
        await Store.shared.generateNPCML(code: partyCode, npcid: newid, className: playerClass.lowercased(), alignment: alignments.firstIndex(of: playerAlignment), race: nil, level: level, name: name, friendly: type == "friendly")
        print("generating random character sheet...")
    }
}
