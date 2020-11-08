//
//  PoiActionSheet.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 04/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import MapKit
import SwiftUI

struct PoiActionSheet: View {
    @Binding var presentPoiActionSheet: Bool
    @Binding var selectedPoi: Poi?
    @State private var showShareSheet = false
    
    var location: CLLocationCoordinate2D {
        selectedPoi?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    func buttons() -> [Alert.Button] {
        var buttons = [Alert.Button]()
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            buttons.append(
                .default(Text(
                    String.localizedStringWithFormat(NSLocalizedString("poi.see_in", comment: ""), "Google Maps")
                )) {
                    UIApplication.shared.open(URL(string: "comgooglemaps://?daddr=\(location.latitude),\(location.longitude)")!)
                }
            )
        }
        
        if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
            buttons.append(
                .default(Text(
                    String.localizedStringWithFormat(NSLocalizedString("poi.see_in", comment: ""), "Waze")
                )) {
                    let urlStr: String = "waze://?ll=\(location.latitude),\(location.longitude)&navigate=yes"
                    UIApplication.shared.open(URL(string: urlStr)!)
                }
            )
        }
        
        buttons.append(
            .default(Text(
                String.localizedStringWithFormat(NSLocalizedString("poi.see_in", comment: ""), "Apple Maps")
            )) {
                let destination = MKMapItem(placemark: MKPlacemark(coordinate: location))
                destination.name = selectedPoi?.description ?? ""

                MKMapItem.openMaps(with: [destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            }
        )
        
        buttons.append(
            .default(Text("poi.share")) {
                showShareSheet = true
            }
        )
        
        buttons.append(
            .cancel(Text("poi.cancel"))
        )
        
        return buttons
    }
    
    var body: some View {
        EmptyView()
            .actionSheet(isPresented: $presentPoiActionSheet) {
                ActionSheet(
                    title: Text(selectedPoi?.description ?? ""),
                    buttons: buttons()
                )
        }
        .background(
            EmptyView()
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(activityItems: [
                        String.localizedStringWithFormat(NSLocalizedString("poi.gps_coordinates_for_poi", comment: ""), selectedPoi?.description ?? "", location.latitude.description, location.longitude.description)
                    ])
                }
        )
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
      
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil
      
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
      
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}
