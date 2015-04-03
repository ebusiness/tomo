//
//  DBControllerTests.swift
//  Tomo
//
//  Created by Hikaru on 2015/04/03.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import XCTest

class DBControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        ApiController.setup()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

    func testNewsfeedsHasImage() {
        let res = DBController.newsfeedsHasImage();
        println(res)
        
        XCTAssert(true, "Pass")
    }
    
    func testAllNewsfeeds() {
        let res = DBController.allNewsfeeds()
        
        println(res)
        
        for p in res! {
            println(p.imagesmobile)
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test() {
        let frc = DBController.newsfeeds()
        let info = frc.sections![0] as NSFetchedResultsSectionInfo
        
        println(info.numberOfObjects)
        
        XCTAssert(true, "Pass")
    }
}
