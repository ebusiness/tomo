@objc(User)
class User: _User {

	// Custom logic goes here.

    func fullName() -> String {
        let fName = firstName ?? ""
        let lName = lastName ?? ""
        return "\(fName) \(lName)"
    }
    
    func genderText() -> String? {
        
        if let gender = gender {
            
            if gender == "1" {
                return "男"
            } else {
                return "女"
            }
            
        } else {
            return nil
        }
    }
    
    var hasIdOnly: Bool {
        return createDate == nil
    }
 
}
