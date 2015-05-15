// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Group.swift instead.

import CoreData

enum GroupAttributes: String {
    case cover = "cover"
    case cover_ref = "cover_ref"
    case createDate = "createDate"
    case detail = "detail"
    case id = "id"
    case logicDelete = "logicDelete"
    case name = "name"
    case section = "section"
    case type = "type"
}

enum GroupRelationships: String {
    case announcelist = "announcelist"
    case messages = "messages"
    case owner = "owner"
    case participants = "participants"
    case posts = "posts"
    case station = "station"
    case stickylist = "stickylist"
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
    var detail: String?

    // func validateDetail(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

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
    var section: NSNumber?

    // func validateSection(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var type: String?

    // func validateType(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var announcelist: NSOrderedSet

    @NSManaged
    var messages: NSOrderedSet

    @NSManaged
    var owner: User?

    // func validateOwner(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var participants: NSOrderedSet

    @NSManaged
    var posts: NSOrderedSet

    @NSManaged
    var station: Station?

    // func validateStation(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var stickylist: NSOrderedSet

}

extension _Group {

    func addAnnouncelist(objects: NSOrderedSet) {
        let mutable = self.announcelist.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.announcelist = mutable.copy() as! NSOrderedSet
    }

    func removeAnnouncelist(objects: NSOrderedSet) {
        let mutable = self.announcelist.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.announcelist = mutable.copy() as! NSOrderedSet
    }

    func addAnnouncelistObject(value: User!) {
        let mutable = self.announcelist.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.announcelist = mutable.copy() as! NSOrderedSet
    }

    func removeAnnouncelistObject(value: User!) {
        let mutable = self.announcelist.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.announcelist = mutable.copy() as! NSOrderedSet
    }

}

extension _Group {

    func addMessages(objects: NSOrderedSet) {
        let mutable = self.messages.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.messages = mutable.copy() as! NSOrderedSet
    }

    func removeMessages(objects: NSOrderedSet) {
        let mutable = self.messages.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.messages = mutable.copy() as! NSOrderedSet
    }

    func addMessagesObject(value: Message!) {
        let mutable = self.messages.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.messages = mutable.copy() as! NSOrderedSet
    }

    func removeMessagesObject(value: Message!) {
        let mutable = self.messages.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.messages = mutable.copy() as! NSOrderedSet
    }

}

extension _Group {

    func addParticipants(objects: NSOrderedSet) {
        let mutable = self.participants.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.participants = mutable.copy() as! NSOrderedSet
    }

    func removeParticipants(objects: NSOrderedSet) {
        let mutable = self.participants.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.participants = mutable.copy() as! NSOrderedSet
    }

    func addParticipantsObject(value: User!) {
        let mutable = self.participants.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.participants = mutable.copy() as! NSOrderedSet
    }

    func removeParticipantsObject(value: User!) {
        let mutable = self.participants.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.participants = mutable.copy() as! NSOrderedSet
    }

}

extension _Group {

    func addPosts(objects: NSOrderedSet) {
        let mutable = self.posts.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.posts = mutable.copy() as! NSOrderedSet
    }

    func removePosts(objects: NSOrderedSet) {
        let mutable = self.posts.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.posts = mutable.copy() as! NSOrderedSet
    }

    func addPostsObject(value: Post!) {
        let mutable = self.posts.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.posts = mutable.copy() as! NSOrderedSet
    }

    func removePostsObject(value: Post!) {
        let mutable = self.posts.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.posts = mutable.copy() as! NSOrderedSet
    }

}

extension _Group {

    func addStickylist(objects: NSOrderedSet) {
        let mutable = self.stickylist.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.stickylist = mutable.copy() as! NSOrderedSet
    }

    func removeStickylist(objects: NSOrderedSet) {
        let mutable = self.stickylist.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.stickylist = mutable.copy() as! NSOrderedSet
    }

    func addStickylistObject(value: User!) {
        let mutable = self.stickylist.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.stickylist = mutable.copy() as! NSOrderedSet
    }

    func removeStickylistObject(value: User!) {
        let mutable = self.stickylist.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.stickylist = mutable.copy() as! NSOrderedSet
    }

}
