@objc(Post)
class Post: _Post, MKAnnotation {

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
    
    var isMyPost: Bool {
        get {
            return owner?.id == Defaults["myId"].string
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(35.6556659999999965, 139.7567469999999901)
    }
    
    var title: String! {
        return owner?.nickName
    }
    
    var subtitle: String! {
        return content
    }
    
    func delete() {
        MR_deleteEntity()
        
        managedObjectContext?.MR_saveToPersistentStoreWithCompletion(nil)
    }
}
