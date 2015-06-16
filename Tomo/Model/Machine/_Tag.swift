// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Tag.swift instead.

import CoreData

enum TagAttributes: String {
    case count = "count"
    case createDate = "createDate"
    case id = "id"
    case logicDelete = "logicDelete"
    case name = "name"
    case type = "type"
    case wikis = "wikis"
}

enum TagRelationships: String {
    case groups = "groups"
    case posts = "posts"
    case users = "users"
}

@objc
class _Tag: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Tag"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Tag.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var count: NSNumber?

    // func validateCount(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var createDate: NSDate?

    // func validateCreateDate(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var id: String?

    // func validateId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var logicDelete: NSNumber?

    // func validateLogicDelete(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var name: String?

    // func validateName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var type: String?

    // func validateType(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var wikis: String?

    // func validateWikis(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var groups: NSSet

    @NSManaged
    var posts: NSSet

    @NSManaged
    var users: NSSet

}

extension _Tag {

    func addGroups(objects: NSSet) {
        let mutable = self.groups.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.groups = mutable.copy() as! NSSet
    }

    func removeGroups(objects: NSSet) {
        let mutable = self.groups.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.groups = mutable.copy() as! NSSet
    }

    func addGroupsObject(value: Group!) {
        let mutable = self.groups.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.groups = mutable.copy() as! NSSet
    }

    func removeGroupsObject(value: Group!) {
        let mutable = self.groups.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.groups = mutable.copy() as! NSSet
    }

}

extension _Tag {

    func addPosts(objects: NSSet) {
        let mutable = self.posts.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.posts = mutable.copy() as! NSSet
    }

    func removePosts(objects: NSSet) {
        let mutable = self.posts.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.posts = mutable.copy() as! NSSet
    }

    func addPostsObject(value: Post!) {
        let mutable = self.posts.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.posts = mutable.copy() as! NSSet
    }

    func removePostsObject(value: Post!) {
        let mutable = self.posts.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.posts = mutable.copy() as! NSSet
    }

}

extension _Tag {

    func addUsers(objects: NSSet) {
        let mutable = self.users.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.users = mutable.copy() as! NSSet
    }

    func removeUsers(objects: NSSet) {
        let mutable = self.users.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.users = mutable.copy() as! NSSet
    }

    func addUsersObject(value: User!) {
        let mutable = self.users.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.users = mutable.copy() as! NSSet
    }

    func removeUsersObject(value: User!) {
        let mutable = self.users.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.users = mutable.copy() as! NSSet
    }

}
