//
//  GamesView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI
import UIKit

struct GamesView: View {
    private var games = ["game1", "game2", "game3"] //TODO: remove me
    @State private var partyCode: String = ""
    
    var body: some View {
        VStack {
            Text("Campaigns Joined")
                .font(.title2)
                .padding()
            List {
                ForEach(games, id: \.self) { game in
                    GameInfoView(gameCode: game, username: "User")
                }
            }
            .listStyle(.plain)
            
            
            Text("Enter a party code:")
                .font(.title2)
                .padding()
            
            TextField("", text: $partyCode)
                .font(.title3)
                .multilineTextAlignment(.center)
                .frame(width: 120) //TODO: this is hacky
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                )
            
            NavigationLink(destination: PlayerView()) {
                Text("Join New Party")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .simultaneousGesture(TapGesture().onEnded(joinPartyWithCode)) // TODO: what if party doesn't exist?
            .disabled(partyCode == "")
            .background((partyCode == "") ? Color.gray : Color.blue)
            .cornerRadius(10)
            .padding()
        }
        .padding()
    }
    
    func joinPartyWithCode() {
        //TODO: I am lonely! I need a database!
        print("joining party with code...")
        
        //check to see if party exists
        //if not, error
        //if party exists, add username record to party
    }
}

struct GameInfoView: View {
    @State var gameCode: String
    @State var username: String
    
    var body: some View {
        HStack {
            VStack {
                Text(gameCode)
                Text(username)
            }
            Spacer()
            Button(action: deleteGame) {
                Image(systemName: "x.square")
                    .foregroundColor(Color.red)
            }
        }
    }
    func deleteGame() {
        //TODO: remove player from game in database
        //if player created game, does whole game go away? backend problem
    }
}

struct GamesView_Previews: PreviewProvider {
    static var previews: some View {
        GamesView()
    }
}
