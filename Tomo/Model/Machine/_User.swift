// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.swift instead.

import CoreData

enum UserAttributes: String {
    case address = "address"
    case bioText = "bioText"
    case birthDay = "birthDay"
    case cover = "cover"
    case cover_ref = "cover_ref"
    case createDate = "createDate"
    case email = "email"
    case firstName = "firstName"
    case gender = "gender"
    case id = "id"
    case lastName = "lastName"
    case marriage = "marriage"
    case nationality = "nationality"
    case nearestSt = "nearestSt"
    case photo = "photo"
    case photo_ref = "photo_ref"
    case provider = "provider"
    case telNo = "telNo"
    case tomoid = "tomoid"
    case type = "type"
    case webSite = "webSite"
    case zipCode = "zipCode"
}

enum UserRelationships: String {
    case bookmarked_posts = "bookmarked_posts"
    case confirms = "confirms"
    case devices = "devices"
    case friends = "friends"
    case groups = "groups"
    case inGroups = "inGroups"
    case inGroups_announce = "inGroups_announce"
    case inGroups_sticky = "inGroups_sticky"
    case invited = "invited"
    case liked_comments = "liked_comments"
    case liked_posts = "liked_posts"
    case messages = "messages"
    case messages_to = "messages_to"
    case posts = "posts"
    case stations = "stations"
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
    var address: String?

    // func validateAddress(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var bioText: String?

    // func validateBioText(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var birthDay: NSDate?

    // func validateBirthDay(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

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
    var gender: String?

    // func validateGender(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var id: String?

    // func validateId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var lastName: String?

    // func validateLastName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var marriage: String?

    // func validateMarriage(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var nationality: String?

    // func validateNationality(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var nearestSt: String?

    // func validateNearestSt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

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
    var telNo: String?

    // func validateTelNo(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var tomoid: String?

    // func validateTomoid(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var type: String?

    // func validateType(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var webSite: String?

    // func validateWebSite(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var zipCode: String?

    // func validateZipCode(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var bookmarked_posts: NSOrderedSet

    @NSManaged
    var confirms: NSOrderedSet

    @NSManaged
    var devices: NSOrderedSet

    @NSManaged
    var friends: NSOrderedSet

    @NSManaged
    var groups: NSOrderedSet

    @NSManaged
    var inGroups: NSOrderedSet

    @NSManaged
    var inGroups_announce: NSOrderedSet

    @NSManaged
    var inGroups_sticky: NSOrderedSet

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

    @NSManaged
    var stations: NSOrderedSet

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

    func addConfirms(objects: NSOrderedSet) {
        let mutable = self.confirms.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.confirms = mutable.copy() as! NSOrderedSet
    }

    func removeConfirms(objects: NSOrderedSet) {
        let mutable = self.confirms.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.confirms = mutable.copy() as! NSOrderedSet
    }

    func addConfirmsObject(value: Notification!) {
        let mutable = self.confirms.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.confirms = mutable.copy() as! NSOrderedSet
    }

    func removeConfirmsObject(value: Notification!) {
        let mutable = self.confirms.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.confirms = mutable.copy() as! NSOrderedSet
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

    func addInGroups(objects: NSOrderedSet) {
        let mutable = self.inGroups.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.inGroups = mutable.copy() as! NSOrderedSet
    }

    func removeInGroups(objects: NSOrderedSet) {
        let mutable = self.inGroups.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.inGroups = mutable.copy() as! NSOrderedSet
    }

    func addInGroupsObject(value: Group!) {
        let mutable = self.inGroups.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.inGroups = mutable.copy() as! NSOrderedSet
    }

    func removeInGroupsObject(value: Group!) {
        let mutable = self.inGroups.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.inGroups = mutable.copy() as! NSOrderedSet
    }

}

extension _User {

    func addInGroups_announce(objects: NSOrderedSet) {
        let mutable = self.inGroups_announce.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.inGroups_announce = mutable.copy() as! NSOrderedSet
    }

    func removeInGroups_announce(objects: NSOrderedSet) {
        let mutable = self.inGroups_announce.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.inGroups_announce = mutable.copy() as! NSOrderedSet
    }

    func addInGroups_announceObject(value: Group!) {
        let mutable = self.inGroups_announce.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.inGroups_announce = mutable.copy() as! NSOrderedSet
    }

    func removeInGroups_announceObject(value: Group!) {
        let mutable = self.inGroups_announce.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.inGroups_announce = mutable.copy() as! NSOrderedSet
    }

}

extension _User {

    func addInGroups_sticky(objects: NSOrderedSet) {
        let mutable = self.inGroups_sticky.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.inGroups_sticky = mutable.copy() as! NSOrderedSet
    }

    func removeInGroups_sticky(objects: NSOrderedSet) {
        let mutable = self.inGroups_sticky.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.inGroups_sticky = mutable.copy() as! NSOrderedSet
    }

    func addInGroups_stickyObject(value: Group!) {
        let mutable = self.inGroups_sticky.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.inGroups_sticky = mutable.copy() as! NSOrderedSet
    }

    func removeInGroups_stickyObject(value: Group!) {
        let mutable = self.inGroups_sticky.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.inGroups_sticky = mutable.copy() as! NSOrderedSet
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

extension _User {

    func addStations(objects: NSOrderedSet) {
        let mutable = self.stations.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.stations = mutable.copy() as! NSOrderedSet
    }

    func removeStations(objects: NSOrderedSet) {
        let mutable = self.stations.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.stations = mutable.copy() as! NSOrderedSet
    }

    func addStationsObject(value: Station!) {
        let mutable = self.stations.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.stations = mutable.copy() as! NSOrderedSet
    }

    func removeStationsObject(value: Station!) {
        let mutable = self.stations.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.stations = mutable.copy() as! NSOrderedSet
    }

}
