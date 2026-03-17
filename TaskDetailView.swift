//
//  TaskDetailView.swift
//  SmartTask
//
//  Task Details Screen - iOS 13+ Compatible
//

import SwiftUI

struct TaskDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskStore: TaskStore

    let task: TaskItem

    @State private var isEditing: Bool = false
    @State private var showingDeleteAlert: Bool = false
    @State private var isCompleted: Bool = false
    @State private var editTitle: String = ""
    @State private var editDescription: String = ""
    @State private var editPriority: String = "Medium"

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.12)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(headerColor.opacity(0.3))
                            .frame(height: 200)
                        VStack(spacing: 8) {
                            Image(systemName: categoryIcon)
                                .font(.system(size: 60))
                                .foregroundColor(Color.white.opacity(0.5))
                            Text(task.category)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                    }

                    // Due Date
                    HStack {
                        Image(systemName: "calendar").foregroundColor(.blue)
                        Text("Due: \(formattedDate(task.dueDate))")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }

                    // Title
                    if isEditing {
                        TextField("Task Title", text: $editTitle)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                            .cornerRadius(8)
                    } else {
                        Text(task.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .strikethrough(isCompleted, color: .gray)
                    }

                    // Description
                    if isEditing {
                        TextEditor(text: $editDescription)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    } else {
                        Text(task.description.isEmpty ? "No description." : task.description)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                    }

                    // Priority Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Priority")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        HStack(spacing: 12) {
                            ForEach(["High", "Medium", "Low"], id: \.self) { p in
                                Button(action: {
                                    if isEditing { editPriority = p }
                                }) {
                                    let color: Color = p == "High" ? .red : p == "Medium" ? .orange : .blue
                                    let selected = isEditing ? editPriority == p : task.priority == p
                                    Text(p)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selected ? .white : .gray)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selected ? color : Color(red: 0.15, green: 0.15, blue: 0.17))
                                        .cornerRadius(8)
                                }
                                .disabled(!isEditing)
                            }
                        }
                    }

                    // Status Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Status")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        HStack {
                            Image(systemName: "checkmark.circle").foregroundColor(.blue)
                            Text("Mark as Complete").foregroundColor(.white)
                            Spacer()
                            Toggle("", isOn: $isCompleted)
                                .labelsHidden()
                                .onChange(of: isCompleted) { newValue in
                                    var updated = task
                                    updated.isCompleted = newValue
                                    updated.status = newValue ? "Completed" : "In Progress"
                                    taskStore.updateTask(updated)
                                }
                        }
                        .padding()
                        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                        .cornerRadius(8)
                    }

                    // Metadata
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("STATUS")
                                .font(.system(size: 10)).foregroundColor(.gray)
                            Text(task.status)
                                .font(.system(size: 14)).foregroundColor(.white)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CATEGORY")
                                .font(.system(size: 10)).foregroundColor(.gray)
                            Text(task.category)
                                .font(.system(size: 14)).foregroundColor(.white)
                        }
                    }
                    .padding(.vertical)

                    // Update Button (when editing)
                    if isEditing {
                        Button(action: saveEdits) {
                            Text("Update Changes")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(editTitle.isEmpty ? Color.blue.opacity(0.5) : Color.blue)
                                .cornerRadius(12)
                        }
                        .disabled(editTitle.isEmpty)
                    }

                    // Delete Button
                    Button(action: { self.showingDeleteAlert = true }) {
                        Text("Delete Task")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(
            trailing: HStack(spacing: 16) {
                Button(action: {
                    if isEditing {
                        saveEdits()
                    } else {
                        editTitle = task.title
                        editDescription = task.description
                        editPriority = task.priority
                        isEditing = true
                    }
                }) {
                    Image(systemName: isEditing ? "checkmark" : "pencil")
                        .foregroundColor(.blue)
                }
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash").foregroundColor(.red)
                }
            }
        )
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Task"),
                message: Text("Are you sure you want to delete this task? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    taskStore.deleteTask(self.task)
                    self.presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            isCompleted = task.isCompleted
            editTitle = task.title
            editDescription = task.description
            editPriority = task.priority
        }
    }

    private func saveEdits() {
        var updated = task
        updated.title = editTitle
        updated.description = editDescription
        updated.priority = editPriority
        updated.isCompleted = isCompleted
        updated.status = isCompleted ? "Completed" : task.status
        taskStore.updateTask(updated)
        isEditing = false
    }

    private var headerColor: Color {
        switch task.category {
        case "Work":          return .orange
        case "Design System": return .purple
        case "Documentation": return .teal
        case "Meetings":      return .blue
        case "Reports":       return .green
        default:              return .orange
        }
    }

    private var categoryIcon: String {
        switch task.category {
        case "Work":          return "briefcase"
        case "Design System": return "paintbrush"
        case "Documentation": return "doc.text"
        case "Meetings":      return "person.3"
        case "Reports":       return "chart.bar"
        default:              return "folder"
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
}

struct PriorityButton: View {
    let title: String
    let isSelected: Bool
    let color: Color

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color(red: 0.15, green: 0.15, blue: 0.17))
            .cornerRadius(8)
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TaskDetailView(task: TaskItem.sampleTasks[0])
                .environmentObject(TaskStore())
        }
    }
}
