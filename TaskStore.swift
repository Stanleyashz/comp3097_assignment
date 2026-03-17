//
//  TaskStore.swift
//  SmartTask
//
//  Persistent task store using UserDefaults - iOS 13+ Compatible
//

import Foundation
import Combine

class TaskStore: ObservableObject {
    @Published var tasks: [TaskItem] {
        didSet { persist() }
    }

    private let storageKey = "taskflow_tasks"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([TaskItem].self, from: data) {
            tasks = saved
        } else {
            tasks = TaskItem.sampleTasks
        }
    }

    func addTask(_ task: TaskItem) {
        tasks.append(task)
    }

    func updateTask(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
    }

    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
