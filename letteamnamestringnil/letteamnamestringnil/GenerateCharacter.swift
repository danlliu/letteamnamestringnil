//
//  GenerateCharacter.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/31/21.
//

import SwiftUI

struct GenerateCharacter: View {

    var partyCode: String
    var username: String

    init(partyCode: String, username: String) {
        self.partyCode = partyCode
        self.username = username
    }

    @State private var name: String = ""
    @State private var playerClass: String = "Select a class"
    @State private var playerAlignment: String = "Select an alignment"
    @State private var level: Int = 0
    @State private var manualInput: Bool = false
    
    private var classes = ["Aarakocra", "Bugbear", "Centaur", "Dragonborn", "Dwarf", "Elf", "Gensai", "Goblin", "Human", "Minotaur", "Orc", "Tortle",
                            "Vedalken", "Warforged"]
    private var alignments = ["Chaotic good", "Neutral good", "Lawful good", "Chaotic neutral", "Neutral neutral", "Lawful neutral", "Chaotic evil",
                                "Neutral evil", "Lawful evil"]
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
            
            NavigationLink(destination: PlayerView()) {
                Text("Generate Character")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .disabled(blankEntry())
            .simultaneousGesture(TapGesture().onEnded{ if #available(iOS 15.0, *) {
                Task { await generateRandom() }
            } else {
                // Fallback on earlier versions
            } })
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
            }
        }
    }
    
    func blankEntry() -> Bool {
        if(name == "" || playerClass == "Select a class" || playerAlignment == "Select an alignment") {
            return true
        }
        return false
    }
    
    @available(iOS 15.0.0, *)
    func generateRandom() async {
        //TODO: need database and ML
        await Store.shared.generatePlayerML(code: partyCode, playerId: Store.shared.getID(), className: playerClass, alignment: alignments.firstIndex(of: playerAlignment))
        print("generating character sheet...")
    }
}
