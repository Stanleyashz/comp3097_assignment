//
//  SmartTaskApp.swift
//  SmartTask
//
//  App entry point — injects Core Data-backed TaskStore into the environment.
//  iOS 14+ Compatible
//

import SwiftUI

@main
struct SmartTaskApp: App {

    @StateObject private var taskStore = TaskStore(persistence: .shared)

    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .environmentObject(taskStore)
        }
    }
}
