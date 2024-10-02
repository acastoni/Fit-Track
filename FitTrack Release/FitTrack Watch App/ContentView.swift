//
//  ContentView.swift
//  FitTrack
//
//  Created by Anthony Castillo
//

import SwiftUI

struct ContentView: View {
    @State private var selectedExercise: CustomWorkoutType = .general
    @State private var isWorkoutStarted = false
    @State private var workoutSummary: WorkoutSummary?
    @State private var showWorkoutHistory = false
    @State private var workoutSummaries: [WorkoutSummary] = []

    var body: some View {
        VStack {
            if showWorkoutHistory {
                WorkoutHistoryView(summaries: workoutSummaries) {
                    showWorkoutHistory = false
                    workoutSummary = nil
                }
            } else if let summary = workoutSummary {
                SummaryView(summary: summary) {
                    workoutSummaries.append(summary)
                    workoutSummary = nil
                    showWorkoutHistory = true
                }
            } else if isWorkoutStarted {
                WorkoutView(exerciseType: selectedExercise, isWorkoutStarted: $isWorkoutStarted) { summary in
                    workoutSummary = summary
                    isWorkoutStarted = false
                }
            } else {
                VStack {
                    Picker("Select Exercise", selection: $selectedExercise) {
                        Text("Bench Press").tag(CustomWorkoutType.benchPress)
                        Text("Pull Ups").tag(CustomWorkoutType.pullUps)
                        Text("General").tag(CustomWorkoutType.general)
                    }
                    .pickerStyle(WheelPickerStyle())
                    .padding()
                    .foregroundColor(.white)

                    Button("Start Workout") {
                        isWorkoutStarted = true
                    }
                    .padding()
                    .foregroundColor(Color.white)
                    .clipShape(Capsule())
                }
                .padding()
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
