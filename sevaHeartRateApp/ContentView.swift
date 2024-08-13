//
//  ContentView.swift
//  sevaHeartRateApp
//
//  Created by Jesus Cruz Suárez on 6/08/24.
//

import SwiftUI
import WatchConnectivity

struct HeartRateDataModel {
    var heartRate: Double = 0.0
    var restingHeartRate: Double?
    var walkingHeartRateAverage: Double?
    var minHeartRate: Double?
    var maxHeartRate: Double?
    var highHeartRateNotifications: Int = 0
    var lowHeartRateNotifications: Int = 0
    var workoutHeartRate: [Double] = []
    var sleepHeartRate: [Double] = []
    var breatheSessionHeartRate: [Double] = []

    mutating func update(from dictionary: [String: Any]) {
        if let heartRate = dictionary["heartRate"] as? Double {
            self.heartRate = heartRate
        }
        if let restingHeartRate = dictionary["restingHeartRate"] as? Double {
            self.restingHeartRate = restingHeartRate
        }
        if let walkingHeartRateAverage = dictionary["walkingHeartRateAverage"] as? Double {
            self.walkingHeartRateAverage = walkingHeartRateAverage
        }
        if let minHeartRate = dictionary["minHeartRate"] as? Double {
            self.minHeartRate = minHeartRate
        }
        if let maxHeartRate = dictionary["maxHeartRate"] as? Double {
            self.maxHeartRate = maxHeartRate
        }
        if let highHeartRateNotifications = dictionary["highHeartRateNotifications"] as? Int {
            self.highHeartRateNotifications = highHeartRateNotifications
        }
        if let lowHeartRateNotifications = dictionary["lowHeartRateNotifications"] as? Int {
            self.lowHeartRateNotifications = lowHeartRateNotifications
        }
        if let workoutHeartRate = dictionary["workoutHeartRate"] as? [Double] {
            self.workoutHeartRate = workoutHeartRate
        }
        if let sleepHeartRate = dictionary["sleepHeartRate"] as? [Double] {
            self.sleepHeartRate = sleepHeartRate
        }
        if let breatheSessionHeartRate = dictionary["breatheSessionHeartRate"] as? [Double] {
            self.breatheSessionHeartRate = breatheSessionHeartRate
        }
    }
}


class PhoneViewModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published var heartRateData = HeartRateDataModel()
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.heartRateData.update(from: message)
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
}


struct ContentView: View {
    @StateObject private var phoneViewModel = PhoneViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Current Heart Rate: \(phoneViewModel.heartRateData.heartRate, specifier: "%.1f") BPM")
                .font(.largeTitle)
                .padding()
            
            Text("Resting Heart Rate: \(phoneViewModel.heartRateData.restingHeartRate ?? 0, specifier: "%.1f") BPM")
                .font(.headline)
            
            Text("Walking Heart Rate Average: \(phoneViewModel.heartRateData.walkingHeartRateAverage ?? 0, specifier: "%.1f") BPM")
                .font(.headline)
            
            Text("Heart Rate Range: \(phoneViewModel.heartRateData.minHeartRate ?? 0, specifier: "%.1f") - \(phoneViewModel.heartRateData.maxHeartRate ?? 0, specifier: "%.1f") BPM")
                .font(.headline)
            
            Text("High Heart Rate Notifications: \(phoneViewModel.heartRateData.highHeartRateNotifications)")
                .font(.headline)
            
            Text("Low Heart Rate Notifications: \(phoneViewModel.heartRateData.lowHeartRateNotifications)")
                .font(.headline)
            
            Text("Workout Heart Rate: \(averageHeartRate(phoneViewModel.heartRateData.workoutHeartRate), specifier: "%.1f") BPM")
                .font(.headline)
            
            Text("Sleep Heart Rate: \(averageHeartRate(phoneViewModel.heartRateData.sleepHeartRate), specifier: "%.1f") BPM")
                .font(.headline)
            
            Text("Breathe Session Heart Rate: \(averageHeartRate(phoneViewModel.heartRateData.breatheSessionHeartRate), specifier: "%.1f") BPM")
                .font(.headline)
        }
        .padding()
    }
    
    private func averageHeartRate(_ heartRates: [Double]) -> Double {
        guard !heartRates.isEmpty else { return 0.0 }
        let total = heartRates.reduce(0, +)
        return total / Double(heartRates.count)
    }
}

#Preview {
    ContentView()
}
