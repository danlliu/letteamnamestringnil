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
                
            List {
                Section(header: Text("Active Widgets")) {
                    ForEach(chosenWidgets, id: \.name) { widget in
                        Button(action: {
                            chosenWidgets.remove(at: chosenWidgets.firstIndex {x in
                                x.name == widget.name
                            }!)
                            nonChosenWidgets.append(widget)
                        }) {
                            HStack {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                Text(widget.name)
                            }
                        }.foregroundColor(.black)
                    }
                    .onMove(perform: {f, t in chosenWidgets.move(fromOffsets: f, toOffset: t)})
                }
                Section(header: Text("Inactive Widgets")) {
                    ForEach(nonChosenWidgets, id: \.name) { widget in
                        Button(action: {
                            nonChosenWidgets.remove(at: nonChosenWidgets.firstIndex { x in
                                x.name == widget.name
                            }!)
                            chosenWidgets.append(widget)
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                Text(widget.name)
                            }
                        }.foregroundColor(.black)
                    }
                    .onMove(perform: {f, t in nonChosenWidgets.move(fromOffsets: f, toOffset: t)})
                }
            }
            .animation(.default)
            .listStyle(.grouped)
        }
    }
}

@available(iOS 15.0, *)
struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView()
    }
}
