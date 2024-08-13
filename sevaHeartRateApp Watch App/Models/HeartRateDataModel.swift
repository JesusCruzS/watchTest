//
//  HeartRateData.swift
//  sevaHeartRateApp Watch App
//
//  Created by Jesus Cruz Suárez on 9/08/24.
//

struct HeartRateDataModel: Codable {
    var restingHeartRate: Double?
    var walkingHeartRateAverage: Double?
    var minHeartRate: Double?
    var maxHeartRate: Double?
    var highHeartRateNotificationsCount: Int?
    var lowHeartRateNotificationsCount: Int?
    var workoutHeartRateSamplesCount: Int?
    var sleepHeartRateSamplesCount: Int?
    var breatheSessionHeartRateSamplesCount: Int?
}
