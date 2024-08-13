//
//  HeartRateManager.swift
//  sevaHeartRateApp Watch App
//
//  Created by Jesus Cruz Suárez on 6/08/24.
//

import Foundation
import HealthKit

class HeartRateManager {
    static let shared = HeartRateManager()
    private let healthStore = HKHealthStore()
    private let heartRateUnit = HKUnit(from: "count/min")
    
    private func getHeartRateData(typeIdentifier: HKQuantityTypeIdentifier, options: HKStatisticsOptions, completion: @escaping (Double?) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: typeIdentifier) else {
            completion(nil)
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: options) { _, result, error in
            guard let result = result, let quantity = result.mostRecentQuantity() else {
                completion(nil)
                return
            }
            let value = quantity.doubleValue(for: self.heartRateUnit)
            completion(value)
        }
        healthStore.execute(query)
    }
    
    func startHeartRateQuery(completion: @escaping ([HKSample]?) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, newAnchor, error) in
            completion(samples)
        }
        
        query.updateHandler = { (query, samples, deletedObjects, newAnchor, error) in
            completion(samples)
        }
        
        healthStore.execute(query)
    }
    
    func getRestingHeartRate(completion: @escaping (Double?) -> Void) {
        getHeartRateData(typeIdentifier: .restingHeartRate, options: .mostRecent, completion: completion)
    }
    
    func getWalkingHeartRateAverage(completion: @escaping (Double?) -> Void) {
        getHeartRateData(typeIdentifier: .walkingHeartRateAverage, options: .mostRecent, completion: completion)
    }
    
    func getHeartRateRange(completion: @escaping (Double?, Double?) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil, nil)
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: [.discreteMin, .discreteMax]) { _, result, error in
            guard let result = result else {
                completion(nil, nil)
                return
            }
            let minHeartRate = result.minimumQuantity()?.doubleValue(for: self.heartRateUnit)
            let maxHeartRate = result.maximumQuantity()?.doubleValue(for: self.heartRateUnit)
            completion(minHeartRate, maxHeartRate)
        }
        healthStore.execute(query)
    }
    
    private func getCategorySamples(for identifier: HKCategoryTypeIdentifier, completion: @escaping ([HKSample]?) -> Void) {
        guard let categoryType = HKObjectType.categoryType(forIdentifier: identifier) else {
            completion(nil)
            return
        }
        
        let query = HKSampleQuery(sampleType: categoryType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            completion(samples)
        }
        
        healthStore.execute(query)
    }
    
    func getHighHeartRateNotification(completion: @escaping ([HKSample]?) -> Void) {
        getCategorySamples(for: .highHeartRateEvent, completion: completion)
    }
    
    func getLowHeartRateNotification(completion: @escaping ([HKSample]?) -> Void) {
        getCategorySamples(for: .lowHeartRateEvent, completion: completion)
    }
    
    func getWorkoutHeartRate(completion: @escaping ([HKSample]?) -> Void) {
        guard let workoutHeartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }
        
        let workoutPredicate = HKQuery.predicateForObjects(from: HKSource.default())
        
        let query = HKSampleQuery(sampleType: workoutHeartRateType, predicate: workoutPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            completion(samples)
        }
        
        healthStore.execute(query)
    }
    
    func getSleepHeartRate(completion: @escaping ([HKSample]?) -> Void) {
        guard let sleepHeartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepHeartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            completion(samples)
        }
        
        healthStore.execute(query)
    }
    
    func getBreatheSessionHeartRate(completion: @escaping ([HKSample]?) -> Void) {
        guard let breatheSessionHeartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: breatheSessionHeartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            completion(samples)
        }
        
        healthStore.execute(query)
    }
}
