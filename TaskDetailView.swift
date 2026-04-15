//
//  TaskDetailView.swift
//  SmartTask
//
//  Task Detail / Edit — iOS 14+ Compatible
//

import SwiftUI
import Combine

struct TaskDetailView: View {

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskStore: TaskStore

    let taskID: UUID

    // Always reads live data from Core Data via the store.
    private var task: TaskItem? {
        taskStore.tasks.first { $0.id == taskID }
    }

    @State private var isEditing         = false
    @State private var showingDeleteAlert = false
    @State private var editTitle         = ""
    @State private var editDescription   = ""
    @State private var editPriority      = "Medium"
    @State private var editCategory      = "Work"
    @State private var editDueDate       = Date()

    let categories = ["Work", "School", "Personal",
                      "Design System", "Documentation",
                      "Meetings", "Reports", "Custom"]
    let priorities = ["High", "Medium", "Low"]

    // MARK: - Body

    var body: some View {
        Group {
            if let task = task {
                contentView(task: task)
            } else {
                // Deleted externally — dismiss immediately.
                Color(red: 0.1, green: 0.1, blue: 0.12)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear { presentationMode.wrappedValue.dismiss() }
            }
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private func contentView(task: TaskItem) -> some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.12)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        categoryBanner(task: task)
                        dueDateRow(task: task)
                        titleRow(task: task)
                        descriptionRow(task: task)
                        if isEditing { categoryPicker }
                        prioritySection(task: task)
                    }
                    Group {
                        statusToggle(task: task)
                        metadataRow(task: task)
                        Divider().background(Color.gray.opacity(0.3))
                        if isEditing {
                            updateButton(task: task)
                            cancelEditButton(task: task)
                        }
                        deleteButton
                        Spacer(minLength: 40)
                    }
                }
                .padding()
            } // ← ScrollView closes here
        } // ← ZStack closes here
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: navButtons(task: task))
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Task"),
                message: Text("This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    taskStore.deleteTask(task)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear { loadState(from: task) }
        .onReceive(taskStore.$tasks) { tasks in
            if !tasks.contains(where: { $0.id == taskID }) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    } // ← function closes here

    // MARK: - Row Views

    private func categoryBanner(task: TaskItem) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(headerColor(isEditing ? editCategory : task.category).opacity(0.25))
                .frame(height: 160)
            VStack(spacing: 8) {
                Image(systemName: categoryIcon(isEditing ? editCategory : task.category))
                    .font(.system(size: 52))
                    .foregroundColor(headerColor(isEditing ? editCategory : task.category).opacity(0.8))
                Text(isEditing ? editCategory : task.category)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(headerColor(task.category).opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }

    private func dueDateRow(task: TaskItem) -> some View {
        Group {
            if isEditing {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Due Date & Time")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    DatePicker("", selection: $editDueDate)
                        .labelsHidden()
                        .accentColor(.blue)
                        .padding()
                        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                        .cornerRadius(8)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "calendar").foregroundColor(.blue)
                    Text(formattedDate(task.dueDate))
                        .font(.system(size: 14))
                        .foregroundColor(task.dueDate < Date() && !task.isCompleted ? .red : .gray)
                }
            }
        }
    }

    private func titleRow(task: TaskItem) -> some View {
        Group {
            if isEditing {
                TextField("Task Title", text: $editTitle)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                    .cornerRadius(8)
            } else {
                Text(task.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(task.isCompleted ? Color.white.opacity(0.5) : .white)
                    .strikethrough(task.isCompleted, color: .gray)
            }
        }
    }

    private func descriptionRow(task: TaskItem) -> some View {
        Group {
            if isEditing {
                ZStack(alignment: .topLeading) {
                    if editDescription.isEmpty {
                        Text("Enter description…")
                            .foregroundColor(Color.gray.opacity(0.6))
                            .padding(EdgeInsets(top: 8, leading: 12, bottom: 0, trailing: 0))
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $editDescription)
                        .frame(minHeight: 120)
                        .padding(4)
                        .foregroundColor(.white)
                        .background(Color.clear)
                }
                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                .cornerRadius(8)
            } else {
                Text(task.description.isEmpty ? "No description provided." : task.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineSpacing(5)
            }
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Category")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
            Menu {
                ForEach(categories, id: \.self) { cat in
                    Button(action: { editCategory = cat }) {
                        HStack {
                            Text(cat)
                            if editCategory == cat { Image(systemName: "checkmark") }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(editCategory).foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.down").foregroundColor(.gray)
                }
                .padding()
                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                .cornerRadius(8)
            }
        }
    }

    private func prioritySection(task: TaskItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Priority")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            HStack(spacing: 10) {
                ForEach(priorities, id: \.self) { p in
                    let color: Color = p == "High" ? .red : p == "Medium" ? .orange : .blue
                    let selected     = isEditing ? editPriority == p : task.priority == p
                    Button(action: { if isEditing { editPriority = p } }) {
                        Text(p)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selected ? .white : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selected
                                        ? color
                                        : Color(red: 0.15, green: 0.15, blue: 0.17))
                            .cornerRadius(8)
                    }
                    .disabled(!isEditing)
                }
            }
        }
    }

    private func statusToggle(task: TaskItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Status")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            HStack {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                Text(task.isCompleted ? "Completed" : "Mark as Complete")
                    .foregroundColor(.white)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { task.isCompleted },
                    set: { _ in taskStore.toggleComplete(task) }
                ))
                .labelsHidden()
            }
            .padding()
            .background(Color(red: 0.15, green: 0.15, blue: 0.17))
            .cornerRadius(10)
        }
    }

    private func metadataRow(task: TaskItem) -> some View {
        HStack(spacing: 0) {
            metadataCell(
                label: "STATUS", value: task.status,
                color: task.status == "Overdue" ? .red : task.status == "Completed" ? .green : .blue
            )
            Spacer()
            metadataCell(
                label: "PRIORITY", value: task.priority,
                color: task.priority == "High" ? .red : task.priority == "Medium" ? .orange : .blue
            )
            Spacer()
            metadataCell(label: "CATEGORY", value: task.category, color: .gray)
        }
        .padding()
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(10)
    }

    private func metadataCell(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 10, weight: .semibold)).foregroundColor(.gray)
            Text(value).font(.system(size: 13, weight: .medium)).foregroundColor(color)
        }
    }

    private func updateButton(task: TaskItem) -> some View {
        Button(action: { saveEdits(task: task) }) {
            Text("Update Task")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(editTitle.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Color.blue.opacity(0.4) : Color.blue)
                .cornerRadius(12)
        }
        .disabled(editTitle.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    private func cancelEditButton(task: TaskItem) -> some View {
        Button(action: { cancelEdit(task: task) }) {
            Text("Cancel Edit")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                .cornerRadius(12)
        }
    }

    private var deleteButton: some View {
        Button(action: { showingDeleteAlert = true }) {
            HStack {
                Image(systemName: "trash")
                Text("Delete Task").font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 0.15, green: 0.15, blue: 0.17))
            .cornerRadius(12)
        }
    }

    private func navButtons(task: TaskItem) -> some View {
        HStack(spacing: 16) {
            Button(action: {
                if isEditing { saveEdits(task: task) }
                else         { beginEdit(task: task) }
            }) {
                Image(systemName: isEditing ? "checkmark" : "pencil")
                    .foregroundColor(.blue)
            }
            if !isEditing {
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash").foregroundColor(.red)
                }
            }
        }
    }

    // MARK: - State Management

    private func beginEdit(task: TaskItem) {
        loadState(from: task)
        isEditing = true
    }

    private func cancelEdit(task: TaskItem) {
        loadState(from: task)
        isEditing = false
    }

    private func loadState(from task: TaskItem) {
        editTitle       = task.title
        editDescription = task.description
        editPriority    = task.priority
        editCategory    = task.category
        editDueDate     = task.dueDate
    }

    private func saveEdits(task: TaskItem) {
        var updated         = task
        updated.title       = editTitle.trimmingCharacters(in: .whitespaces)
        updated.description = editDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.priority    = editPriority
        updated.category    = editCategory
        updated.dueDate     = editDueDate
        if !task.isCompleted {
            updated.status  = computeStatus(for: editDueDate)
        }
        taskStore.updateTask(updated)
        isEditing = false
    }

    // MARK: - Helpers

    private func computeStatus(for date: Date) -> String {
        if date < Date() { return "Overdue" }
        let hours = Calendar.current.dateComponents([.hour], from: Date(), to: date).hour ?? 0
        return hours <= 24 ? "Due Soon" : "In Progress"
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        return "Due: \(f.string(from: date))"
    }

    private func headerColor(_ category: String) -> Color {
        switch category {
        case "Work":          return .orange
        case "School":        return .indigo
        case "Personal":      return .pink
        case "Design System": return .purple
        case "Documentation": return .teal
        case "Meetings":      return .blue
        case "Reports":       return .green
        default:              return .orange
        }
    }

    private func categoryIcon(_ category: String) -> String {
        switch category {
        case "Work":          return "briefcase.fill"
        case "School":        return "book.fill"
        case "Personal":      return "person.fill"
        case "Design System": return "paintbrush.fill"
        case "Documentation": return "doc.text.fill"
        case "Meetings":      return "person.3.fill"
        case "Reports":       return "chart.bar.fill"
        default:              return "folder.fill"
        }
    }
}

// MARK: - Preview

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let store = TaskStore(persistence: .preview)
        NavigationView {
            TaskDetailView(taskID: store.tasks[0].id)
                .environmentObject(store)
        }
    }
}
