@objc(User)
class User: _User {

	// Custom logic goes here.

    func fullName() -> String {
        let fName = firstName ?? ""
        let lName = lastName ?? ""
        return "\(fName) \(lName)"
    }
    
    var hasIdOnly: Bool {
        return createDate == nil
    }
 
}
