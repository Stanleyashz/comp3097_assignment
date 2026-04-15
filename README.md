# TaskFlow

A task management iOS app built with SwiftUI. Designed for individuals who need a clean, focused way to organize work, track priorities, and stay on top of deadlines.

---

## Application Overview

TaskFlow is a dark-themed, mobile-first task manager. Users can create tasks with titles, descriptions, categories, due dates, and priority levels. Tasks are displayed in a filterable list and can be viewed in detail, edited, marked complete, or deleted.

The app targets iOS 13+ and uses only native SwiftUI — no third-party dependencies.

**App name:** TaskFlow
**Bundle:** SmartTask
**Team:** Team Alpha

---

## Screen Flow

```
Launch Screen
    └── Task List (All / Today / Important filters)
            ├── Task Detail (view, edit, complete, delete)
            └── Add Task (name, description, category, priority, due date/time)
```

---

## Changes from Early Prototype

The initial version was a pure UI mockup — all four screens were styled and navigable but no data operation actually worked.

| Feature | Prototype (v1) | Current (v2) |
|---|---|---|
| Task list data | 5 hardcoded static tasks | Persisted via UserDefaults (survives app restarts) |
| Create task | Dismissed modal without saving | Saves new task to store, appears in list immediately |
| Edit task | Toggle edit mode, no changes saved | Updates title, description, priority in persistent store |
| Delete task | Showed alert then dismissed | Removes task from store, navigates back |
| Complete toggle | Updated local UI state only | Persists completion state to store |
| Priority field | Derived from due date heuristic | Explicit field: High / Medium / Low, set by user |
| Important filter | Filtered by overdue date | Filters by High priority + incomplete |
| Task card | Title + status + date | Adds priority badge + strikethrough on completion |
| Detail header | Fixed orange gradient | Color and icon adapt to task category |
| Empty state | No handling | Shows empty-state message when filter has no results |
| Data model | `struct TaskItem` (no persistence) | `TaskItem: Codable` + `TaskStore: ObservableObject` |

### Architecture Change

A `TaskStore` class was introduced as the single source of truth. It is injected at the app root as an `@EnvironmentObject` and consumed by `TaskListView`, `AddTaskView`, and `TaskDetailView`. All mutations go through the store, which auto-persists to `UserDefaults` via `JSONEncoder` on every change.

```
SmartTaskApp
    └── LaunchScreenView
            └── TaskListView          @EnvironmentObject TaskStore
                    ├── AddTaskView   @EnvironmentObject TaskStore
                    └── TaskDetailView @EnvironmentObject TaskStore
```

---

## Current Functionality (~30% Complete)

### Works end-to-end
- **Create tasks** — title, description, category, priority, combined date+time due date
- **Read tasks** — persistent list that survives app termination and relaunch
- **Update tasks** — edit title, description, priority; completion toggle persists immediately
- **Delete tasks** — confirmation alert, then removed from store and list
- **Filter tasks** — All / Today / High-priority (Important)
- **Visual status** — color-coded cards (green = done, red = overdue, yellow = due soon, blue = upcoming)
- **Priority badges** — shown on list cards and selectable in detail/add views
- **Category icons** — detail header adapts icon and color per category

### Still stubbed / not yet implemented
- No user authentication — app opens directly to task list
- No push notifications or local reminders for due dates
- No search or sort controls
- No recurring tasks
- No subtasks or checklists within a task
- No cloud sync — data is local to the device only
- No collaboration or task sharing
- Category management is fixed (no custom categories persisted)
- "Created by" metadata is not captured (field removed pending auth)
- No iCloud or cross-device support

---

## End Goal: Full Functional Prototype

The following features are planned to bring TaskFlow to a complete v1 product.

### 1. User Authentication
- Sign in with Apple / email+password via Firebase Auth or Supabase
- User profile screen (name, avatar)
- Tasks scoped per authenticated user

### 2. Cloud Sync & Backend
- Replace UserDefaults with a remote database (Firebase Firestore or Supabase)
- Real-time task updates across devices
- Offline support with local cache + sync on reconnect

### 3. Notifications & Reminders
- Local push notifications scheduled at task due date
- Optional reminder offsets (15 min, 1 hour, 1 day before)
- Notification management screen

### 4. Search & Sort
- Full-text search bar on task list
- Sort by: due date, priority, creation date, alphabetical
- Multi-filter support (e.g., Today + High priority)

### 5. Subtasks & Checklists
- Add checklist items within a task
- Progress indicator on task card (e.g., "2/5 subtasks done")

### 6. Recurring Tasks
- Repeat options: daily, weekly, monthly, custom
- Auto-generate next occurrence on completion

### 7. Categories Management
- Create, rename, and delete custom categories
- Color-code categories
- Filter by category

### 8. Statistics & Dashboard
- Completion rate over time
- Tasks completed per day/week chart
- Overdue task summary

### 9. Collaboration (Stretch Goal)
- Share tasks or task lists with other users
- Assign tasks to team members
- Comment thread on tasks

### 10. Widgets & Shortcuts
- iOS home screen widget showing today's tasks
- Siri Shortcuts integration ("Add task to TaskFlow")

---

## Project Structure

```
SwiftUI_MockUps/
├── SmartTaskApp.swift       App entry point, injects TaskStore
├── TaskModel.swift          TaskItem struct (Codable, Identifiable)
├── TaskStore.swift          ObservableObject, UserDefaults persistence
├── launchscreenview.swift   Splash screen with fade-in animation
├── tasklistview.swift       Main list with filters and task cards
├── AddTaskView.swift        Create new task form
├── TaskDetailView.swift     View, edit, complete, delete a task
└── Assets.xcassets/         App icons and color assets
```

---

## Running the Project

1. Open `SwiftUI_MockUps.xcodeproj` (or `.xcworkspace`) in Xcode 14+
2. Select an iOS 13+ simulator or physical device
3. Build and run (`Cmd+R`)

No external dependencies or package setup required.
