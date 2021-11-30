//
//  WelcomeView.swift
//  letteamnamestringnil
//
//  Created by Alexis Covacha on 11/25/21.
//

import SwiftUI

struct WelcomeView: View {
    
    @State var signupShown = false
    @State var loginShown = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Text("TCP")
                    .font(.largeTitle).bold() //TODO: custom fonts are a lot of work, not skeletal
                    .padding(5)
                Text("Traveler Creation Partner")
                Spacer() //TODO: I don't love this spacing
                
                Text("Welcome, guest!")
                
                Spacer()
                
                Button("Login") {
                    self.loginShown.toggle()
                    let _ = print("toggle: \(loginShown)")
                }
                    .padding()
                    .foregroundColor(Color.white)
                    .frame(width: 220)
                    .background(Color.blue)
                    .clipShape(Capsule())
                
                Button(action: {
                    self.signupShown.toggle()
                }) {
                    Text("Signup")
                        .foregroundColor(Color.white)
                        .padding()
                }
                    .frame(width: 220)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .padding(8)
                
                Spacer()
            }
            
            AccountsModalView(isShown: $loginShown, modalHeight: 500.0) {
                LoginView()
            }
            
            AccountsModalView(isShown: $signupShown, modalHeight: 500.0) {
                SignupView()
            }
        }
    }
}

struct LoginView: View {
    var body: some View {
        Text("Login context")
    }
}

struct SignupView: View {
    var body: some View {
        Text("Login context")
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
