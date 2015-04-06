@objc(Post)
class Post: _Post {

    func sortedComments() -> [Comments] {
        let sd = NSSortDescriptor(key: "createDate", ascending: false)
        return (self.comments.allObjects as NSArray).sortedArrayUsingDescriptors([sd]) as [Comments]
    }

}
