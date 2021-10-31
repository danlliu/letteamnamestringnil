//
//  GamesView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI
import CoreData

struct GamesView: View {
    @State private var partyCode: String = ""
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("Enter party code or \nchoose existing campaign")
                .multilineTextAlignment(.center)
            
            TextField("Enter party code here...", text: $partyCode)
                .frame(width: UIScreen.main.bounds.size.width * 0.75,
                       height: 20.0)
                .padding()
                .border(Color.gray, width: 1.0)
            
            Spacer()
            
            NavigationLink( destination: Text("You pressed ubtton!"), label: {
                Text("JOIN")
            })
                .buttonStyle(SmallRedButton())
                .padding()
            
            Spacer()
            
            List {
                NavigationLink (
                    destination: Text("You pressed the character button!"),
                    label: {
                        Text("Character 1")
                    }
                )
            }
            .padding(.top, 10.0)
            
        }
    }
}

struct SmallRedButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 8.0)
            .padding()
            .background(Color("redAccent"))
            .foregroundColor(.white)
            .clipShape(Rectangle())
            .cornerRadius(3.0)
            .font(.title2)
    }
}

struct GamesView_Previews: PreviewProvider {
    static var previews: some View {
        GamesView()
    }
}
