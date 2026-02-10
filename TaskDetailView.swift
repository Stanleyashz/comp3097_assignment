//
//  TaskDetailView.swift
//  SmartTask
//
//  Mockup 4 - Task Details Screen - iOS 13+ Compatible
//

import SwiftUI

struct TaskDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let task: TaskItem
    
    @State private var isEditing: Bool = false
    @State private var showingDeleteAlert: Bool = false
    @State private var isCompleted: Bool = false
    @State private var editTitle: String = ""
    @State private var editDescription: String = ""
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.12)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Image Placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.3))
                            .frame(height: 200)
                        
                        Image(systemName: "desktopcomputer")
                            .font(.system(size: 60))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    
                    // Due Date
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
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
                        Text(task.description)
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
                            PriorityButton(
                                title: "High",
                                isSelected: task.dueDate < Date() && !task.isCompleted,
                                color: .red
                            )
                            PriorityButton(
                                title: "Medium",
                                isSelected: task.hoursUntilDue <= 24 && task.hoursUntilDue > 0,
                                color: .orange
                            )
                            PriorityButton(
                                title: "Low",
                                isSelected: task.hoursUntilDue > 24,
                                color: .blue
                            )
                        }
                    }
                    
                    // Status Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Status")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.blue)
                            Text("Mark as Complete")
                                .foregroundColor(.white)
                            Spacer()
                            Toggle("", isOn: $isCompleted)
                                .labelsHidden()
                        }
                        .padding()
                        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                        .cornerRadius(8)
                        
                        Text("When this task officially has been")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    // Metadata
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CREATED BY")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            Text("Alex Rivera")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CATEGORY")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            Text(task.category)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.vertical)
                    
                    // Update Button (when editing)
                    if isEditing {
                        Button(action: {
                            // Just toggle edit mode for mockup
                            self.isEditing = false
                        }) {
                            Text("Update Changes")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    
                    // Delete Button
                    Button(action: {
                        self.showingDeleteAlert = true
                    }) {
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
                    if self.isEditing {
                        self.isEditing = false
                    } else {
                        self.editTitle = self.task.title
                        self.editDescription = self.task.description
                        self.isEditing = true
                    }
                }) {
                    Image(systemName: self.isEditing ? "checkmark" : "pencil")
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    self.showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        )
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Task"),
                message: Text("Are you sure you want to delete this task? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    self.presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            self.isCompleted = self.task.isCompleted
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
        }
    }
}
