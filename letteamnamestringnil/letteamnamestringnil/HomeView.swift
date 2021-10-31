//
//  LoginView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

//@main
struct HomeView: View {
    
    var body: some View {
        NavigationView {
            VStack {
                
                Spacer()
                
                Text("TCP")
                    .font(.largeTitle)
//                    .padding(.bottom, 20.0)
                
                Spacer()
                Spacer()

                NavigationLink (
                    destination: GamesView(),
                    label: {
                        Text("Join Game")
                    }
                )
                    .padding(.bottom, 12.0)
                
                NavigationLink(
                    destination: Text("You pressed create game!"),
                    label: {
                        Text("Create Game")
                    }
                )
                
                Spacer()
                
            }
            .buttonStyle(BigRedButton())
        }
    }
    
    func tempFunc() {
        return
    }
    
    /*
     
     Button("Join Game", action: tempFunc)
         .padding(.bottom, 20.0)
     
     Button("Create Game", action: tempFunc)
     
     */
}

struct BigRedButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 180.0)
            .padding()
            .background(Color("redAccent"))
            .foregroundColor(.white)
            .clipShape(Rectangle())
            .cornerRadius(3.0)
            .font(.title)
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
