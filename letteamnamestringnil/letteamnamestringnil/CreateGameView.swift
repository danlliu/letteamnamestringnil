//
//  CreateGameView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/31/21.
//

import SwiftUI

struct CreateGameView: View {
    @State private var partyCode: String = ""
    @State private var role: String = ""
    
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
                NavigationLink(destination: PlayerView()) {
                    Text("Join as DM")
                        .foregroundColor(Color.white)
                        .padding(buttonPadding)
                }
                .simultaneousGesture(TapGesture().onEnded({
                    role = "DM"
                    createGame()
                }))
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
                
                NavigationLink(destination: PlayerView()) {
                    Text("Join as Player")
                        .foregroundColor(Color.white)
                        .padding(buttonPadding)
                }
                .simultaneousGesture(TapGesture().onEnded({
                    role = "player"
                    createGame()
                }))
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
                
            }
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
