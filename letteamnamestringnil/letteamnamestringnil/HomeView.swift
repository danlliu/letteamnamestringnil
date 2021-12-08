//
//  LoginView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

struct HomeView: View {
    
    @State var username: String = "guest"
    // https://stackoverflow.com/questions/57799548/navigationview-and-navigationlink-on-button-click-in-swiftui
    @State var active = false
    @State var newPartyCode = ""
    
    var body: some View {
        if #available(iOS 15.0, *) {
            VStack {
                
                Spacer()
                Text("TCP")
                    .font(.largeTitle).bold() //TODO: custom fonts are a lot of work, not skeletal
                    .padding(5)
                Text("Traveler Creation Partner")
                //                .font(.headline)
                Spacer() //TODO: I don't love this spacing
                
                Text("Welcome, \(username)!")
                
                Spacer() //TODO: I don't love this spacing
                
                //            VStack {
                //                Text("username:")
                //                TextField("username", text: $username)
                //                    .padding(10)
                //                    .overlay(
                //                        RoundedRectangle(cornerRadius: 10)
                //                                .stroke(Color.gray, lineWidth: 1)
                //                    )
                //            }
                //            .frame(width: 300)
                //            .padding()
                
                //            Spacer()
                
                HStack {
                    Text("username:")
                    TextField("username", text: $username)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                .padding()
                
                Button(action: {
                    Task {
                        await Store.shared.logout()
                        await Store.shared.createAccount(username: username, password: username)
                        await Store.shared.login(username: username, password: username)
                        guard let code = await Store.shared.createParty() else {
                            return
                        }
                        newPartyCode = code
                        active = true
                    }
                }) {
                    Text("Create New Party")
                        .foregroundColor(Color.white)
                        .padding()
                }
                .frame(width: 220)
                .background(Color.blue)
                .cornerRadius(40)
                .padding(8)
                NavigationLink(destination: DMView(partyCode: newPartyCode, username: username), isActive: $active) {
                    EmptyView()
                }.hidden()
                
                NavigationLink(destination: GamesView(username: username)) {
                    Text("Join Game")
                        .foregroundColor(Color.white)
                        .padding()
                }
                .frame(width: 220)
                .background(Color.blue)
                .cornerRadius(40)
                .padding(8)
                
            }.task {
                await Store.shared.logout()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
