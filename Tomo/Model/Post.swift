@objc(Post)
class Post: _Post {

//    func sortedComments() -> [Comments] {
//        let sd = NSSortDescriptor(key: "createDate", ascending: false)
//        return (self.comments.allObjects as NSArray).sortedArrayUsingDescriptors([sd]) as [Comments]
//    }

    var image: Images? {
        return imagesmobile.firstObject as? Images
    }
    
    var imageSize: CGSize? {
        get {
            if let image = image {
                if image.width != nil && image.height != nil {
                    return CGSize(width: CGFloat(image.width!), height: CGFloat(image.height!))
                }
            }
            
            return nil
        }
    }

    var imagePath: String? {
        return image?.name
    }
}
