//
//  HealthService.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/17.
//

import Foundation
import HealthKit
import RxCocoa

class HealthService {
    static let shared = HealthService()
    
    let stepsRelay = BehaviorRelay<Int>(value: 0)
    let distanceRelay = BehaviorRelay<Double>(value: 0.0)
    let caloriesRelay = BehaviorRelay<Double>(value: 0.0)
    let healthDataRelay = BehaviorRelay<[Health]>(value: [])
    
    private let read = Set([
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!])
    
    private let share = Set([
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!])
    
    private let healthStore = HKHealthStore()
    
    private init() {
        requestAuthorization(completion: { [weak self] response in
            guard let `self` = self else { return }
            self.loadData()
            self.observeStepsChanges()
        })
    }
    
    private func requestAuthorization(completion: @escaping (Bool) -> Void) {
        healthStore.requestAuthorization(toShare: share, read: read, completion: { success, error in
            if error != nil {
                completion(false)
            }
            else {
                if success {
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
        })
    }
    
    private func loadData() {
        let dispatchGroup = DispatchGroup()
        
        var steps: Int = 0
        var distance: Double = 0.0
        var calories: Double = 0.0
        
        dispatchGroup.enter()
        fetchSteps { fetchedSteps in
            steps = fetchedSteps
            self.stepsRelay.accept(fetchedSteps)
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchDistance { fetchedDistance in
            distance = fetchedDistance
            self.distanceRelay.accept(fetchedDistance)
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchCalories { fetchedCalories in
            calories = fetchedCalories
            self.caloriesRelay.accept(fetchedCalories)
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let `self` = self else { return }
            
            let stepData = Health(name: "걸음", value: steps)
            let distanceData = Health(name: "이동 거리", value: Int(distance))
            let caloriesData = Health(name: "칼로리", value: Int(calories))
            self.healthDataRelay.accept([stepData,
                                         distanceData,
                                         caloriesData])
        }
    }

    
    private func observeStepsChanges() {
        guard HKHealthStore.isHealthDataAvailable(),
              let stepsQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        
        let query = HKObserverQuery(sampleType: stepsQuantityType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("Failed to set up observer query: \(error.localizedDescription)")
                return
            }
            
            self?.loadData()
        }
        
        healthStore.execute(query)
    }
    
    private func observeDistanceChanges() {
        guard HKHealthStore.isHealthDataAvailable(),
              let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        
        let query = HKObserverQuery(sampleType: distanceType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("Failed to set up distance observer query: \(error.localizedDescription)")
                return
            }
            
            self?.loadData()
        }
        
        healthStore.execute(query)
    }
    
    private func fetchSteps(completion: @escaping (Int) -> Void) {
        guard let stepsQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            var resultCount = 0
            if let error = error {
                print("Failed to fetch steps = \(error.localizedDescription)")
            }
            else if let sum = result?.sumQuantity() {
                resultCount = Int(sum.doubleValue(for: HKUnit.count()))
            }
            
            completion(resultCount)
        }
        
        healthStore.execute(query)
    }
    
    private func fetchDistance(completion: @escaping (Double) -> Void) {
        guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(0)
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            var resultValue = 0.0
            if let error = error {
                print("Failed to fetch distance = \(error.localizedDescription)")
            }
            else if let sum = result?.sumQuantity() {
                resultValue = sum.doubleValue(for: HKUnit.meter())
            }
            
            completion(resultValue)
        }
        
        healthStore.execute(query)
    }
    
    private func fetchCalories(completion: @escaping (Double) -> Void) {
        guard let caloriesType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(0)
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            var resultValue = 0.0
            if let error = error {
                print("Failed to fetch calories = \(error.localizedDescription)")
            } else if let sum = result?.sumQuantity() {
                resultValue = sum.doubleValue(for: HKUnit.kilocalorie())
            }
            
            completion(resultValue)
        }
        
        healthStore.execute(query)
    }

}
