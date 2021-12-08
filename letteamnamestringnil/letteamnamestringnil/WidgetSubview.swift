//
//  WidgetSubview.swift
//  letteamnamestringnil
//
//  Created by Daniel Liu on 21-11-21.
//

import SwiftUI

struct WidgetSubview: View {
    
    @Binding var players: [Player]
    
    @State var title: String = "HP"
    @State var color: Color = .purple
    var render: (CharacterSheet) -> String
    
    init(title: String, color: Color, render: @escaping (CharacterSheet) -> String, players: Binding<[Player]>) {
        self.title = title
        self.color = color
        self.render = render
        self._players = players
    }
    
    var body: some View {
        VStack {
            Group {
                Text(title)
                    .font(.title)
                List {
                    ForEach(players, id: \.username) { player in
                        if player.csheet != nil {
                            Text(player.username + ": " + render(player.csheet!))
                        }
                    }
                }.frame(width: nil, height: 144, alignment: .center)
                    .listStyle(.inset)
            }
        }
        .padding()
        .border(color, width: 2)
    }
}
