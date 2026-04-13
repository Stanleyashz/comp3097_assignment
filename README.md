# TaskFlow

A full-featured task management iOS app built with SwiftUI and Core Data. Designed for individuals who need a clean, focused way to organize work, track priorities, stay on top of deadlines, and visualize progress through analytics.

---

## Application Overview

TaskFlow is a dark-themed, mobile-first task manager. Users can create tasks with titles, descriptions, categories, due dates, and priority levels. Tasks are displayed in a filterable, searchable list and can be viewed in detail, edited, marked complete, or deleted. A dedicated Stats screen provides a visual analytics dashboard.

The app targets iOS 13+ and uses only native Apple frameworks — no third-party dependencies.

**App name:** TaskFlow
**Bundle identifier:** SmartTask
**Team:** Team Alpha

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | SwiftUI |
| Data Persistence | Core Data (SQLite) |
| Reactive State | Combine (`@ObservableObject`, `@Published`) |
| Notifications | UserNotifications framework |
| Minimum iOS | iOS 13+ |
| External Dependencies | None |

---

## Screen Flow

```
Launch Screen (2.5s splash)
    └── Tab Bar
            ├── Task List Tab
            │       ├── Search bar (live full-text search)
            │       ├── Filter bar (All / Today / Important / Done)
            │       ├── Sort options (Due Date / Priority / Title)
            │       ├── Task cards (color-coded by status)
            │       │       └── Context menu: Mark Complete / Delete
            │       ├── Add Task (FAB button)
            │       │       └── AddTaskView: name, description, category, priority, due date/time
            │       └── Task Detail
            │               └── TaskDetailView: view, edit, complete, delete
            └── Stats Tab
                    └── StatsView: completion ring, metrics grid, category chart, priority chart
```

---

## Features

### Task Management
- **Create tasks** — title, description, category, priority (High/Medium/Low), combined date+time due date
- **Read tasks** — persistent list that survives app termination and relaunch via Core Data
- **Update tasks** — edit title, description, category, priority, due date; completion toggle persists immediately
- **Delete tasks** — swipe-to-delete or confirmation alert from detail view
- **Custom categories** — 8 preset categories plus the ability to enter a custom category name

### Search, Filter & Sort
- **Full-text search** — searches across title, description, and category
- **Filter modes** — All tasks / Today (due today) / Important (High priority, incomplete) / Done (completed)
- **Sort options** — by due date, by priority, or alphabetically by title

### Visual Status System
Tasks automatically calculate a status based on due date and completion:

| Status | Color | Condition |
|---|---|---|
| Completed | Green | `isCompleted = true` |
| Overdue | Red | Past due date, not complete |
| Due Soon | Yellow/Orange | Due within 24 hours, not complete |
| In Progress | Blue | Future due date, not complete |

### Analytics (Stats Tab)
- Animated circular progress ring showing overall completion percentage
- Metric grid: Total / Completed / Pending / Overdue task counts
- Category breakdown bar chart
- Priority distribution bar chart with stacked visualization

### Notifications
- Local push notifications scheduled at each task's due date/time
- Triggered automatically on task creation

### UX Details
- Dark theme throughout (consistent `RGB(0.1, 0.1, 0.12)` background)
- Floating action button (FAB) for quick task creation
- Category-adaptive header in task detail (icon + color per category)
- Strikethrough styling on completed task titles
- Empty-state message when a filter returns no results
- SwiftUI previews configured in every view file

---

## Architecture

The app follows an **MVVM** pattern with Core Data as the persistence layer.

```
SmartTaskApp
    └── LaunchScreenView
            └── MainTabView
                    ├── TaskListView          @EnvironmentObject TaskStore
                    │       ├── AddTaskView   @EnvironmentObject TaskStore
                    │       └── TaskDetailView @EnvironmentObject TaskStore
                    └── StatsView             @EnvironmentObject TaskStore
```

### Data Flow

```
TaskItem (struct, Codable)
    ↕  toTaskItem() / populate(from:)
TaskEntity (NSManagedObject)
    ↕  Core Data SQLite store
PersistenceController (singleton)
    ↕  CRUD methods
TaskStore (@ObservableObject)
    ↕  @Published tasks array
SwiftUI Views
```

**`TaskStore`** is the single source of truth. It is injected at the app root as an `@StateObject` / `@EnvironmentObject` and consumed by all views. All mutations go through the store, which syncs to Core Data on every change.

---

## Project Structure

```
Proj_final/
├── SmartTaskApp.swift          App entry point — injects TaskStore, bootstraps Core Data
├── TaskModel.swift             TaskItem value type (Codable, Identifiable) + sample data
├── TaskStore.swift             ObservableObject — CRUD, stats, notification scheduling
├── TaskEntity.swift            NSManagedObject subclass — bidirectional mapping to TaskItem
├── PersistenceController.swift Core Data stack with programmatic model definition
├── LaunchScreenView.swift      2.5s splash screen with animated branding
├── MainTabView.swift           Root tab bar (Tasks + Stats tabs)
├── TaskListView.swift          Main list — search, filter, sort, task cards, FAB
├── AddTaskView.swift           Create task form with full field set
├── TaskDetailView.swift        View/edit individual task, complete, delete
├── StatsView.swift             Analytics dashboard — ring, metrics, charts
├── ContentView.swift           Legacy template (not integrated in app navigation)
└── Assets.xcassets/            App icons and accent color assets
```

---

## Changes from Prototype (v1 → v2)

| Feature | Prototype (v1) | Current (v2) |
|---|---|---|
| Task persistence | 5 hardcoded static tasks | Core Data SQLite, survives restarts |
| Create task | Dismissed without saving | Saves to Core Data, appears in list |
| Edit task | No changes saved | Updates all fields in Core Data |
| Delete task | Alert dismissed, no removal | Removed from Core Data, navigates back |
| Complete toggle | Local UI state only | Persisted to Core Data |
| Priority field | Derived from due date heuristic | Explicit user-set field (High/Medium/Low) |
| Important filter | Filtered by overdue date | Filters by High priority + incomplete |
| Search | Not available | Full-text search across title/description/category |
| Sort | Not available | Sort by due date, priority, or title |
| Analytics | Not available | Full Stats tab with ring + charts |
| Notifications | Not available | Local push notifications at due date |
| Custom categories | Fixed list only | Preset list + free-text custom entry |
| Category UI | Fixed header color | Adaptive icon + color per category |
| Empty state | No handling | Empty-state message per filter |

---

## Running the Project

1. Open `Proj_final.xcodeproj` in **Xcode 14+**
2. Select an **iOS 13+ simulator** or physical device
3. Build and run (`Cmd+R`)

No external dependencies or package installation required. Sample tasks are seeded automatically on first launch.

---

## Course

**COMP 3097** — Mobile Application Development
George Brown College
