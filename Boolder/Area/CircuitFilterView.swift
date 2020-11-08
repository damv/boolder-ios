//
//  CircuitFilterView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct CircuitFilterView: View {    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: DataStore
    
    @State private var presentCircuitArticle = false
    @Binding var filters: Filters
    
    var body: some View {
        Form {
            Section {
                ForEach(dataStore.geoStore.circuits, id: \.color) { (circuit: Circuit) in
                    Button(action: {
                        if filters.circuit == circuit.color {
                            filters.circuit = nil
                        }
                        else {
                            filters.circuit = circuit.color
                            filters.gradeRange = nil
                        }
                        
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(alignment: .center) {
                            CircleView(number: "", color: circuit.color.uicolor, height: 20)
                            
                            Text("\(circuit.color.shortName())")
                                .foregroundColor(Color(.label))
                            
                            Spacer()
                            
                            if filters.circuit == circuit.color {
                                Image(systemName: "checkmark").font(Font.body.weight(.bold))
                            }
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("filters.circuit", displayMode: .inline)
        .navigationBarItems(
            trailing: Button(action: {
                presentCircuitArticle.toggle()
            }) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 20, weight: .regular))
                    .padding(.vertical)
                    .padding(.leading, 32)
            }
            .sheet(isPresented: $presentCircuitArticle) {
                CircuitHelpView()
                    // FIXME: use accent color on all views by default (even for modals)
                    // read this blog post: https://medium.com/swlh/swiftui-and-the-missing-environment-object-1a4bf8913ba7
                    .environmentObject(dataStore)
                    .accentColor(Color.green)
            }
        )
    }
}

struct CircuitFilterView_Previews: PreviewProvider {
    static var previews: some View {
        CircuitFilterView(filters: .constant(Filters()))
            .environmentObject(DataStore())
    }
}
