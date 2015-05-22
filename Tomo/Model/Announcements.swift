@objc(Announcements)
class Announcements: _Announcements {

    var path: String {
        get {
            return kAPIBaseURLString + "/mobile/announcements/\(id!)"
        }
    }

}
