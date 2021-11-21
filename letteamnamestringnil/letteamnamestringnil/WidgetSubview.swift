//
//  WidgetSubview.swift
//  letteamnamestringnil
//
//  Created by Daniel Liu on 21-11-21.
//

import SwiftUI

struct WidgetSubview: View {
    @State var title: String = "HP"
    @State var color: Color = .purple
    var render: (CharacterSheet) -> [String] = {c in
        return [c.id]
    }
    // TODO: I'm lonely, give me a database
    
    var body: some View {
        VStack {
            Group {
                Text(title)
                    .font(.title)
                List {
                    Text("alice: 10 / 30")
                    Text("bob: 25 / 28")
                    Text("jinx: 20 / 25")
                    Text("cave orc: 1 / 15")
                    // TODO: content (ForEach on render result)
                }.frame(width: nil, height: 144, alignment: .center)
                    .listStyle(.inset)
            }
        }
        .padding()
        .border(color, width: 2)
    }
}

struct WidgetSubview_Previews: PreviewProvider {
    static var previews: some View {
        WidgetSubview()
    }
}
