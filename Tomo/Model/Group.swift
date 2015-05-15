@objc(Group)
class Group: _Group {
    
    var shouldNotification: Bool {
        get {
            for user in announcelist.array as! [User] {
                if user.id == Defaults["myId"].string {
                    return true
                }
            }
            
            return false
        }
    }
    
    var isSticky: Bool {
        get {
            for user in stickylist.array as! [User] {
                if user.id == Defaults["myId"].string {
                    return true
                }
            }
            
            return false
        }
    }
}
