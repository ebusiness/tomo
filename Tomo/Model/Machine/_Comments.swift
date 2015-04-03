// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Comments.swift instead.

import CoreData

enum CommentsAttributes: String {
    case content = "content"
    case createDate = "createDate"
    case id = "id"
    case logicDelete = "logicDelete"
}

enum CommentsRelationships: String {
    case liked = "liked"
    case owner = "owner"
}

@objc
class _Comments: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Comments"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Comments.entity(managedObjectContext)
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
    var logicDelete: NSNumber?

    // func validateLogicDelete(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var liked: NSSet

    @NSManaged
    var owner: User?

    // func validateOwner(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

extension _Comments {

    func addLiked(objects: NSSet) {
        let mutable = self.liked.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.liked = mutable.copy() as NSSet
    }

    func removeLiked(objects: NSSet) {
        let mutable = self.liked.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.liked = mutable.copy() as NSSet
    }

    func addLikedObject(value: User!) {
        let mutable = self.liked.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.liked = mutable.copy() as NSSet
    }

    func removeLikedObject(value: User!) {
        let mutable = self.liked.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.liked = mutable.copy() as NSSet
    }

}
