//
//  Entity.swift
//  Tomo
//
//  Created by starboychina on 2015/09/08.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import SwiftyJSON

public protocol CollectionSerializable {
    init(_ json: JSON)
    static func collection<T: CollectionSerializable>(json: JSON) -> [T]?
}

class Entity: NSObject, CollectionSerializable {
    
    //MARK - NSObject
    override init() {
        super.init()
    }
    
    //MARK - ResponseCollectionSerializable
    required init(_ json: JSON) {
        super.init()
    }
    
    class func collection<T: CollectionSerializable>(json: JSON) -> [T]? {
        
        if let array = json.array {
            return array.map { T($0) }
        }
        return nil
    }
}

//MARK - convenience

extension Entity {
    
    convenience init(_ respunse: AnyObject) {
        self.init(JSON(respunse))
    }
    
    class func collection<T: CollectionSerializable>(respunse: AnyObject) -> [T]? {
        return collection(JSON(respunse))
    }
}