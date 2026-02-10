//
//  AddTaskView.swift
//  SmartTask
//
//  Mockup 3 - Add Task Screen - iOS 13+ Compatible
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var taskName: String = ""
    @State private var taskDescription: String = ""
    @State private var selectedCategory: String = "Work"
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    
    let categories = ["Work", "School", "Personal", "Custom"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.12)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Task Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            TextField("e.g., Design Review Meeting", text: $taskName)
                                .padding()
                                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            // iOS 13 compatible TextEditor alternative
                            ZStack(alignment: .topLeading) {
                                if taskDescription.isEmpty {
                                    Text("Enter task details or sub-tasks...")
                                        .foregroundColor(.gray)
                                        .padding(.top, 16)
                                        .padding(.leading, 12)
                                }
                                
                                TextEditor(text: $taskDescription)
                                    .frame(height: 120)
                                    .padding(8)
                                    .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .opacity(taskDescription.isEmpty ? 0.25 : 1)
                            }
                        }
                        
                        // Task Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Category")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Menu {
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        self.selectedCategory = category
                                    }) {
                                        Text(category)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedCategory)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Date & Time
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date & Time")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 12) {
                                // Date Picker
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.gray)
                                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                        .labelsHidden()
                                        .accentColor(.blue)
                                }
                                .padding()
                                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                                .cornerRadius(8)
                                
                                // Time Picker
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.gray)
                                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .accentColor(.blue)
                                }
                                .padding()
                                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                                .cornerRadius(8)
                            }
                        }
                        
                        Spacer(minLength: 40)
                        
                        // Save Button
                        Button(action: {
                            // Just dismiss for mockup
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save Task")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(taskName.isEmpty ? Color.blue.opacity(0.5) : Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(taskName.isEmpty)
                        
                        // Cancel Button
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Add New Task", displayMode: .inline)
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
    }
}
