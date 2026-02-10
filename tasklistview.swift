//
//  TaskListView.swift
//  SmartTask
//
//  Mockup 2 - Task List Screen - iOS 13+ Compatible
//

import SwiftUI

struct TaskListView: View {
    @State private var selectedFilter: TaskFilter = .all
    @State private var showingAddTask: Bool = false
    @State private var tasks: [TaskItem] = TaskItem.sampleTasks
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case important = "Important"
    }
    
    var filteredTasks: [TaskItem] {
        switch selectedFilter {
        case .all:
            return tasks
        case .today:
            return tasks.filter { Calendar.current.isDateInToday($0.dueDate) }
        case .important:
            return tasks.filter { $0.dueDate < Date() && !$0.isCompleted }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.12)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header with filters
                    HStack(spacing: 20) {
                        ForEach(TaskFilter.allCases, id: \.self) { filter in
                            FilterButton(
                                title: filter.rawValue,
                                isSelected: self.selectedFilter == filter,
                                action: {
                                    self.selectedFilter = filter
                                }
                            )
                        }
                        Spacer()
                    }
                    .padding()
                    
                    // Task List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTasks) { task in
                                NavigationLink(destination: TaskDetailView(task: task)) {
                                    TaskCardView(task: task)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            self.showingAddTask = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitle("My Tasks", displayMode: .large)
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .padding(.bottom, 4)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2)
            }
        }
    }
}

struct TaskCardView: View {
    let task: TaskItem
    
    var statusColor: Color {
        switch task.statusColor {
        case "green": return .green
        case "red": return .red
        case "yellow": return .yellow
        default: return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(statusColor)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Status icon
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .gray)
                    
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Due date
                    Text(formatDueDate(task.dueDate))
                        .font(.system(size: 12))
                        .foregroundColor(task.dueDate < Date() && !task.isCompleted ? .red : .gray)
                }
                
                Text(task.status)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 16)
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(12)
    }
    
    func formatDueDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if date < Date() {
            return "Overdue"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
    }
}
