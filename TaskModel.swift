//
//  TaskModel.swift
//  SmartTask
//
//  Data model - iOS 13+ Compatible
//

import Foundation

struct TaskItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var category: String
    var dueDate: Date
    var status: String
    var isCompleted: Bool
    var priority: String // "High", "Medium", "Low"

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: String,
        dueDate: Date,
        status: String,
        isCompleted: Bool,
        priority: String = "Medium"
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.dueDate = dueDate
        self.status = status
        self.isCompleted = isCompleted
        self.priority = priority
    }

    var statusColor: String {
        if isCompleted { return "green" }
        else if dueDate < Date() { return "red" }
        else if hoursUntilDue <= 24 { return "yellow" }
        else { return "blue" }
    }

    var hoursUntilDue: Int {
        Calendar.current.dateComponents([.hour], from: Date(), to: dueDate).hour ?? 0
    }
}

extension TaskItem {
    static let sampleTasks: [TaskItem] = [
        TaskItem(
            title: "Design system audit",
            description: "Review and update the design system",
            category: "Design System",
            dueDate: Date(),
            status: "In Progress",
            isCompleted: false,
            priority: "High"
        ),
        TaskItem(
            title: "Update documentation",
            description: "Update project documentation",
            category: "Documentation",
            dueDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            status: "Completed",
            isCompleted: true,
            priority: "Low"
        ),
        TaskItem(
            title: "Client presentation",
            description: "Prepare slides for client meeting",
            category: "Work",
            dueDate: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
            status: "Overdue",
            isCompleted: false,
            priority: "High"
        ),
        TaskItem(
            title: "Team sync meeting",
            description: "Weekly team sync",
            category: "Meetings",
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            status: "Pending",
            isCompleted: false,
            priority: "Medium"
        ),
        TaskItem(
            title: "Prepare monthly report",
            description: "Compile monthly analytics report",
            category: "Reports",
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            status: "Not Started",
            isCompleted: false,
            priority: "Low"
        )
    ]
}
