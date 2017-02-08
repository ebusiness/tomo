//
//  Entity.swift
//  Tomo
//
//  Created by starboychina on 2015/09/08.
//  Copyright © 2015 e-business. All rights reserved.
//

import SwiftyJSON

public protocol CollectionSerializable {
    init(_ json: JSON)
    static func collection<T: CollectionSerializable>(_ json: JSON) -> [T]?
}

extension CollectionSerializable {

    init(_ respunse: Any) {
        if let json = respunse as? JSON {
            self.init(json)
        } else {
            self.init(JSON(respunse))
        }
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
