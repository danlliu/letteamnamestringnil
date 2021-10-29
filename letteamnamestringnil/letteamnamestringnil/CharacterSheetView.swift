//
//  CharacterSheetView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

struct CharacterSheetView: View {
    
    @State var race: String = ""
    
    var body: some View {
        VStack {
            Text("Character Sheet")
                .font(.largeTitle)
            
            Divider()
            Group {
                Text("Character Information")
                    .font(.headline)
                VStack {
                    TextField("Character Race", text: $race)
                        .border(.gray, width: 1)
                }.padding(16)
            }
            Divider()
            Group {
                Text("Ability Scores")
                    .font(.headline)
                VStack {
                    TextField("Character Race", text: $race)
                        .border(.gray, width: 1)
                }.padding(16)
            }
            Divider()
            Group {
                Text("Other Stats")
                    .font(.headline)
                VStack {
                    TextField("Character Race", text: $race)
                        .border(.gray, width: 1)
                }.padding(16)
            }
        }
    }
}

struct CharacterSheetView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterSheetView()
    }
}
