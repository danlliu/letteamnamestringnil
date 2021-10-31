//
//  GenerateCharacter.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/31/21.
//

import SwiftUI

struct GenerateCharacter: View {
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
            
            NavigationLink(destination: GamesView()) {
                Text("Generate Random Character")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .simultaneousGesture(TapGesture().onEnded(generateRandom))
            .background(Color.blue)
            .cornerRadius(10)
            
            Text("or")
            HStack {
                Text("Enter all input manually")
                Spacer()
                Button(action: {
                    manualInput.toggle()
                }) {
                    if manualInput {
                        Image(systemName: "minus.circle")
                    }
                    else {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .padding()
            if(manualInput) {
                ManualEntryView()
            }

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
    
    func generateRandom() {
        //TODO: need database and ML
        print("generating random character sheet...")
    }
}

struct ManualEntryView: View {
    //TODO: validate string to int conversions -> make number only keyboard
    //basic stats
    @State private var xp: String = ""
    @State private var hp: String = ""
    @State private var perception: String = ""
    @State private var ac: String = ""
    @State private var initiative: String = ""
    @State private var speed: String = ""
    
    //ability modifiers
    @State private var strength: String = ""
    @State private var dexterity: String = ""
    @State private var constitution: String = ""
    @State private var intelligence: String = ""
    @State private var wisdom: String = ""
    @State private var character: String = ""
    
    //spells
    @State private var spells: [String] = []
    @State private var spelltext: String = ""
    @State private var editSpell: Bool = false
    
    //skills
    @State private var skills: [String] = []
    @State private var skilltext: String = ""
    @State private var editSkill: Bool = false
    
    var body: some View {
        List {
            Section(header: Text("Basic info")) {
                HStack {
                    Text("XP:")
                    TextField("XP", text: $xp)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("HP:")
                    TextField("HP", text: $hp)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("Perception:")
                    TextField("Perception", text: $perception)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("Initiative:")
                    TextField("Initiative", text: $initiative)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("AC:")
                    TextField("AC", text: $ac)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("Speed:")
                    TextField("Speed", text: $speed)
                        .keyboardType(.numberPad)
                }
            }
            Section(header: Text("Ability modifiers")) {
                HStack {
                    Text("Strength:")
                    TextField("Strength", text: $strength)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("Dexterity:")
                    TextField("Dexterity", text: $dexterity)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("Constitution:")
                    TextField("Constitution", text: $constitution)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("Intelligence:")
                    TextField("Intelligence", text: $intelligence)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("Wisdom:")
                    TextField("Wisdom", text: $wisdom)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("Character:")
                    TextField("Character", text: $character)
                        .keyboardType(.numberPad)
                }
            }
            Section(header: Text("Skills")) {
                ForEach(skills, id: \.self) { skill in
                    Text(skill)
                }
                if editSkill {
                    HStack {
                        TextField("New skill", text: $skilltext)
                        Button("Add", action: {
                            editSkill = false
                            skills.append(skilltext)
                            skilltext = ""
                        })
                            .disabled(skilltext == "")
                    }
                }
                Button(action: {
                    editSkill = true
                }) {
                    HStack {
                        Text("Add skill")
                        Image(systemName: "plus.circle")
                    }
                }
            }
            Section(header: Text("Spells")) {
                ForEach(spells, id: \.self) { spell in
                    Text(spell)
                }
                if editSpell {
                    HStack {
                        TextField("New spell", text: $spelltext)
                        Button("Add", action: {
                            editSpell = false
                            spells.append(spelltext)
                            spelltext = ""
                        })
                            .disabled(spelltext == "")
                    }
                }
                Button(action: {
                    editSpell = true
                }) {
                    VStack {
                        HStack {
                            Text("Add spell")
                            Image(systemName: "plus.circle")
                        }
                    }
                }
            }
        }
        .listStyle(.grouped)
    }
}

struct GenerateCharacter_Previews: PreviewProvider {
    static var previews: some View {
        GenerateCharacter()
    }
}
