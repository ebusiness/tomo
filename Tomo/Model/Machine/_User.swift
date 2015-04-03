// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.swift instead.

import CoreData

enum UserAttributes: String {
    case cover = "cover"
    case cover_ref = "cover_ref"
    case createDate = "createDate"
    case email = "email"
    case firstName = "firstName"
    case id = "id"
    case lastName = "lastName"
    case photo = "photo"
    case photo_ref = "photo_ref"
    case provider = "provider"
    case type = "type"
}

enum UserRelationships: String {
    case bookmarked_posts = "bookmarked_posts"
    case devices = "devices"
    case friends = "friends"
    case groups = "groups"
    case liked_comments = "liked_comments"
    case liked_posts = "liked_posts"
    case messages = "messages"
    case posts = "posts"
}

@objc
class _User: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "User"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _User.entity(managedObjectContext)
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
    var email: String?

    // func validateEmail(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var firstName: String?

    // func validateFirstName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var id: String?

    // func validateId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var lastName: String?

    // func validateLastName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var photo: String?

    // func validatePhoto(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var photo_ref: String?

    // func validatePhoto_ref(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var provider: String?

    // func validateProvider(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var type: String?

    // func validateType(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var bookmarked_posts: NSSet

    @NSManaged
    var devices: NSSet

    @NSManaged
    var friends: NSSet

    @NSManaged
    var groups: NSSet

    @NSManaged
    var liked_comments: NSSet

    @NSManaged
    var liked_posts: NSSet

    @NSManaged
    var messages: NSSet

    @NSManaged
    var posts: NSSet

}

extension _User {

    func addBookmarked_posts(objects: NSSet) {
        let mutable = self.bookmarked_posts.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.bookmarked_posts = mutable.copy() as NSSet
    }

    func removeBookmarked_posts(objects: NSSet) {
        let mutable = self.bookmarked_posts.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.bookmarked_posts = mutable.copy() as NSSet
    }

    func addBookmarked_postsObject(value: Post!) {
        let mutable = self.bookmarked_posts.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.bookmarked_posts = mutable.copy() as NSSet
    }

    func removeBookmarked_postsObject(value: Post!) {
        let mutable = self.bookmarked_posts.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.bookmarked_posts = mutable.copy() as NSSet
    }

}

extension _User {

    func addDevices(objects: NSSet) {
        let mutable = self.devices.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.devices = mutable.copy() as NSSet
    }

    func removeDevices(objects: NSSet) {
        let mutable = self.devices.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.devices = mutable.copy() as NSSet
    }

    func addDevicesObject(value: Devices!) {
        let mutable = self.devices.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.devices = mutable.copy() as NSSet
    }

    func removeDevicesObject(value: Devices!) {
        let mutable = self.devices.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.devices = mutable.copy() as NSSet
    }

}

extension _User {

    func addFriends(objects: NSSet) {
        let mutable = self.friends.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.friends = mutable.copy() as NSSet
    }

    func removeFriends(objects: NSSet) {
        let mutable = self.friends.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.friends = mutable.copy() as NSSet
    }

    func addFriendsObject(value: User!) {
        let mutable = self.friends.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.friends = mutable.copy() as NSSet
    }

    func removeFriendsObject(value: User!) {
        let mutable = self.friends.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.friends = mutable.copy() as NSSet
    }

}

extension _User {

    func addGroups(objects: NSSet) {
        let mutable = self.groups.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.groups = mutable.copy() as NSSet
    }

    func removeGroups(objects: NSSet) {
        let mutable = self.groups.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.groups = mutable.copy() as NSSet
    }

    func addGroupsObject(value: Group!) {
        let mutable = self.groups.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.groups = mutable.copy() as NSSet
    }

    func removeGroupsObject(value: Group!) {
        let mutable = self.groups.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.groups = mutable.copy() as NSSet
    }

}

extension _User {

    func addLiked_comments(objects: NSSet) {
        let mutable = self.liked_comments.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.liked_comments = mutable.copy() as NSSet
    }

    func removeLiked_comments(objects: NSSet) {
        let mutable = self.liked_comments.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.liked_comments = mutable.copy() as NSSet
    }

    func addLiked_commentsObject(value: Comments!) {
        let mutable = self.liked_comments.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.liked_comments = mutable.copy() as NSSet
    }

    func removeLiked_commentsObject(value: Comments!) {
        let mutable = self.liked_comments.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.liked_comments = mutable.copy() as NSSet
    }

}

extension _User {

    func addLiked_posts(objects: NSSet) {
        let mutable = self.liked_posts.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.liked_posts = mutable.copy() as NSSet
    }

    func removeLiked_posts(objects: NSSet) {
        let mutable = self.liked_posts.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.liked_posts = mutable.copy() as NSSet
    }

    func addLiked_postsObject(value: Post!) {
        let mutable = self.liked_posts.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.liked_posts = mutable.copy() as NSSet
    }

    func removeLiked_postsObject(value: Post!) {
        let mutable = self.liked_posts.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.liked_posts = mutable.copy() as NSSet
    }

}

extension _User {

    func addMessages(objects: NSSet) {
        let mutable = self.messages.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.messages = mutable.copy() as NSSet
    }

    func removeMessages(objects: NSSet) {
        let mutable = self.messages.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.messages = mutable.copy() as NSSet
    }

    func addMessagesObject(value: Message!) {
        let mutable = self.messages.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.messages = mutable.copy() as NSSet
    }

    func removeMessagesObject(value: Message!) {
        let mutable = self.messages.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.messages = mutable.copy() as NSSet
    }

}

extension _User {

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
