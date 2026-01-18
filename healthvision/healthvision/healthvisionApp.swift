//
//  healthvisionApp.swift
//  healthvision
//
//  Created by Tony Chen on 2026-01-17.
//

import SwiftUI
import SmartSpectraSwiftSDK

struct ContentView: View {
    @ObservedObject var sdk = SmartSpectraSwiftSDK.shared
    
    init() {
        let apiKey = "oQkCjMU4z0asFsSaQeluhG9Ng94jtFi4u5ucy3E4"
        sdk.setApiKey(apiKey)
    }
    
    var body: some View {
        SmartSpectraView()
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
