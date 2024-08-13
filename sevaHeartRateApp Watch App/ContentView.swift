//
//  ContentView.swift
//  sevaHeartRateApp Watch App
//
//  Created by Jesus Cruz Suárez on 6/08/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some View {
        if healthKitManager.isAuthorized {
            HeartRateView()
        } else {
            Text("Requesting Health Data Access...")
                .onAppear {
                    healthKitManager.requestAuthorization()
                }
        }
    }
}

#Preview {
    ContentView()
}
