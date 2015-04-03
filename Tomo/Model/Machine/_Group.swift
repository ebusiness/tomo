// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Group.swift instead.

import CoreData

enum GroupAttributes: String {
    case cover = "cover"
    case cover_ref = "cover_ref"
    case createDate = "createDate"
    case depiction = "depiction"
    case id = "id"
    case name = "name"
}

enum GroupRelationships: String {
    case owner = "owner"
    case posts = "posts"
}

@objc
class _Group: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Group"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Group.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var cover: String?

    // func validateCover(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var cover_ref: String?

    // func validateCover_ref(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var createDate: NSDate?

    // func validateCreateDate(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var depiction: String?

    // func validateDepiction(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var id: String?

    // func validateId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var name: String?

    // func validateName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var owner: User?

    // func validateOwner(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var posts: NSSet

}

extension _Group {

    func addPosts(objects: NSSet) {
        let mutable = self.posts.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.posts = mutable.copy() as NSSet
    }

    func removePosts(objects: NSSet) {
        let mutable = self.posts.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.posts = mutable.copy() as NSSet
    }

    func addPostsObject(value: Post!) {
        let mutable = self.posts.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.posts = mutable.copy() as NSSet
    }

    func removePostsObject(value: Post!) {
        let mutable = self.posts.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.posts = mutable.copy() as NSSet
    }

}
