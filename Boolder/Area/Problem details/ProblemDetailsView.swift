//
//  ProblemDetailsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 25/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ProblemDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: DataStore
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    @Binding var problem: Problem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ZStack(alignment: .topLeading) {
                    Image(uiImage: problem.mainTopoPhoto())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    BezierViewRepresentable(problem: problem)
                    
                    GeometryReader { geo in
                        if lineFirstPoint(photoSize: geo.size) != nil {
                            ProblemCircleView(problem: problem, isDisplayedOnPhoto: true)
                                .offset(x: lineFirstPoint(photoSize: geo.size)!.x - 14, y: lineFirstPoint(photoSize: geo.size)!.y - 14)
                        }
                    }
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(UIColor.init(white: 1.0, alpha: 0.8)))
                            .padding(16)
                            .shadow(color: Color.gray, radius: 8, x: 0, y: 0)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 8) {
                    
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(problem.nameWithFallback())
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.label))
                                
                                Spacer()
                                
                                Text(problem.grade.string)
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                        }
                    
                        
                        HStack(alignment: .firstTextBaseline) {
                            Image(Steepness(problem.steepness).imageName)
                                .font(.body)
                                .frame(minWidth: 16)
                            Text(Steepness(problem.steepness).name)
                                .font(.body)
                            Text(problem.readableDescription() ?? "")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                        }
                        
//                        if problem.isRisky() {
//                        
//                            Divider()
//                            
//                            HStack {
//                                Image(systemName: "exclamationmark.shield.fill")
//                                    .font(.body)
//                                    .foregroundColor(Color.red)
//                                    .frame(minWidth: 16)
//                                Text("risky.long")
//                                    .font(.body)
//                                    .foregroundColor(Color.red)
//                                }
//                        }
                    }
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            toggleFavorite()
                        }) {
                            HStack(alignment: .center, spacing: 16) {
                                if isFavorite() {
                                    Image(systemName: "star.fill")
                                        .font(.title)
                                    Text("problem.favorite")
                                        .fontWeight(.bold)
                                        .padding(.vertical)
                                        .fixedSize(horizontal: true, vertical: true)
                                }
                                else {
                                    Image(systemName: "star")
                                        .font(.title)
                                    Text("problem.favorite")
                                        .fontWeight(.bold)
                                        .padding(.vertical)
                                        .fixedSize(horizontal: true, vertical: true)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGreen))
                        .foregroundColor(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        
                        Button(action: {
                            toggleTick()
                        }) {
                            HStack(alignment: .center, spacing: 16) {
                                if isTicked() {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title)
                                    Text("problem.ticked.short")
                                        .fontWeight(.bold)
                                        .padding(.vertical)
                                        .fixedSize(horizontal: true, vertical: true)
                                }
                                else {
                                    Image(systemName: "circle")
                                        .font(.title)
                                    Text("problem.ticked.short")
                                        .fontWeight(.bold)
                                        .padding(.vertical)
                                        .fixedSize(horizontal: true, vertical: true)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemBackground))
                        .foregroundColor(Color(UIColor.systemGreen))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.systemGreen), lineWidth: 2)
                        )
                    }
                    .padding(.vertical)
                    
//                    VStack(alignment: .leading) {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("Circuit")
//                                .font(.title)
//                                .fontWeight(.bold)
//                            Rectangle()
//                                .fill(Color.green)
//                                .frame(width: 70, height: 4, alignment: .leading)
//                        }
//                    }
//                    .padding(.vertical, 16)
                }
                .padding(.horizontal)
                .padding(.top, 0)
                
                
                
                Spacer()
            }
        }
//        .navigationBarTitle(Text(problem.name ?? ""), displayMode: .inline)
//        .navigationBarItems(trailing:
//            HStack(spacing: 16) {
//                Button(action: {}) {
//                    Image(systemName: "square.and.arrow.up")
//                }
//            }
//        )
    }
    
    func lineFirstPoint(photoSize size: CGSize) -> CGPoint? {
        guard let lineFirstPoint = problem.lineFirstPoint() else { return nil }
            
        return CGPoint(x: CGFloat(lineFirstPoint.x) * size.width, y: CGFloat(lineFirstPoint.y) * size.height)
    }
        
    func isFavorite() -> Bool {
        favorite() != nil
    }
    
    func favorite() -> Favorite? {
        favorites.first { (favorite: Favorite) -> Bool in
            return Int(favorite.problemId) == problem.id
        }
    }
    
    func toggleFavorite() {
        if isFavorite() {
            deleteFavorite()
        }
        else {
            createFavorite()
        }
    }
    
    func createFavorite() {
        let favorite = Favorite(context: managedObjectContext)
        favorite.id = UUID()
        favorite.problemId = Int64(problem.id)
        favorite.createdAt = Date()
        
        do {
            try managedObjectContext.save()
        } catch {
            // handle the Core Data error
        }
    }
    
    func deleteFavorite() {
        guard let favorite = favorite() else { return }
        managedObjectContext.delete(favorite)
        
        do {
            try managedObjectContext.save()
        } catch {
            // handle the Core Data error
        }
    }
    
    func isTicked() -> Bool {
        tick() != nil
    }
    
    func tick() -> Tick? {
        ticks.first { (tick: Tick) -> Bool in
            return Int(tick.problemId) == problem.id
        }
    }
    
    func toggleTick() {
        if isTicked() {
            deleteTick()
        }
        else {
            createTick()
        }
    }
    
    func createTick() {
        let tick = Tick(context: managedObjectContext)
        tick.id = UUID()
        tick.problemId = Int64(problem.id)
        tick.createdAt = Date()
        
        do {
            try managedObjectContext.save()
        } catch {
            // handle the Core Data error
        }
    }
    
    func deleteTick() {
        guard let tick = tick() else { return }
        managedObjectContext.delete(tick)
        
        do {
            try managedObjectContext.save()
        } catch {
            // handle the Core Data error
        }
    }
}

struct ProblemDetailsView_Previews: PreviewProvider {
    static let dataStore = DataStore()
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static var previews: some View {
        ProblemDetailsView(problem: .constant(dataStore.problems.last!))
            .environment(\.managedObjectContext, context)
            .environmentObject(dataStore)
    }
}

