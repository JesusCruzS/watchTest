//
//  HeartRateView.swift
//  sevaHeartRateApp Watch App
//
//  Created by Jesus Cruz Suárez on 6/08/24.
//

import SwiftUI

struct HeartRateView: View {
    @StateObject private var heartRateViewModel = HeartRateViewModel()
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Text(heartRateViewModel.heartRateModel == 0 ? "--" : "\(Int(heartRateViewModel.heartRateModel))")
                                    .font(.system(size: 50, weight: .medium))
                                    .frame(width: 80, height: 50, alignment: .center)
                                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("BPM")
                        .font(.system(size: 20, weight: .medium))
                        .kerning(0.5)
                        .foregroundColor(.white)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                        .frame(width: 30, height: 30)
                }
                .frame(width: 80, height: 50, alignment: .leading)
            }
            .frame(width: 160, height: 60, alignment: .center)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
    }
}

#Preview {
    HeartRateView()
}
