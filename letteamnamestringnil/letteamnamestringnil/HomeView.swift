//
//  LoginView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

struct HomeView: View {
    
    var username: String = "guest"
    
    var body: some View {
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

            //TODO: Make this a button, use callback from model to redirect to DMView
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
