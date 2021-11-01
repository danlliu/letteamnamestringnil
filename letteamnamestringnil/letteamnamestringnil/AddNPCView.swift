//
//  AddNPCView.swift
//  letteamnamestringnil
//
//  Created by Abigail Fox on 10/28/21.
//

import SwiftUI

struct AddNPCView: View {
    @State var friendly: Bool
    var body: some View {
        VStack {
            if(friendly) {
                Text("friendly")
            }
            else {
                Text("monster")
            }
        }
    }
}
