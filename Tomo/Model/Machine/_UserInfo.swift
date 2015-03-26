// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UserInfo.swift instead.

import CoreData

enum UserInfoAttributes: String {
    case firstName = "firstName"
    case id = "id"
    case lastName = "lastName"
}

enum UserInfoRelationships: String {
    case posts = "posts"
}

@objc
class _UserInfo: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "UserInfo"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _UserInfo.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var firstName: String?

    // func validateFirstName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var id: String?

    // func validateId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var lastName: String?

    // func validateLastName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var posts: NSSet

}

extension _UserInfo {

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
