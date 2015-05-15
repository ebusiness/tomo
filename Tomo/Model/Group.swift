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
    
    func setSticky() {
        for user in stickylist.array as! [User] {
            if user.id == Defaults["myId"].string {
                isSticky = true
                return
            }
        }
        
        isSticky = false
    }
    
    func isMyGroup() -> Bool {
        return owner?.id == Defaults["myId"].string
    }
    
}
