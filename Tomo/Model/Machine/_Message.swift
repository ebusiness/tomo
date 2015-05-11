// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.swift instead.

import CoreData

enum MessageAttributes: String {
    case content = "content"
    case createDate = "createDate"
    case id = "id"
    case isRead = "isRead"
    case subject = "subject"
}

enum MessageRelationships: String {
    case from = "from"
    case group = "group"
    case opened = "opened"
    case to = "to"
}

@objc
class _Message: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Message"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Message.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var content: String?

    // func validateContent(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var createDate: NSDate?

    // func validateCreateDate(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var id: String?

    // func validateId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var isRead: NSNumber?

    // func validateIsRead(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var subject: String?

    // func validateSubject(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var from: User?

    // func validateFrom(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var group: Group?

    // func validateGroup(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var opened: NSOrderedSet

    @NSManaged
    var to: NSOrderedSet

}

extension _Message {

    func addOpened(objects: NSOrderedSet) {
        let mutable = self.opened.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.opened = mutable.copy() as! NSOrderedSet
    }

    func removeOpened(objects: NSOrderedSet) {
        let mutable = self.opened.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.opened = mutable.copy() as! NSOrderedSet
    }

    func addOpenedObject(value: User!) {
        let mutable = self.opened.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.opened = mutable.copy() as! NSOrderedSet
    }

    func removeOpenedObject(value: User!) {
        let mutable = self.opened.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.opened = mutable.copy() as! NSOrderedSet
    }

}

extension _Message {

    func addTo(objects: NSOrderedSet) {
        let mutable = self.to.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.to = mutable.copy() as! NSOrderedSet
    }

    func removeTo(objects: NSOrderedSet) {
        let mutable = self.to.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.to = mutable.copy() as! NSOrderedSet
    }

    func addToObject(value: User!) {
        let mutable = self.to.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.to = mutable.copy() as! NSOrderedSet
    }

    func removeToObject(value: User!) {
        let mutable = self.to.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.to = mutable.copy() as! NSOrderedSet
    }

}
