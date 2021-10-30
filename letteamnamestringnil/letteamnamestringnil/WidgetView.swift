//
//  WidgetView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

struct Widget {
    
    var name: String
    
}

@available(iOS 15.0, *)
struct WidgetView: View {
    
    @State var chosenWidgets: [Widget] = [
        Widget(name: "hp"),
        Widget(name: "spells")
    ]
    @State var nonChosenWidgets: [Widget] = [
        Widget(name: "skills"),
        Widget(name: "inventory"),
        Widget(name: "ability modifiers")
    ]
    
    var body: some View {
        VStack {
            Text("Customize Widgets")
                .font(.largeTitle)
                
            Divider()
            
            ForEach(chosenWidgets, id: \.name) { widget in
                HStack {
                    Spacer()
                    Button("remove", role: .destructive, action: {() in})
                    Spacer()
                    Text(widget.name)
                    Spacer()
                }
            }
            
            Divider()
            
            ForEach(nonChosenWidgets, id: \.name) { widget in
                HStack {
                    Spacer()
                    Button("add", role: .none, action: {() in})
                    Spacer()
                    Text(widget.name)
                    Spacer()
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView()
    }
}
