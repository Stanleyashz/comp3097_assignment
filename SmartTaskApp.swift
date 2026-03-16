//
//  SmartTaskApp.swift
//  SmartTask
//
//  Main App Entry Point - iOS 13+ Compatible
//

import SwiftUI

@main
struct SmartTaskApp: App {
    @StateObject private var taskStore = TaskStore()

    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .environmentObject(taskStore)
        }
    }
}
