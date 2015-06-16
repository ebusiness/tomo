// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Post.swift instead.

import CoreData

enum PostAttributes: String {
    case content = "content"
    case createDate = "createDate"
    case id = "id"
    case logicDelete = "logicDelete"
    case newsfeed = "newsfeed"
}

enum PostRelationships: String {
    case bookmarked = "bookmarked"
    case comments = "comments"
    case group = "group"
    case imagesmobile = "imagesmobile"
    case liked = "liked"
    case owner = "owner"
    case tags = "tags"
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

    @NSManaged
    var logicDelete: NSNumber?

    // func validateLogicDelete(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var newsfeed: NSNumber?

    // func validateNewsfeed(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var bookmarked: NSSet

    @NSManaged
    var comments: NSOrderedSet

    @NSManaged
    var group: Group?

    // func validateGroup(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var imagesmobile: NSOrderedSet

    @NSManaged
    var liked: NSOrderedSet

    @NSManaged
    var owner: User?

    // func validateOwner(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var tags: NSSet

}

extension _Post {

    func addBookmarked(objects: NSSet) {
        let mutable = self.bookmarked.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.bookmarked = mutable.copy() as! NSSet
    }

    func removeBookmarked(objects: NSSet) {
        let mutable = self.bookmarked.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.bookmarked = mutable.copy() as! NSSet
    }

    func addBookmarkedObject(value: User!) {
        let mutable = self.bookmarked.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.bookmarked = mutable.copy() as! NSSet
    }

    func removeBookmarkedObject(value: User!) {
        let mutable = self.bookmarked.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.bookmarked = mutable.copy() as! NSSet
    }

}

extension _Post {

    func addComments(objects: NSOrderedSet) {
        let mutable = self.comments.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.comments = mutable.copy() as! NSOrderedSet
    }

    func removeComments(objects: NSOrderedSet) {
        let mutable = self.comments.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.comments = mutable.copy() as! NSOrderedSet
    }

    func addCommentsObject(value: Comments!) {
        let mutable = self.comments.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.comments = mutable.copy() as! NSOrderedSet
    }

    func removeCommentsObject(value: Comments!) {
        let mutable = self.comments.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.comments = mutable.copy() as! NSOrderedSet
    }

}

extension _Post {

    func addImagesmobile(objects: NSOrderedSet) {
        let mutable = self.imagesmobile.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.imagesmobile = mutable.copy() as! NSOrderedSet
    }

    func removeImagesmobile(objects: NSOrderedSet) {
        let mutable = self.imagesmobile.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.imagesmobile = mutable.copy() as! NSOrderedSet
    }

    func addImagesmobileObject(value: Images!) {
        let mutable = self.imagesmobile.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.imagesmobile = mutable.copy() as! NSOrderedSet
    }

    func removeImagesmobileObject(value: Images!) {
        let mutable = self.imagesmobile.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.imagesmobile = mutable.copy() as! NSOrderedSet
    }

}

extension _Post {

    func addLiked(objects: NSOrderedSet) {
        let mutable = self.liked.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.liked = mutable.copy() as! NSOrderedSet
    }

    func removeLiked(objects: NSOrderedSet) {
        let mutable = self.liked.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.liked = mutable.copy() as! NSOrderedSet
    }

    func addLikedObject(value: User!) {
        let mutable = self.liked.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.liked = mutable.copy() as! NSOrderedSet
    }

    func removeLikedObject(value: User!) {
        let mutable = self.liked.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.liked = mutable.copy() as! NSOrderedSet
    }

}

extension _Post {

    func addTags(objects: NSSet) {
        let mutable = self.tags.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.tags = mutable.copy() as! NSSet
    }

    func removeTags(objects: NSSet) {
        let mutable = self.tags.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.tags = mutable.copy() as! NSSet
    }

    func addTagsObject(value: Tag!) {
        let mutable = self.tags.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.tags = mutable.copy() as! NSSet
    }

    func removeTagsObject(value: Tag!) {
        let mutable = self.tags.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.tags = mutable.copy() as! NSSet
    }

}
