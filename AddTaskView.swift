//
//  AddTaskView.swift
//  SmartTask
//
//  Add Task — iOS 14+ Compatible
//

import SwiftUI

struct AddTaskView: View {

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskStore: TaskStore

    @State private var taskName        = ""
    @State private var taskDescription = ""
    @State private var selectedCategory = "Work"
    @State private var customCategory   = ""
    @State private var selectedPriority = "Medium"
    @State private var selectedDate     = Date()
    @State private var selectedTime     = Date()

    let categories = ["Work", "School", "Personal",
                      "Design System", "Documentation",
                      "Meetings", "Reports", "Custom"]
    let priorities = ["High", "Medium", "Low"]

    // Make TextEditor background transparent globally.
    init() {
        UITextView.appearance().backgroundColor = .clear
    }

    // MARK: - Computed

    var effectiveCategory: String {
        if selectedCategory == "Custom" {
            let trimmed = customCategory.trimmingCharacters(in: .whitespaces)
            return trimmed.isEmpty ? "Custom" : trimmed
        }
        return selectedCategory
    }

    var combinedDueDate: Date {
        let cal = Calendar.current
        let d   = cal.dateComponents([.year, .month, .day],    from: selectedDate)
        let t   = cal.dateComponents([.hour, .minute],         from: selectedTime)
        var c   = DateComponents()
        c.year = d.year; c.month  = d.month; c.day    = d.day
        c.hour = t.hour; c.minute = t.minute
        return cal.date(from: c) ?? selectedDate
    }

    var computedStatus: String {
        let due = combinedDueDate
        if due < Date() { return "Overdue" }
        let hours = Calendar.current.dateComponents([.hour], from: Date(), to: due).hour ?? 0
        return hours <= 24 ? "Due Soon" : "Not Started"
    }

    var canSave: Bool {
        !taskName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.12)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        taskNameField
                        descriptionField
                        categoryField
                        priorityField
                        dateTimeField
                        statusPreview
                        Spacer(minLength: 16)
                        saveButton
                        cancelButton
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Add New Task", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }.foregroundColor(.gray)
            )
        }
    }

    // MARK: - Field Views

    private var taskNameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("Task Name")
            TextField("e.g., Design Review Meeting", text: $taskName)
                .padding()
                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                .cornerRadius(8)
                .foregroundColor(.white)
        }
    }

    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("Description (optional)")
            ZStack(alignment: .topLeading) {
                if taskDescription.isEmpty {
                    Text("Enter task details or sub-tasks…")
                        .foregroundColor(Color.gray.opacity(0.6))
                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 0, trailing: 0))
                        .allowsHitTesting(false)
                }
                TextEditor(text: $taskDescription)
                    .frame(height: 120)
                    .padding(4)
                    .foregroundColor(.white)
                    .background(Color.clear)
            }
            .background(Color(red: 0.15, green: 0.15, blue: 0.17))
            .cornerRadius(8)
        }
    }

    private var categoryField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("Category")
            Menu {
                ForEach(categories, id: \.self) { cat in
                    Button(action: { selectedCategory = cat }) {
                        HStack {
                            Text(cat)
                            if selectedCategory == cat { Image(systemName: "checkmark") }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(effectiveCategory).foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.down").foregroundColor(.gray)
                }
                .padding()
                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                .cornerRadius(8)
            }

            if selectedCategory == "Custom" {
                TextField("Enter category name", text: $customCategory)
                    .padding()
                    .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }
        }
    }

    private var priorityField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("Priority")
            HStack(spacing: 10) {
                ForEach(priorities, id: \.self) { p in
                    let color: Color = p == "High" ? .red : p == "Medium" ? .orange : .blue
                    Button(action: { selectedPriority = p }) {
                        Text(p)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedPriority == p ? .white : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedPriority == p
                                        ? color
                                        : Color(red: 0.15, green: 0.15, blue: 0.17))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }

    private var dateTimeField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("Due Date & Time")
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "calendar").foregroundColor(.gray)
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .accentColor(.blue)
                }
                .padding()
                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                .cornerRadius(8)

                HStack {
                    Image(systemName: "clock").foregroundColor(.gray)
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .accentColor(.blue)
                }
                .padding()
                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                .cornerRadius(8)
            }
        }
    }

    private var statusPreview: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle").foregroundColor(.gray)
            Text("Status will be:")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            Text(computedStatus)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(
                    computedStatus == "Overdue"  ? .red  :
                    computedStatus == "Due Soon" ? .yellow : .blue
                )
        }
    }

    private var saveButton: some View {
        Button(action: saveTask) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Save Task").font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(canSave ? Color.blue : Color.blue.opacity(0.4))
            .cornerRadius(12)
        }
        .disabled(!canSave)
    }

    private var cancelButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Text("Cancel")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                .cornerRadius(12)
        }
    }

    // MARK: - Helpers

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.gray)
    }

    private func saveTask() {
        let newTask = TaskItem(
            title:       taskName.trimmingCharacters(in: .whitespaces),
            description: taskDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            category:    effectiveCategory,
            dueDate:     combinedDueDate,
            status:      computedStatus,
            isCompleted: false,
            priority:    selectedPriority
        )
        taskStore.addTask(newTask)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Preview

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
            .environmentObject(TaskStore(persistence: .preview))
    }
}
