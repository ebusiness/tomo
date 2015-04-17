// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Notification.swift instead.

import CoreData

enum NotificationAttributes: String {
    case createDate = "createDate"
    case id = "id"
    case type = "type"
}

enum NotificationRelationships: String {
    case confirmed = "confirmed"
    case from = "from"
    case owner = "owner"
    case targetPost = "targetPost"
}

@objc
class _Notification: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Notification"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Notification.entity(managedObjectContext)
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
    var confirmed: NSOrderedSet

    @NSManaged
    var from: User?

    // func validateFrom(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var owner: NSOrderedSet

    @NSManaged
    var targetPost: Post?

    // func validateTargetPost(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

extension _Notification {

    func addConfirmed(objects: NSOrderedSet) {
        let mutable = self.confirmed.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.confirmed = mutable.copy() as! NSOrderedSet
    }

    func removeConfirmed(objects: NSOrderedSet) {
        let mutable = self.confirmed.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.confirmed = mutable.copy() as! NSOrderedSet
    }

    func addConfirmedObject(value: User!) {
        let mutable = self.confirmed.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.confirmed = mutable.copy() as! NSOrderedSet
    }

    func removeConfirmedObject(value: User!) {
        let mutable = self.confirmed.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.confirmed = mutable.copy() as! NSOrderedSet
    }

}

extension _Notification {

    func addOwner(objects: NSOrderedSet) {
        let mutable = self.owner.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.owner = mutable.copy() as! NSOrderedSet
    }

    func removeOwner(objects: NSOrderedSet) {
        let mutable = self.owner.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.owner = mutable.copy() as! NSOrderedSet
    }

    func addOwnerObject(value: User!) {
        let mutable = self.owner.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.owner = mutable.copy() as! NSOrderedSet
    }

    func removeOwnerObject(value: User!) {
        let mutable = self.owner.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.owner = mutable.copy() as! NSOrderedSet
    }

}
