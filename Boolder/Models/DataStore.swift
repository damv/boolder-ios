//
//  DataStore.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/03/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//


import MapKit
import CoreData

class DataStore : ObservableObject {
    var geoStore = GeoStore(areaId: 1)
    var topoStore = TopoStore(areaId: 1)
    
    var areaId: Int = 1 {
        didSet {
            if oldValue != areaId {
                self.geoStore = GeoStore(areaId: areaId)
                self.topoStore = TopoStore(areaId: areaId)
                self.refresh()
            }
        }
    }
    
    // custom wrapper instead of @Published, to be able to refresh data store everytime filters change
    var filters = Filters() {
        willSet { objectWillChange.send() }
        didSet { self.refresh() }
    }

    @Published var overlays = [MKOverlay]()
    @Published var problems = [Problem]()
    @Published var pois = [Poi]()
    @Published var groupedProblems = Dictionary<Circuit.CircuitColor, [Problem]>()
    @Published var groupedProblemsKeys = [Circuit.CircuitColor]()
    
    let areas = [1: "Rocher Canon", 2: "Cul de Chien", 4: "Cuvier"]

    init() {
        refresh()
    }
    
    func refresh() {
        overlays = geoStore.boulderOverlays
        
        if let circuitOverlay = circuitOverlay() {
            overlays.append(circuitOverlay)
        }
        
        overlays.append(contentsOf: geoStore.poiRouteOverlays)
        
        problems = filteredProblems()
        setBelongsToCircuit()
        createGroupedAnnotations()
        
        pois = geoStore.pois
    }
    
    private func filteredProblems() -> [Problem] {
        return geoStore.problems.filter { problem in
            if(filters.circuit == nil || problem.circuitColor == filters.circuit) {
                if isGradeOk(problem)  {
                    if filters.steepness.contains(problem.steepness) {
                        if filters.photoPresent == false || problem.isPhotoPresent() {
                            if isHeightOk(problem) {
                                if filters.favorite == false || problem.isFavorite()  {
                                    if filters.ticked == false || problem.isTicked()  {
                                        if filters.risky == true || !problem.isRisky()  {
                                            return true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return false
        }
    }
    
    private func isHeightOk(_ problem: Problem) -> Bool {
        if filters.heightMax == Int.max { return true }
        
        if let height = problem.height {
            return (height <= filters.heightMax)
        }
        else {
            return false
        }
    }
    
    private func isGradeOk(_ problem: Problem) -> Bool {
        if let grade = problem.grade {
            return grade >= filters.gradeMin && grade <= filters.gradeMax
        }
        else {
            return (filters.gradeMin == Filters().gradeMin && filters.gradeMax == Filters().gradeMax)
        }
    }
    
    private func circuitOverlay() -> CircuitOverlay? {
        if let circuitColor = filters.circuit {
            if let circuit = circuit(withColor: circuitColor) {
                return circuit.overlay
            }
        }
        
        return nil
    }
    
    func circuit(withColor color: Circuit.CircuitColor) -> Circuit? {
        geoStore.circuits.first { $0.color == color }
    }
    
    private func createGroupedAnnotations() {
        var sortedProblems = problems
        sortedProblems.sort { (lhs, rhs) -> Bool in
            guard let lhsGrade = lhs.grade else { return true }
            guard let rhsGrade = rhs.grade else { return false }
            
            if lhs.circuitNumber == rhs.circuitNumber {
                return lhsGrade < rhsGrade
            }
            else {
                return lhs.circuitNumberComparableValue() < rhs.circuitNumberComparableValue()
            }
        }
        
        groupedProblems = Dictionary(grouping: sortedProblems, by: { (problem: Problem) in
            problem.circuitColor ?? Circuit.CircuitColor.offCircuit
        })
        
        groupedProblemsKeys = groupedProblems.keys.sorted()
    }
    
    private func setBelongsToCircuit() {
        for problem in problems {
            problem.belongsToCircuit = (filters.circuit == problem.circuitColor)
        }
    }
    
    func favorites() -> [Favorite] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        request.sortDescriptors = []
        
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Failed to fetch favorites: \(error)")
        }
    }
    
    func ticks() -> [Tick] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request: NSFetchRequest<Tick> = Tick.fetchRequest()
        request.sortDescriptors = []
        
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Failed to fetch ticks: \(error)")
        }
    }
}
