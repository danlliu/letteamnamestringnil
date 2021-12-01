//
//  AddNPCView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

struct AddNPCView: View {

    var partyCode: String

    init(partyCode: String) {
        self.partyCode = partyCode
    }

    @State private var type: String = ""
    @State private var name: String = ""
    @State private var playerClass: String = "Select a class"
    @State private var playerAlignment: String = "Select an alignment"
    @State private var level: Int = 0
    
    private var classes = ["Aarakocra", "Bugbear", "Centaur", "Dragonborn", "Dwarf", "Elf", "Gensai", "Goblin", "Human", "Minotaur", "Orc", "Tortle",
                            "Vedalken", "Warforged"]
    private var alignments = ["Chaotic good", "Neutral good", "Lawful good", "Chaotic neutral", "Neutral neutral", "Lawful neutral", "Chaotic evil",
                                "Neutral evil", "Lawful evil"]
    
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
            
            NavigationLink(destination: PlayerView()) {
                Text("Generate Random Character")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .disabled(blankEntry())
            .simultaneousGesture(TapGesture().onEnded(generateRandomNPC))
            .background(blankEntry() ? Color.gray : Color.blue)
            .cornerRadius(10)
            
            Text("or")
                .padding()
            
            NavigationLink(destination: CharacterSheetView(partyCode: partyCode, username: name)) {
                Text("Enter all information manually")
            }
            .disabled(blankEntry())
            .foregroundColor(blankEntry() ? Color.gray : Color.blue)

        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("New character")
            }
            ToolbarItem {
                NavigationLink(destination: PlayerView()) {
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
    
    func generateRandomNPC() {
        //TODO: need database and ML
        print("generating random character sheet...")
    }
}
