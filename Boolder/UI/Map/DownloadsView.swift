//
//  DownloadsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/06/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct DownloadsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let mapState: MapState
    
    var body: some View {
        NavigationView {
            List {
                
                
                if let cluster = mapState.selectedCluster {
//                    Section {
//                        HStack {
//                            Text("\(Int(cluster.areas.reduce(0) { $0 + $1.photosSize }.rounded())) Mo")
//                        }
//                    }
                    
                    Section {
                        
                        NavigationLink {
                            List {
                                ForEach(cluster.areas) { area in
                                    HStack {
                                        Text(area.name)
                                        Text("\(Int(area.photosSize.rounded())) Mo")
                                        Spacer()
                                        DownloadAreaButtonView(area: area, presentRemoveDownloadSheet: .constant(false), presentCancelDownloadSheet: .constant(false))
                                    }
                                }
                            }
                        } label: {
                            HStack {
//                                Text("\(cluster.areas.count) secteurs")
                                Text(cluster.name)
                                Spacer()
                                Text("\(Int(cluster.areas.reduce(0) { $0 + $1.photosSize }.rounded())) Mo").foregroundStyle(.gray)
                            }
                        }
                        
                        HStack {
                            Spacer()
                            Text("Télécharger").foregroundStyle(Color.appGreen)
                            Spacer()
                        }
                        
                    }
                }
                
            }
            .navigationTitle("Téléchargements")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Fermer")
                        .padding(.vertical)
                        .font(.body)
                }
            )
        }
    }
}

//#Preview {
//    DownloadsView()
//}
