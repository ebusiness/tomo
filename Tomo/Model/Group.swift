@objc(Group)
class Group: _Group {

    var typeStr: String? {
        get {
            if type == "public" {
                return "一般公開"
            }
            
            return nil
        }
    }

}
