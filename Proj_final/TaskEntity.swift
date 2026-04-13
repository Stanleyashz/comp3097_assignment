//
//  TaskEntity.swift
//  SmartTask
//
//  NSManagedObject subclass for Core Data — iOS 14+ Compatible
//

import CoreData
import Foundation

@objc(TaskEntity)
class TaskEntity: NSManagedObject {

    // These names must exactly match the attribute names in PersistenceController.makeModel().
    @NSManaged var id:               UUID
    @NSManaged var title:            String
    @NSManaged var taskDescription:  String
    @NSManaged var category:         String
    @NSManaged var dueDate:          Date
    @NSManaged var status:           String
    @NSManaged var isCompleted:      Bool
    @NSManaged var priority:         String
}

// MARK: - Fetch Request

extension TaskEntity {

    /// Typed fetch request for all TaskEntity objects.
    static var fetchRequest: NSFetchRequest<TaskEntity> {
        NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }
}

// MARK: - Mapping

extension TaskEntity {

    /// Converts this managed object to the app's value-type domain model.
    func toTaskItem() -> TaskItem {
        TaskItem(
            id:          id,
            title:       title,
            description: taskDescription,
            category:    category,
            dueDate:     dueDate,
            status:      status,
            isCompleted: isCompleted,
            priority:    priority
        )
    }

    /// Copies all fields from a TaskItem value into this managed object.
    func populate(from item: TaskItem) {
        id              = item.id
        title           = item.title
        taskDescription = item.description
        category        = item.category
        dueDate         = item.dueDate
        status          = item.status
        isCompleted     = item.isCompleted
        priority        = item.priority
    }
}
