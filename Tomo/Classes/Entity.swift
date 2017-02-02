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
    static func collection<T: CollectionSerializable>(_ json: JSON) -> [T]?
}

extension CollectionSerializable {

    init(_ respunse: Any) {
        self.init(JSON(respunse))
    }

    static func collection<T: CollectionSerializable>(_ json: JSON) -> [T]? {

        if let array = json.array {
            return array.map { T($0) }
        }
        return nil
    }

    static func collection<T: CollectionSerializable>(respunse: Any) -> [T]? {
        return collection(JSON(respunse))
    }
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
}

//MARK - convenience

extension Entity {
}
