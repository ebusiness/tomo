// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Post.swift instead.

import CoreData

enum PostAttributes: String {
    case content = "content"
    case createDate = "createDate"
    case id = "id"
}

enum PostRelationships: String {
    case bookmarked = "bookmarked"
    case comments = "comments"
    case group = "group"
    case imagesmobile = "imagesmobile"
    case liked = "liked"
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
    var bookmarked: NSSet

    @NSManaged
    var comments: NSSet

    @NSManaged
    var group: Group?

    // func validateGroup(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var imagesmobile: NSSet

    @NSManaged
    var liked: NSSet

    @NSManaged
    var owner: User?

    // func validateOwner(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

extension _Post {

    func addBookmarked(objects: NSSet) {
        let mutable = self.bookmarked.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.bookmarked = mutable.copy() as NSSet
    }

    func removeBookmarked(objects: NSSet) {
        let mutable = self.bookmarked.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.bookmarked = mutable.copy() as NSSet
    }

    func addBookmarkedObject(value: User!) {
        let mutable = self.bookmarked.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.bookmarked = mutable.copy() as NSSet
    }

    func removeBookmarkedObject(value: User!) {
        let mutable = self.bookmarked.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.bookmarked = mutable.copy() as NSSet
    }

}

extension _Post {

    func addComments(objects: NSSet) {
        let mutable = self.comments.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.comments = mutable.copy() as NSSet
    }

    func removeComments(objects: NSSet) {
        let mutable = self.comments.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.comments = mutable.copy() as NSSet
    }

    func addCommentsObject(value: Comments!) {
        let mutable = self.comments.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.comments = mutable.copy() as NSSet
    }

    func removeCommentsObject(value: Comments!) {
        let mutable = self.comments.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.comments = mutable.copy() as NSSet
    }

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

extension _Post {

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
