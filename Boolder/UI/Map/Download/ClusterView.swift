//
//  ClusterView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/06/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ClusterView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let clusterDownloader: ClusterDownloader // we don't use @ObservedObject because it would make the actionsheets unresponsive
    let cluster: Cluster
    let area: Area?
    
    @State private var presentRemoveDownloadSheet = false
    @State private var presentCancelDownloadSheet = false
    @State private var areaToEdit : Area = Area.load(id: 1)! // FIXME: don't use bang
    
    @State private var presentRemoveClusterDownloadSheet = false
    @State private var presentCancelClusterDownloadSheet = false
    
    @State private var handpickedDownload = false // TODO: refactor
    
    // TODO: compute only once (inside cluster downloader?)
    var areas: [Area] {
        cluster.areasSortedByDistance(area)
    }
    
    var body: some View {
        NavigationView {
            List {
                if areas.count > 1 {
                    clusterSection
                }
                
                areasSection
            }
            .background {
                EmptyView().actionSheet(isPresented: $presentRemoveDownloadSheet) {
                    ActionSheet(
                        title: Text("download.remove.title"),
                        buttons: [
                            .destructive(Text("download.remove.action")) {
                                DownloadCenter.shared.areaDownloader(id: areaToEdit.id).remove()
                            },
                            .cancel()
                        ]
                    )
                }
            }
            .background {
                EmptyView().actionSheet(isPresented: $presentCancelDownloadSheet) {
                    ActionSheet(
                        title: Text("download.cancel.title"),
                        buttons: [
                            .destructive(Text("download.cancel.action")) {
                                DownloadCenter.shared.areaDownloader(id: areaToEdit.id).cancel()
                            },
                            .cancel()
                        ]
                    )
                }
            }
            .navigationTitle("Téléchargements")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Fermer")
                        .padding(.vertical)
                        .font(.body)
                }
            )
        }
    }
    
    var clusterSection: some View {
        // we use a separate view to avoid redrawing the entire view everytime, which makes the actionsheet unresponsive
        // it probably won't be necessary anymore with iOS 17's @Observable
        ClusterDownloadRowView(clusterDownloader: clusterDownloader, cluster: cluster, presentRemoveClusterDownloadSheet: $presentRemoveClusterDownloadSheet, presentCancelClusterDownloadSheet: $presentCancelClusterDownloadSheet, handpickedDownload: $handpickedDownload)
        
    }
    
    var areasSection: some View {
        Section {
            ForEach(areas) { a in
                HStack {
                    Text(a.name).foregroundColor(.primary)
                    
                    Spacer()
                    
                    // we use a separate view to avoid redrawing the entire view everytime, which makes the actionsheet unresponsive
                    // it probably won't be necessary anymore with iOS 17's @Observable
                    AreaDownloadRowView(area: a, areaToEdit: $areaToEdit, presentRemoveDownloadSheet: $presentRemoveDownloadSheet, presentCancelDownloadSheet: $presentCancelDownloadSheet, handpickedDownload: $handpickedDownload, clusterDownloader: clusterDownloader)
                }
            }
        }
    }
}

//#Preview {
//    DownloadsView()
//}
