//
//  LoginView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    
    var body: some View {
        VStack {
            Text("TCP")
                .font(.largeTitle).bold() //TODO: custom fonts are a lot of work, not skeletal
                .padding()
            Text("Traveler Creation Partner")
            Spacer() //TODO: I don't love this spacing
            
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
            
            NavigationLink(destination: CreateGameView()) {
                Text("Create New Party")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .background(Color.blue)
            .cornerRadius(10)
            .padding()

            NavigationLink(destination: GamesView(username: username)) {
                Text("Join Game")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .background(Color.blue)
            .cornerRadius(10)
            .padding()
            
            Spacer()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
