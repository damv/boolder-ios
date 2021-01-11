//
//  FabFiltersView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct FabFiltersView: View {
    @State private var presentCircuitFilter = false
    @State private var presentFilters = false
    
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    @State var filters: Filters
    
    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                
                Button(action: {
                    presentFilters.toggle()
                }) {
                    HStack {
                        if dataStore.filters.filtersCount() == 0 {
                            Image(systemName: "slider.horizontal.3")
                        }
                        else
                        {
                            RoundedRectangle(cornerRadius: 6)
                            .fill(Color.green)
                                .frame(width: 20, height: 20)
                                .overlay(Text(String(dataStore.filters.filtersCount()))
                                .font(.headline)
                                .padding(.horizontal, 4)
                                )
                                .foregroundColor(Color(.systemBackground))
                        }
                        Text(dataStore.filters.filtersCount() == 1 ? "area.filter" : "area.filters")
                            .fixedSize(horizontal: true, vertical: true)
                    }
                    .padding(.vertical, 12)
                }
                
                .sheet(isPresented: $presentFilters, onDismiss: {
                    dataStore.filters = filters
                }) {
                    FiltersView(presentFilters: $presentFilters, filters: $filters)
                        // FIXME: there is a bug with SwiftUI not passing environment correctly to modal views
                        // remove these lines as soon as it's fixed
                        .environmentObject(dataStore)
                        .environment(\.managedObjectContext, managedObjectContext)
                }
            }
        }
        .accentColor(Color(.label))
        .padding(.horizontal, 16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.25))
        .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
        .padding()
    }
}

struct FabFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FabFiltersView(filters: Filters())
            .environmentObject(DataStore())
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
