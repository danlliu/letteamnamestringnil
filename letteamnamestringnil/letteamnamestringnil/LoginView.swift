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
            
            Spacer()
            
            Text("TCP")
                .font(.largeTitle).bold() //TODO: custom fonts are a lot of work, not skeletal
                .padding()
            Text("Traveler Creation Partner")
            Spacer() //TODO: I don't love this spacing
            
            VStack {
                Text("username:")
                TextField("username", text: $username)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                    )
            }
            .frame(width: 300)
            .padding()
            
            Spacer()
            
            NavigationLink(destination: CreateGameView()) {
                Text("Create New Party")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .frame(width: 220)
            .background(Color.blue)
            .cornerRadius(40)

            NavigationLink(destination: GamesView(username: username)) {
                Text("Join Game")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .frame(width: 220)
            .background(Color.blue)
            .cornerRadius(40)
            .padding(8)
        
            
            Spacer()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
