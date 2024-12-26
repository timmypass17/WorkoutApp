//
//  WorkoutService.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/25/24.
//

import Foundation
import CoreData
import UIKit

class WorkoutService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchWorkoutPlans() -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "createdAt == nil")
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        
        do {
            let workoutPlans = try context.fetch(request)
            return workoutPlans
        } catch {
            print("Error fetching workouts: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchLoggedWorkouts() -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        let predicate = NSPredicate(format: "createdAt != nil")
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let workoutPlans = try context.fetch(request)
            return workoutPlans
        } catch {
            print("Error fetching logs: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Get exercise data  from Core Data.
    /// - The sets within each exercise are sorted by date (oldest to recent).
    /// - Returns: List of exercise progress data
    func fetchProgressData() -> [ProgressData] {
        var data: [String : [ExerciseSet]] = [:]
        let request: NSFetchRequest<ExerciseSet> = ExerciseSet.fetchRequest()
        let predicate = NSPredicate(format: "exercise.workout.createdAt != nil")
        let sortDescriptor = NSSortDescriptor(key: "exercise.workout.createdAt", ascending: true)
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let exerciseSets: [ExerciseSet] = try context.fetch(request)
            for set in exerciseSets {
                guard let name = set.exercise?.title else { continue }
                data[name, default: []].append(set)
            }
            return data
                .map { ProgressData(name: $0.key, sets: $0.value) }
                .sorted(by: { $0.name < $1.name})
        } catch {
            print("Error fetching logs: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteWorkout(_ workout: Workout) {
        context.delete(workout)
        
        do {
            try context.save()
        } catch {
            print("Failed to delete workout: \(error)")
        }
    }
    
    func reorderWorkouts(_ workouts: inout [Workout], moveWorkoutAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }
        
        let workoutToMove = workouts.remove(at: sourceIndexPath.row)
        workouts.insert(workoutToMove, at: destinationIndexPath.row)
        
        for (index, workout) in workouts.enumerated() {
            workout.index = Int16(index)
        }
        
        do {
            try context.save()
            print("save: \(context)")
        } catch {
            print("Error saving reordering: \(error)")
        }
    }
}
