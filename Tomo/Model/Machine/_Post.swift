// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Post.swift instead.

import CoreData

enum PostAttributes: String {
    case content = "content"
    case createDate = "createDate"
    case id = "id"
}

enum PostRelationships: String {
    case group = "group"
    case imagesmobile = "imagesmobile"
    case owner = "owner"
}

@objc
class _Post: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Post"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Post.entity(managedObjectContext)
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

    // MARK: - Relationships

    @NSManaged
    var group: Group?

    // func validateGroup(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var imagesmobile: NSSet

    @NSManaged
    var owner: User?

    // func validateOwner(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

extension _Post {

    func addImagesmobile(objects: NSSet) {
        let mutable = self.imagesmobile.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.imagesmobile = mutable.copy() as NSSet
    }

    func removeImagesmobile(objects: NSSet) {
        let mutable = self.imagesmobile.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.imagesmobile = mutable.copy() as NSSet
    }

    func addImagesmobileObject(value: Images!) {
        let mutable = self.imagesmobile.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.imagesmobile = mutable.copy() as NSSet
    }

    func removeImagesmobileObject(value: Images!) {
        let mutable = self.imagesmobile.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.imagesmobile = mutable.copy() as NSSet
    }

}
