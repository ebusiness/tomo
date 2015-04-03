//
//  ApiControllerTests.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import XCTest

class ApiControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
//        ApiController.setup()
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

    func testSignUp() {
        let expect = expectationWithDescription("api")
        
        ApiController.signUp(email: "1@1.com", password: "12345678", firstName: "fName", lastName: "lName") { (error) -> Void in
            
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }
    
    func testLogin() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(email: "zhangzhihua.dev@gmail.com", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            
            expect.fulfill()
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }
    
    func testGetUserInfoFail() {
        let expect = expectationWithDescription("api")
        
        ApiController.getUserInfo("5387053ade9ace7c4c00010f", done: { (error) -> Void in
            XCTAssertNotNil(error, "should failed")
            expect.fulfill()
        })
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }

    func testGetUserInfo() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(email: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            
            ApiController.getUserInfo("5387053ade9ace7c4c00010f", done: { (error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(11115, handler: { (error) -> Void in
            println(error)
        })
    }
    
    func testGetNewsfeed() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(email: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            
            ApiController.getNewsfeed({ (error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }
    
    func testGetMessage() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(email: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            
            ApiController.getMessage({ (error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }
}
