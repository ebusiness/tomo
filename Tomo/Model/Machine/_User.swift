// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.swift instead.

import CoreData

enum UserAttributes: String {
    case bio = "bio"
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
    case invited = "invited"
    case liked_comments = "liked_comments"
    case liked_posts = "liked_posts"
    case messages = "messages"
    case messages_to = "messages_to"
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
    var bio: String?

    // func validateBio(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

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
    var bookmarked_posts: NSOrderedSet

    @NSManaged
    var devices: NSOrderedSet

    @NSManaged
    var friends: NSOrderedSet

    @NSManaged
    var groups: NSOrderedSet

    @NSManaged
    var invited: NSOrderedSet

    @NSManaged
    var liked_comments: NSOrderedSet

    @NSManaged
    var liked_posts: NSOrderedSet

    @NSManaged
    var messages: NSOrderedSet

    @NSManaged
    var messages_to: NSOrderedSet

    @NSManaged
    var posts: NSOrderedSet

}

extension _User {

    func addBookmarked_posts(objects: NSOrderedSet) {
        let mutable = self.bookmarked_posts.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.bookmarked_posts = mutable.copy() as! NSOrderedSet
    }

    func removeBookmarked_posts(objects: NSOrderedSet) {
        let mutable = self.bookmarked_posts.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.bookmarked_posts = mutable.copy() as! NSOrderedSet
    }

    func addBookmarked_postsObject(value: Post!) {
        let mutable = self.bookmarked_posts.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.bookmarked_posts = mutable.copy() as! NSOrderedSet
    }

    func removeBookmarked_postsObject(value: Post!) {
        let mutable = self.bookmarked_posts.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.bookmarked_posts = mutable.copy() as! NSOrderedSet
    }

}

extension _User {

    func addDevices(objects: NSOrderedSet) {
        let mutable = self.devices.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.devices = mutable.copy() as! NSOrderedSet
    }

    func removeDevices(objects: NSOrderedSet) {
        let mutable = self.devices.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.devices = mutable.copy() as! NSOrderedSet
    }

    func addDevicesObject(value: Devices!) {
        let mutable = self.devices.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.devices = mutable.copy() as! NSOrderedSet
    }

    func removeDevicesObject(value: Devices!) {
        let mutable = self.devices.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.devices = mutable.copy() as! NSOrderedSet
    }

}

extension _User {

    func addFriends(objects: NSOrderedSet) {
        let mutable = self.friends.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.friends = mutable.copy() as! NSOrderedSet
    }

    func removeFriends(objects: NSOrderedSet) {
        let mutable = self.friends.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.friends = mutable.copy() as! NSOrderedSet
    }

    func addFriendsObject(value: User!) {
        let mutable = self.friends.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.friends = mutable.copy() as! NSOrderedSet
    }

    func removeFriendsObject(value: User!) {
        let mutable = self.friends.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.friends = mutable.copy() as! NSOrderedSet
    }

}

extension _User {

    func addGroups(objects: NSOrderedSet) {
        let mutable = self.groups.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.groups = mutable.copy() as! NSOrderedSet
    }

    func removeGroups(objects: NSOrderedSet) {
        let mutable = self.groups.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.groups = mutable.copy() as! NSOrderedSet
    }

    func addGroupsObject(value: Group!) {
        let mutable = self.groups.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.groups = mutable.copy() as! NSOrderedSet
    }

    func removeGroupsObject(value: Group!) {
        let mutable = self.groups.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.groups = mutable.copy() as! NSOrderedSet
    }

}

extension _User {

    func addInvited(objects: NSOrderedSet) {
        let mutable = self.invited.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.invited = mutable.copy() as! NSOrderedSet
    }

    func removeInvited(objects: NSOrderedSet) {
        let mutable = self.invited.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.invited = mutable.copy() as! NSOrderedSet
    }

    func addInvitedObject(value: User!) {
        let mutable = self.invited.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.invited = mutable.copy() as! NSOrderedSet
    }

    func removeInvitedObject(value: User!) {
        let mutable = self.invited.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.invited = mutable.copy() as! NSOrderedSet
    }

}

extension _User {

    func addLiked_comments(objects: NSOrderedSet) {
        let mutable = self.liked_comments.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.liked_comments = mutable.copy() as! NSOrderedSet
    }

    func removeLiked_comments(objects: NSOrderedSet) {
        let mutable = self.liked_comments.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.liked_comments = mutable.copy() as! NSOrderedSet
    }

    func addLiked_commentsObject(value: Comments!) {
        let mutable = self.liked_comments.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.liked_comments = mutable.copy() as! NSOrderedSet
    }

    func removeLiked_commentsObject(value: Comments!) {
        let mutable = self.liked_comments.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.liked_comments = mutable.copy() as! NSOrderedSet
    }

}

extension _User {

    func addLiked_posts(objects: NSOrderedSet) {
        let mutable = self.liked_posts.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.liked_posts = mutable.copy() as! NSOrderedSet
    }

    func removeLiked_posts(objects: NSOrderedSet) {
        let mutable = self.liked_posts.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.liked_posts = mutable.copy() as! NSOrderedSet
    }

    func addLiked_postsObject(value: Post!) {
        let mutable = self.liked_posts.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.liked_posts = mutable.copy() as! NSOrderedSet
    }

    func removeLiked_postsObject(value: Post!) {
        let mutable = self.liked_posts.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.liked_posts = mutable.copy() as! NSOrderedSet
    }

}

extension _User {

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

extension _User {

    func addMessages_to(objects: NSOrderedSet) {
        let mutable = self.messages_to.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.messages_to = mutable.copy() as! NSOrderedSet
    }

    func removeMessages_to(objects: NSOrderedSet) {
        let mutable = self.messages_to.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.messages_to = mutable.copy() as! NSOrderedSet
    }

    func addMessages_toObject(value: Message!) {
        let mutable = self.messages_to.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.messages_to = mutable.copy() as! NSOrderedSet
    }

    func removeMessages_toObject(value: Message!) {
        let mutable = self.messages_to.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.messages_to = mutable.copy() as! NSOrderedSet
    }

}

extension _User {

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
