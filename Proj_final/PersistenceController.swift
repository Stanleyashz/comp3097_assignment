//
//  PersistenceController.swift
//  SmartTask
//
//  Core Data stack — model defined in code, no .xcdatamodeld file required.
//  iOS 14+ Compatible
//

import CoreData

final class PersistenceController {

    // MARK: - Shared Instances

    /// Production store backed by SQLite on disk.
    static let shared = PersistenceController()

    /// In-memory store used for SwiftUI Previews and unit tests.
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        TaskItem.sampleTasks.forEach { controller.createEntity(from: $0) }
        controller.save()
        return controller
    }()

    // MARK: - Core Data Stack

    let container: NSPersistentContainer

    var context: NSManagedObjectContext { container.viewContext }

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(
            name: "SmartTask",
            managedObjectModel: PersistenceController.makeModel()
        )

        if inMemory {
            container.persistentStoreDescriptions.first?.url =
                URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                // In production, handle gracefully rather than crashing.
                fatalError("Core Data failed to load store: \(error.localizedDescription)")
            }
        }

        // Merge background-context changes into the view context automatically.
        container.viewContext.automaticallyMergesChangesFromParent = true
        // Object-level values trump the store when conflicts arise.
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Save

    /// Saves the view context if it has unsaved changes.
    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("[PersistenceController] Save failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Entity Helpers

    /// Creates a new TaskEntity in the view context from a TaskItem value.
    @discardableResult
    func createEntity(from item: TaskItem) -> TaskEntity {
        let entity = TaskEntity(context: context)
        entity.populate(from: item)
        return entity
    }

    /// Fetches the TaskEntity matching a given UUID, or nil if not found.
    func fetchEntity(id: UUID) -> TaskEntity? {
        let request = TaskEntity.fetchRequest
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    /// Returns all stored TaskEntities sorted by due date.
    func fetchAll() -> [TaskEntity] {
        let request = TaskEntity.fetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)
        ]
        return (try? context.fetch(request)) ?? []
    }

    // MARK: - Programmatic Core Data Model

    /// Builds an NSManagedObjectModel at runtime so no .xcdatamodeld file is needed.
    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name        = "TaskEntity"
        entity.managedObjectClassName = NSStringFromClass(TaskEntity.self)

        entity.properties = [
            attribute("id",               .UUIDAttributeType,    optional: false),
            attribute("title",            .stringAttributeType,  optional: false),
            attribute("taskDescription",  .stringAttributeType,  optional: true),
            attribute("category",         .stringAttributeType,  optional: false),
            attribute("dueDate",          .dateAttributeType,    optional: false),
            attribute("status",           .stringAttributeType,  optional: false),
            attribute("isCompleted",      .booleanAttributeType, optional: false),
            attribute("priority",         .stringAttributeType,  optional: false),
        ]

        model.entities = [entity]
        return model
    }

    private static func attribute(
        _ name: String,
        _ type: NSAttributeType,
        optional: Bool
    ) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name          = name
        attr.attributeType = type
        attr.isOptional    = optional
        return attr
    }
}
