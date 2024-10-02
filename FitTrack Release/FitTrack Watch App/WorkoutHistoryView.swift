//
//  WorkoutHistoryView.swift
//  FitTrack
//
//  Created by Anthony Castillo
//

import SwiftUI

public struct WorkoutHistoryView: View {
    public var summaries: [WorkoutSummary]
    public var onDone: () -> Void
    
    public var body: some View {

            ScrollView {
                ForEach(summaries, id: \.timestamp) { summary in
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Date: \(formattedDate(from: summary.timestamp))")
                        Text("Exercise: \(summary.exerciseType.rawValue)")
                        Text("Duration: \(formattedDuration(from: summary.duration))")
                        Text("Calories: \(summary.caloriesBurned) cal")
                        Text("Repetitions: \(summary.repetitions)")
                    }
                    
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                    .padding(.bottom, 5)
                }
                Button("Done") {
                    onDone()
                }
            }

            .padding()
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom)
        }

    
    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formattedDuration(from duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
