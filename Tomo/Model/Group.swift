@objc(Group)
class Group: _Group {
    
    var sectionIdentifier: String {
        get {
            willAccessValueForKey("sectionIdentifier")
            
            var res: String = "B"
            
            if owner?.id == Defaults["myId"].string {
                res = "A"
            }
            
            for user in participants {
                if user.id == Defaults["myId"].string {
                    res = "A"
                    break
                }
            }
            
            setPrimitiveValue(res, forKey: "sectionIdentifier")
            return res
        }
    }
}
