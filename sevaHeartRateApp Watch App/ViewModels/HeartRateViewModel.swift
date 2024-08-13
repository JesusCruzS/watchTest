//
//  HeartRateViewModel.swift
//  sevaHeartRateApp Watch App
//
//  Created by Jesus Cruz Suárez on 6/08/24.
//

import Foundation
import HealthKit
import WatchConnectivity
import CoreMotion

class HeartRateViewModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published var heartRateModel: Double = 0
    @Published var heartRateData: HeartRateDataModel = HeartRateDataModel()
    
    private let motionActivityManager = CMMotionActivityManager()
    private var isUserMoving: Bool = false
    private var heartRateQueryTimer: Timer?
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        
        startMonitoringMotionActivity()
        executeHeartRateQuery()
    }
    
    func fetchAndSendAllHeartRateData() {
        let group = DispatchGroup()
        
        group.enter()
        HeartRateManager.shared.getRestingHeartRate { restingHeartRate in
            self.heartRateData.restingHeartRate = restingHeartRate
            group.leave()
        }
        
        group.enter()
        HeartRateManager.shared.getWalkingHeartRateAverage { walkingHeartRateAverage in
            self.heartRateData.walkingHeartRateAverage = walkingHeartRateAverage
            group.leave()
        }
        
        group.enter()
        HeartRateManager.shared.getHeartRateRange { minHeartRate, maxHeartRate in
            self.heartRateData.minHeartRate = minHeartRate
            self.heartRateData.maxHeartRate = maxHeartRate
            group.leave()
        }
        
        group.enter()
        HeartRateManager.shared.getHighHeartRateNotification { highHeartRateSamples in
            self.heartRateData.highHeartRateNotificationsCount = highHeartRateSamples?.count ?? 0
            group.leave()
        }
        
        group.enter()
        HeartRateManager.shared.getLowHeartRateNotification { lowHeartRateSamples in
            self.heartRateData.lowHeartRateNotificationsCount = lowHeartRateSamples?.count ?? 0
            group.leave()
        }
        
        group.enter()
        HeartRateManager.shared.getWorkoutHeartRate { workoutHeartRateSamples in
            self.heartRateData.workoutHeartRateSamplesCount = workoutHeartRateSamples?.count ?? 0
            group.leave()
        }
        
        group.enter()
        HeartRateManager.shared.getSleepHeartRate { sleepHeartRateSamples in
            self.heartRateData.sleepHeartRateSamplesCount = sleepHeartRateSamples?.count ?? 0
            group.leave()
        }
        
        group.enter()
        HeartRateManager.shared.getBreatheSessionHeartRate { breatheSessionHeartRateSamples in
            self.heartRateData.breatheSessionHeartRateSamplesCount = breatheSessionHeartRateSamples?.count ?? 0
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.sendHeartRateDataToPhone()
        }
    }
    
    private func sendHeartRateDataToPhone() {
        if WCSession.default.isReachable {
            let dataToSend: [String: Any] = [
                "restingHeartRate": heartRateData.restingHeartRate ?? 0.0,
                "walkingHeartRateAverage": heartRateData.walkingHeartRateAverage ?? 0.0,
                "minHeartRate": heartRateData.minHeartRate ?? 0.0,
                "maxHeartRate": heartRateData.maxHeartRate ?? 0.0,
                "highHeartRateNotifications": heartRateData.highHeartRateNotificationsCount ?? 0,
                "lowHeartRateNotifications": heartRateData.lowHeartRateNotificationsCount ?? 0,
                "workoutHeartRateSamples": heartRateData.workoutHeartRateSamplesCount ?? 0,
                "sleepHeartRateSamples": heartRateData.sleepHeartRateSamplesCount ?? 0,
                "breatheSessionHeartRateSamples": heartRateData.breatheSessionHeartRateSamplesCount ?? 0
            ]
            
            WCSession.default.sendMessage(dataToSend, replyHandler: nil, errorHandler: { error in
                print("Error sending message: \(error)")
            })
        }
    }
    
    func startHeartRateQuery() {
        scheduleHeartRateQuery()
    }
    
    func startMonitoringMotionActivity() {
        guard CMMotionActivityManager.isActivityAvailable() else { return }
        
        motionActivityManager.startActivityUpdates(to: OperationQueue.main) { [weak self] activity in
            guard let self = self else { return }
            
            if let activity = activity {
                self.isUserMoving = activity.walking || activity.running || activity.cycling || activity.automotive
                self.scheduleHeartRateQuery()
            }
        }
    }
    
    private func scheduleHeartRateQuery() {
        heartRateQueryTimer?.invalidate()
        
        let interval: TimeInterval = isUserMoving ? 10.0 : 600.0
        
        heartRateQueryTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.executeHeartRateQuery()
        }
    }
    
    func executeHeartRateQuery() {
        HeartRateManager.shared.startHeartRateQuery { [weak self] samples in
            self?.process(samples)
        }
    }
    
    private func process(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else {
            return
        }
        
        DispatchQueue.main.async {
            let heartRate = samples.last?.quantity.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0.0
            self.heartRateModel = heartRate
            self.sendHeartRateToPhone(heartRate)
            self.fetchAndSendAllHeartRateData()
        }
    }
    
    private func sendHeartRateToPhone(_ heartRate: Double) {
        if WCSession.default.isReachable {
            let message = ["heartRate": heartRate]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("Error sending message: \(error)")
            })
        }
    }
    
    // No need for scheduleBackgroundRefresh in WatchKit apps
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
