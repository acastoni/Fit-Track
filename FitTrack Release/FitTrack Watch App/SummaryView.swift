//
//  SummaryView.swift
//  FitTrack
//
//  Created by Anthony Castillo
//


import SwiftUI

public struct SummaryView: View {
    public var summary: WorkoutSummary
    public var onShowHistory: () -> Void

    public var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Workout Summary")
                    .font(.subheadline)
                    .padding(.top)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(summary.heartRate, specifier: "%.1f") bpm")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }

                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(summary.caloriesBurned) cal")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }

                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                        Text("\(formattedDuration(from: summary.duration))")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }

                    HStack {
                        Image(systemName: "repeat")
                            .foregroundColor(.green)
                        Text("\(summary.repetitions)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                .padding()

                Spacer()

                Button("Done") {
                    onShowHistory()
                }
                .padding()
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom)
            }
            .padding()
        }
    }

    private func formattedDuration(from duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension WorkoutSummary {
    static var sample: WorkoutSummary {
        WorkoutSummary(
            exerciseType: .benchPress,
            heartRate: 120.0,
            caloriesBurned: 200,
            duration: 1800,
            repetitions: 15
        )
    }
}
