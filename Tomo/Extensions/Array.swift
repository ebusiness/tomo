//
//  Array.swift
//  Tomo
//
//  Created by starboychina on 2017/02/16.
//  Copyright © 2017 e-business. All rights reserved.
//

internal extension Array {

    /**
     Deletes all the items in self that are equal to element.
     
     - parameter element: Element to remove
     */
    mutating func remove <U: Equatable> (_ element: U) {
        let anotherSelf = self

        removeAll(keepingCapacity: true)

        anotherSelf.forEach({ current in
            let elem = current as? U

            if elem != element {
                self.append(current)
            }
        })
    }
}
