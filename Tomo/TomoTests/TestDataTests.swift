//
//  TestDataTests.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/03.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import XCTest

class TestDataTests: XCTestCase {

    override func setUp() {
        super.setUp()
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
    
//    func test() {
//        let expect = expectationWithDescription("api")
//        
//        TestData.getRandomAvatarPath { (path) -> Void in
//            expect.fulfill()
//        }
//        
//        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
//            println(error)
//        })
//    }

}
