//
//  healthvisionApp.swift
//  healthvision
//
//  Created by Tony Chen on 2026-01-17.
//

import SwiftUI
import SmartSpectraSwiftSDK

struct ContentView: View {
    @State private var isFaceMeshEnabled = true
    @ObservedObject var sdk = SmartSpectraSwiftSDK.shared
    
    init() {
        let apiKey = "oQkCjMU4z0asFsSaQeluhG9Ng94jtFi4u5ucy3E4"
        sdk.setApiKey(apiKey)
    }

    // update vitals on the terminal
    private func updateVitals() {
        if let metrics = sdk.metricsBuffer{

            // pulse
            metrics.pulse.rate.forEach {
                measurement in print("Pulse: \(measurement.value) BPM at \(measurement.time)")
            }

            // breathing rate
            metrics.breathing.rate.forEach {
                measurement in print("Breathing: \(measurement.value) BPM at \(measurement.time)")
            }

            // used to determine stability or irregularity of breathing 
            metrics.breathing.inhaleExhaleRatio.forEach {
                measurement in print("Inhale exhale ratio: \(measurement.value)" )
            }

            // determines if face is present
            metrics.hasFace.forEach {
                measurement in print("Face present: \(measurement.value)")
            }

            metrics.face.blinking.forEach {
                measurement in print("Blinking: \(measurement.detected) at \(measurement.time)")
            }
        }
    }
    
    var body: some View {
        ZStack{
            SmartSpectraView()

            // face mesh display
            if let edgeMetrics = sdk.edgeMetrics,
                edgeMetrics.hasFace && !edgeMetrics.face.landmarks.isEmpty && isFaceMeshEnabled {
                // Visual representation of mesh points from edge metrics
                if let latestLandmarks = edgeMetrics.face.landmarks.last {
                    GeometryReader { geometry in
                        ZStack {
                            ForEach(Array(latestLandmarks.value.enumerated()), id: \.offset) { index, landmark in
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 3, height: 3)
                                    .position(x: CGFloat(landmark.x) * geometry.size.width / 1280.0,
                                            y: CGFloat(landmark.y) * geometry.size.height / 1280.0)
                            }
                        }
                    }
                    .frame(width: 400, height: 400) // Adjust the height as needed
                }
            }
        }
/*
    VStack(alignment: .leading, spacing: 10) {
        HStack {
            Text("healthvision")
                .font(.headline)
            Spacer()
            Toggle("Face Mesh", isOn: $isFaceMeshEnabled)
                .labelsHidden()
        }

        metricRow(title: "Pulse", value: pulseBpm, unit: "BPM")
        metricRow(title: "Breathing", value: breathingBpm, unit: "BPM")
    }
*/
    // display charts on the UI
    ScrollView{
        VStack{
            if let metrics = sdk.metricsBuffer{
                let pulse = metrics.pulse
                let breathing = metrics.breathing
                let bloodPressure = metrics.bloodPressure
                let face = metrics.face

                Section("Breathing"){
                    if !breathing.rate.isEmpty {
                        LineChartView(orderedPairs: breathing.rate.map { ($0.time, $0.value) }, title: "Breathing Rates", xLabel: "Time", yLabel: "Value", showYTicks: true)
                        LineChartView(orderedPairs: breathing.rate.map { ($0.time, $0.confidence) }, title: "Breathing Rate Confidence", xLabel: "Time", yLabel: "Value", showYTicks: true)
                    }
                    if !breathing.inhaleExhaleRatio.isEmpty {
                        LineChartView(orderedPairs: breathing.inhaleExhaleRatio.map { ($0.time, $0.value) }, title: "Inhale-Exhale Ratio", xLabel: "Time", yLabel: "Value", showYTicks: true)
                    }
                }

                Section("Face"){
                    if !face.blinking.isEmpty {
                        LineChartView(orderedPairs: face.blinking.map { ($0.time, $0.detected ? 1.0 : 0.0) }, title: "Blinking", xLabel: "Time", yLabel: "Value", showYTicks: true)
                    }
                }
            }
        }
    }
}
}

@main
struct healthvisionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
