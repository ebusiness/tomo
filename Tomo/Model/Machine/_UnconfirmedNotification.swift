// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UnconfirmedNotification.swift instead.

import CoreData

enum UnconfirmedNotificationAttributes: String {
    case createDate = "createDate"
    case id = "id"
    case type = "type"
}

enum UnconfirmedNotificationRelationships: String {
    case from = "from"
    case targetPost = "targetPost"
}

@objc
class _UnconfirmedNotification: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "UnconfirmedNotification"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _UnconfirmedNotification.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var createDate: NSDate?

    // func validateCreateDate(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var id: String?

    // func validateId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var type: String?

    // func validateType(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var from: User?

    // func validateFrom(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var targetPost: Post?

    // func validateTargetPost(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

