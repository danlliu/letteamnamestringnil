//
//  GamesView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI
import UIKit

struct GamesView: View {
    
    var username: String
    @State private var games: [GameData] = []
    @State private var partyCode: String = ""
    
    init(username: String = "user") {
        self.username = username
    }
    
    var body: some View {
        if #available(iOS 15.0, *) {
            VStack {
                Text("My Campaigns")
                        .font(.title2)
                        .padding()
                List {
                    ForEach(games, id: \.self) { game in
                        GameInfoView(gameCode: game.code, username: username)
                    }
                }
                        .listStyle(.plain)

                Text("Enter a party code:")
                        .font(.title2)
                        .padding()

                TextField("", text: $partyCode)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                        .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                        )

                NavigationLink(destination: PlayerView(partyCode: partyCode, username: username)) {
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
                    .task {
                        let games = await Store.shared.getParties()
                        self.games = games.map {
                            GameData(code: $0)
                        }
                    }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func joinPartyWithCode() {
        //TODO: I am lonely! I need a database!
        print("joining party with code...")

        if #available(iOS 15.0, *) {
            Task {
                await Store.shared.joinParty(code: partyCode)
            }
        } else {
            // Fallback on earlier versions
        }
        //check to see if party exists
        //if not, error
        //if party exists, add username record to party
    }
}

struct GameInfoView: View {
    @State var gameCode: String
    @State var username: String
    @State var isDM: Bool
    @State var goPlayer: Bool = false
    @State var goDM: Bool = false
    
    var body: some View {
        if #available(iOS 15.0, *) {
            HStack {
                VStack(alignment: .leading) {
                    Text(gameCode)
                            .font(.headline)
                    Text(username)
                            .font(.subheadline)
                }
                Spacer()
                Button(action: {
                    joinGame()
                }) {
                    Image(systemName: "square.and.arrow.down")
                }
                NavigationLink(destination: PlayerView(partyCode: gameCode, username: username), isActive: $goPlayer) {
                    EmptyView()
                }.hidden()
                NavigationLink(destination: DMView(partyCode: gameCode, username: username), isActive: $goDM) {
                    EmptyView()
                }.hidden()
            }
                    .task {
                        let p = await Store.shared.getPlayerData(code: gameCode, player: username)
                        self.isDM = p.isDM
                    }
        } else {
            // Fallback on earlier versions
        }
    }

    func joinGame() {
        if isDM {
            goDM = true
        } else {
            goPlayer = true
        }
    }
}

struct GameData: Hashable {
    var code: String
    //TODO: can add other relevant info to show here
}

struct GamesView_Previews: PreviewProvider {
    static var previews: some View {
        GamesView(username: "tuna_player_485")
    }
}
