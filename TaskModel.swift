//
//  TaskModel.swift
//  SmartTask
//
//  Simple data model - iOS 13+ Compatible
//

import Foundation

struct TaskItem: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var category: String
    var dueDate: Date
    var status: String
    var isCompleted: Bool
    
    var statusColor: String {
        if isCompleted {
            return "green"
        } else if dueDate < Date() {
            return "red"
        } else if hoursUntilDue <= 24 {
            return "yellow"
        } else {
            return "blue"
        }
    }
    
    var hoursUntilDue: Int {
        let hours = Calendar.current.dateComponents([.hour], from: Date(), to: dueDate).hour ?? 0
        return hours
    }
}

// Sample data for mockup
extension TaskItem {
    static let sampleTasks: [TaskItem] = [
        TaskItem(
            title: "Design system audit",
            description: "Review and update the design system",
            category: "Design System",
            dueDate: Date(),
            status: "In Progress",
            isCompleted: false
        ),
        TaskItem(
            title: "Update documentation",
            description: "Update project documentation",
            category: "Documentation",
            dueDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            status: "Completed",
            isCompleted: true
        ),
        TaskItem(
            title: "Client presentation",
            description: "Prepare slides for client meeting",
            category: "Work",
            dueDate: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
            status: "Overdue",
            isCompleted: false
        ),
        TaskItem(
            title: "Team sync meeting",
            description: "Weekly team sync",
            category: "Meetings",
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            status: "Pending",
            isCompleted: false
        ),
        TaskItem(
            title: "Prepare monthly report",
            description: "Compile monthly analytics report",
            category: "Reports",
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            status: "Not Started",
            isCompleted: false
        )
    ]
}
