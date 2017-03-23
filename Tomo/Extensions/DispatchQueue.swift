//
//  DispatchQueue.swift
//  Tomo
//
//  Created by starboychina on 2017/03/23.
//  Copyright © 2017 e-business. All rights reserved.
//

extension DispatchQueue {

    /// concurrent queue with default priority
    public class var `default`: DispatchQueue {
        return .global(qos: .default)
    }

    /// concurrent queue with hight priority
    public class var high: DispatchQueue {
        return .global(qos: .userInitiated)
    }
    
    // Enqueue a block for execution at the specified time
    public func async(delay: Double, closure: @escaping () -> Void) {
        self.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(Int(delay)), execute: closure)
    }
}
