//
//  TaskStore.swift
//  SmartTask
//
//  Observable task store backed by Core Data — iOS 14+ Compatible
//

import Foundation
import Combine
import UserNotifications

class TaskStore: ObservableObject {

    @Published var tasks: [TaskItem] = []

    private let persistence: PersistenceController

    // MARK: - Init

    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
        loadTasks()
        requestNotificationPermission()
    }

    // MARK: - Load

    /// Reads all rows from Core Data and refreshes the published array.
    func loadTasks() {
        let entities = persistence.fetchAll()
        if entities.isEmpty {
            seedSampleData()
        } else {
            tasks = entities.map { $0.toTaskItem() }
        }
    }

    // MARK: - CRUD

    func addTask(_ task: TaskItem) {
        persistence.createEntity(from: task)
        persistence.save()
        tasks.append(task)
        scheduleNotification(for: task)
    }

    func updateTask(_ task: TaskItem) {
        guard let entity = persistence.fetchEntity(id: task.id) else { return }
        cancelNotification(for: task)
        entity.populate(from: task)
        persistence.save()
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
        scheduleNotification(for: task)
    }

    func deleteTask(_ task: TaskItem) {
        if let entity = persistence.fetchEntity(id: task.id) {
            persistence.context.delete(entity)
            persistence.save()
        }
        tasks.removeAll { $0.id == task.id }
        cancelNotification(for: task)
    }

    func toggleComplete(_ task: TaskItem) {
        var updated = task
        updated.isCompleted.toggle()
        updated.status = updated.isCompleted ? "Completed" : "In Progress"
        updateTask(updated)
    }

    // MARK: - Sample Data Seed

    /// Inserts sample tasks on first launch (empty store).
    private func seedSampleData() {
        TaskItem.sampleTasks.forEach { persistence.createEntity(from: $0) }
        persistence.save()
        tasks = persistence.fetchAll().map { $0.toTaskItem() }
    }

    // MARK: - Stats

    var completedCount: Int          { tasks.filter { $0.isCompleted }.count }
    var pendingCount: Int            { tasks.filter { !$0.isCompleted }.count }
    var overdueCount: Int            { tasks.filter { !$0.isCompleted && $0.dueDate < Date() }.count }
    var highPriorityPendingCount: Int { tasks.filter { $0.priority == "High" && !$0.isCompleted }.count }

    var categoryBreakdown: [(category: String, count: Int)] {
        let grouped = Dictionary(grouping: tasks) { $0.category }
        return grouped.map { (category: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleNotification(for task: TaskItem) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
        guard !task.isCompleted, task.dueDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Due: \(task.title)"
        content.body  = task.description.isEmpty ? "Time to complete this task!" : task.description
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: task.dueDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: task.id.uuidString, content: content, trigger: trigger
        )
        center.add(request)
    }

    func cancelNotification(for task: TaskItem) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
}
