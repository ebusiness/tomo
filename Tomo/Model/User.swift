@objc(User)
class User: _User {
    
    var hasIdOnly: Bool {
        return createDate == nil
    }
 
}
