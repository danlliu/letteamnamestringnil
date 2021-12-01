//
//  CreateGameView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/31/21.
//

import SwiftUI

struct CreateGameView: View {
    @State private var partyCode: String = ""
    @State var username = ""

    @State private var role: String = ""
    
    private var buttonPadding: CGFloat = 10
    
    var body: some View {
        VStack {
            Spacer()
            Text("Enter a party code:")
                .font(.title2)
            
            TextField("", text: $partyCode)
                .multilineTextAlignment(.center)
                .padding(buttonPadding)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                )
                .padding()
            HStack {
                Button(action: {
                    role = "DM"
                }) {
                    Text("Join as DM")
                        .foregroundColor((role == "DM") ? Color.white : Color.blue)
                        .padding(buttonPadding)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 3)
                )
                .background((role == "DM") ? Color.blue : Color.white)
                .cornerRadius(10)
                .padding()
                
                Button(action: {
                    role = "player"
                }){
                    Text("Join as Player")
                        .foregroundColor((role == "player") ? Color.white : Color.blue)
                        .padding(buttonPadding)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 3)
                )
                .background((role == "player") ? Color.blue : Color.white)
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
            }
            
            Spacer()
            
            //TODO: GenerateCharacter need arguments
            NavigationLink(destination: (role == "DM") ? AnyView(DMView(partyCode: partyCode, username: username)) : AnyView(GenerateCharacter())) {
                Text("Create Party")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .simultaneousGesture(TapGesture().onEnded(createGame))
            .disabled(partyCode == "" || role == "")
            .background((partyCode == "" || role == "") ? Color.gray : Color.blue)
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
