//
//  String.swift
//  ExSwift
//
//  Created by pNre on 03/06/14.
//  Copyright (c) 2014 pNre. All rights reserved.
//

import Foundation

public extension String {

    /**
        String length
    */
    var length: Int { return count(self) }
    
    /**
    Strips whitespaces from the beginning of self.
    
    :returns: Stripped string
    */
    func ltrimmed () -> String {
        return ltrimmed(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    /**
    Strips the specified characters from the beginning of self.
    
    :returns: Stripped string
    */
    func ltrimmed (set: NSCharacterSet) -> String {
        if let range = rangeOfCharacterFromSet(set.invertedSet) {
            return self[range.startIndex..<endIndex]
        }
        
        return ""
    }
    
    /**
    Strips whitespaces from the end of self.
    
    :returns: Stripped string
    */
    func rtrimmed () -> String {
        return rtrimmed(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    /**
    Strips the specified characters from the end of self.
    
    :returns: Stripped string
    */
    func rtrimmed (set: NSCharacterSet) -> String {
        if let range = rangeOfCharacterFromSet(set.invertedSet, options: NSStringCompareOptions.BackwardsSearch) {
            return self[startIndex..<range.endIndex]
        }
        
        return ""
    }
    
    /**
    Strips whitespaces from both the beginning and the end of self.
    
    :returns: Stripped string
    */
    func trimmed () -> String {
        return ltrimmed().rtrimmed()
    }
    
}