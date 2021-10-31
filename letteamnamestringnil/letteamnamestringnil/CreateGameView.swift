//
//  CreateGameView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/31/21.
//

import SwiftUI

struct CreateGameView: View {
    @State private var partyCode: String = ""
    @State private var role: String = "DM"
    
    private var buttonPadding: CGFloat = 8
    
    var body: some View {
        VStack {
            Text("Enter a party code:")
                .font(.title2)
                .padding()
            
            TextField("", text: $partyCode)
                .multilineTextAlignment(.center)
                .frame(width: 120) //TODO: this is hacky
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                )
            HStack {
                Button(action: {
                    role = "DM"
                }) {
                    Text("Join as DM")
                        .foregroundColor(Color.white)
                        .padding(buttonPadding)
                }
                .background((role == "DM") ? Color.blue : Color.gray)
                .cornerRadius(10)
                .padding()
                
                Button(action: {
                    role = "player"
                }){
                    Text("Join as Player")
                        .foregroundColor(Color.white)
                        .padding(buttonPadding)
                }
                .background((role == "player") ? Color.blue : Color.gray)
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
            }
            NavigationLink(destination: PlayerView()) {
                Text("Create Party")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .simultaneousGesture(TapGesture().onEnded(createGame))
            .disabled(partyCode == "")
            .background((partyCode == "") ? Color.gray : Color.blue)
            .background(Color.blue)
            .cornerRadius(10)
            .padding()
        }
    }
    
    func createGame() {
        //TODO: I am lonely, I need a database
        //can use "role" state variable here
    }
}

struct CreateGameView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGameView()
    }
}
