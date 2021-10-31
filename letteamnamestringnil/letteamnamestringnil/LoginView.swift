//
//  LoginView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var partyCode: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("username:")
                    //.padding()
                TextField("username", text: $username)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                    )
            }
            .padding()
            
            Button(action: createParty) {
                Text("Create New Party")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .background(Color.blue)
            .cornerRadius(10)
            .padding()
            
            Text("Or enter a party code:")
                .padding()
            
            TextField("", text: $partyCode)
                .frame(width: 120) //TODO: this is hacky
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                )
            NavigationLink(destination: GamesView()) {
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
    
    func createParty() {
        //TODO: create party entry in database
        print("creating a new party...")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
