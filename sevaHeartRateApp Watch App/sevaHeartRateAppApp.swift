//
//  sevaHeartRateAppApp.swift
//  sevaHeartRateApp Watch App
//
//  Created by Jesus Cruz Suárez on 6/08/24.
//

import SwiftUI

@main
struct sevaHeartRateApp_Watch_AppApp: App {
    @StateObject private var heartRateViewModel = HeartRateViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .backgroundTask(.appRefresh("WEATHER_DATA")) {
            await heartRateViewModel.startMonitoringMotionActivity()
            await heartRateViewModel.executeHeartRateQuery()
        }
    }
}
