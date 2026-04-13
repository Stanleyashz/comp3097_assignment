//
//  TaskListView.swift
//  SmartTask
//
//  Task List — search, sort, swipe-to-delete, context menu — iOS 14+
//

import SwiftUI

struct TaskListView: View {

    @EnvironmentObject var taskStore: TaskStore
    @State private var selectedFilter: TaskFilter = .all
    @State private var showingAddTask   = false
    @State private var searchText       = ""
    @State private var selectedSort: SortOption = .dueDate

    // Remove default UITableView chrome once, globally, for this app.
    init() {
        UITableView.appearance().backgroundColor  = .clear
        UITableView.appearance().separatorStyle   = .none
    }

    // MARK: - Enums

    enum TaskFilter: String, CaseIterable {
        case all       = "All"
        case today     = "Today"
        case important = "Important"
        case completed = "Done"
    }

    enum SortOption: String, CaseIterable {
        case dueDate  = "Due Date"
        case priority = "Priority"
        case title    = "Title"
    }

    // MARK: - Filtering & Sorting

    var filteredTasks: [TaskItem] {
        var result = taskStore.tasks

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)     ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch selectedFilter {
        case .all:       break
        case .today:     result = result.filter { Calendar.current.isDateInToday($0.dueDate) }
        case .important: result = result.filter { $0.priority == "High" && !$0.isCompleted }
        case .completed: result = result.filter { $0.isCompleted }
        }

        switch selectedSort {
        case .dueDate:  result.sort { $0.dueDate < $1.dueDate }
        case .priority: result.sort { priorityRank($0.priority) < priorityRank($1.priority) }
        case .title:    result.sort { $0.title.localizedCompare($1.title) == .orderedAscending }
        }

        return result
    }

    private func priorityRank(_ p: String) -> Int {
        switch p { case "High": return 0; case "Medium": return 1; default: return 2 }
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.12)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    searchBar
                    filterSortRow
                    taskCountRow

                    if filteredTasks.isEmpty {
                        emptyState
                    } else {
                        taskList
                    }
                }

                addButton
            }
            .navigationBarTitle("My Tasks", displayMode: .large)
            .sheet(isPresented: $showingAddTask) {
                AddTaskView().environmentObject(taskStore)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Sub-views

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search tasks…", text: $searchText)
                .foregroundColor(.white)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var filterSortRow: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        FilterButton(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter,
                            action: { selectedFilter = filter }
                        )
                    }
                }
                .padding(.horizontal)
            }

            Divider()
                .background(Color.gray.opacity(0.3))
                .frame(height: 20)

            Menu {
                ForEach(SortOption.allCases, id: \.self) { sort in
                    Button(action: { selectedSort = sort }) {
                        HStack {
                            Text(sort.rawValue)
                            if selectedSort == sort { Image(systemName: "checkmark") }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(selectedSort.rawValue).font(.system(size: 11))
                }
                .foregroundColor(.blue)
                .font(.system(size: 13))
                .padding(.horizontal, 12)
            }
        }
        .padding(.vertical, 8)
    }

    private var taskCountRow: some View {
        HStack {
            Text("\(filteredTasks.count) task\(filteredTasks.count == 1 ? "" : "s")")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            Spacer()
            if taskStore.overdueCount > 0 {
                Label("\(taskStore.overdueCount) overdue",
                      systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: searchText.isEmpty ? "checkmark.circle" : "magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundColor(.gray)
                Text(searchText.isEmpty
                     ? "No tasks here"
                     : "No results for \"\(searchText)\"")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                if searchText.isEmpty && selectedFilter != .all {
                    Button("Show all tasks") { selectedFilter = .all }
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
            }
            Spacer()
        }
    }

    private var taskList: some View {
        List {
            ForEach(filteredTasks) { task in
                NavigationLink(destination: TaskDetailView(taskID: task.id)) {
                    TaskCardView(task: task)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .contextMenu {
                    Button(action: { taskStore.toggleComplete(task) }) {
                        Label(
                            task.isCompleted ? "Mark Incomplete" : "Mark Complete",
                            systemImage: task.isCompleted ? "circle" : "checkmark.circle"
                        )
                    }
                    Button(action: { taskStore.deleteTask(task) }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .onDelete(perform: deleteTasks)
        }
        .listStyle(PlainListStyle())
        .background(Color(red: 0.1, green: 0.1, blue: 0.12))
    }

    private var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        offsets.map { filteredTasks[$0] }.forEach { taskStore.deleteTask($0) }
    }
}

// MARK: - Filter Button

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

// MARK: - Task Card

struct TaskCardView: View {
    let task: TaskItem

    var statusColor: Color {
        switch task.statusColor {
        case "green":  return .green
        case "red":    return .red
        case "yellow": return .yellow
        default:       return .blue
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(statusColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .gray)

                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .strikethrough(task.isCompleted, color: .gray)

                    Spacer()

                    Text(formatDueDate(task.dueDate))
                        .font(.system(size: 12))
                        .foregroundColor(task.dueDate < Date() && !task.isCompleted ? .red : .gray)
                }

                HStack {
                    Label(task.category, systemImage: categoryIcon(for: task.category))
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Spacer()
                    priorityBadge
                }
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 16)
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(12)
    }

    private var priorityBadge: some View {
        let color: Color = task.priority == "High" ? .red : task.priority == "Medium" ? .orange : .blue
        return Text(task.priority)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .cornerRadius(4)
    }

    private func formatDueDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date)    { return "Today" }
        if Calendar.current.isDateInTomorrow(date) { return "Tomorrow" }
        if date < Date()                           { return "Overdue" }
        let f = DateFormatter(); f.dateFormat = "MMM d"
        return f.string(from: date)
    }

    func categoryIcon(for category: String) -> String {
        switch category {
        case "Work":          return "briefcase"
        case "School":        return "book"
        case "Personal":      return "person"
        case "Design System": return "paintbrush"
        case "Documentation": return "doc.text"
        case "Meetings":      return "person.3"
        case "Reports":       return "chart.bar"
        default:              return "folder"
        }
    }
}

// MARK: - Preview

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
            .environmentObject(TaskStore(persistence: .preview))
    }
}
