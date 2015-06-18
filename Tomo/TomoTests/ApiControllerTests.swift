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
        
        ApiController.setup()
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
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
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
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
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
    func testsetUserTags() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(tomoid: "hikaru", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            
            ApiController.editUserTags("test", tags: ["tag3","tag4"], done: { (error) -> Void in
                XCTAssertNil(error, "")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(11115, handler: { (error) -> Void in
            println(error)
        })
    }
    
//    func testGetNewsfeed() {
//        let expect = expectationWithDescription("api")
//        
//        ApiController.login(email: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
//            XCTAssertNil(error, "")
//            println("logined")
//            ApiController.getNewsfeed({ (error) -> Void in
//                XCTAssertNil(error, "should success")
//                expect.fulfill()
//            })
//        }
//        
//        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
//            println(error)
//        })
//    }
    

    func testGetUserPosts() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            println("logined")
            ApiController.getPostOfUser("5387053ade9ace7c4c00010f", done: { (posts, error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }

    
    func testCreatePosts() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            var param = Dictionary<String, String>();
            param["content"] = "記事コンテンツ";
            for i in 1...3{
                param["images[\(i)][name]"] = "upload_2f0a4f9bfee51eacdc38f339d42eba21";
                param["images[\(i)][size][width]"] = "100";
                param["images[\(i)][size][height]"] = "100";
            }
            
            ApiController.createPosts(param,  done: { (error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }
    
    func testGetFriends() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678")  { (error) -> Void in
            XCTAssertNil(error, "")
            
            ApiController.getFriends({ (error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }
    func testCreateComment() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            
            var param = Dictionary<String, String>();
            param["content"] = "記事コンテンツ";
            param["replyTo"] = "5523a7c3a74dece90358bfdf";//
            
            let postid = "5523a697fc7c94126d3184b9"
            ApiController.createComment(postid, param: param, done: { (error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }
    func testPostLike() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            
            let postid = "5523a697fc7c94126d3184b9"
            ApiController.postLike(postid, done: { (error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }
    func testPostBookmark() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            
            let postid = "5523a697fc7c94126d3184b9"
            ApiController.postBookmark(postid, done: { (error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }
    func testPostEdit() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            
            let postid = "5523a697fc7c94126d3184b9"
            let content = "編集編集編集編集編集編集fffffffffß"
            ApiController.postEdit(postid, content: content,done: { (error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }
    func testPostCommentAble() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            
            let postid = "5523a697fc7c94126d3184b9"
            let commentable = false;//禁止
            ApiController.postCommentable(postid, commentable: commentable,done: { (error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }
    func testCommentEdit() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            
            let postid = "5523a697fc7c94126d3184b9"
            let commentid = "5523a6d9a74dece90358bfdc"
            let content = "編集編集編集編集編集編集aaaa"
            ApiController.commentEdit(postid, cid: commentid,content: content,done: { (error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }
    func testPostDel() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            
            let postid = "5523abcd454c85990f1fb0b3"
            ApiController.postDelete(postid,done: { (error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }
    func testCommentDel() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            
            let postid = "5523a697fc7c94126d3184b9"
            let commentid = "5523a6d9a74dece90358bfdc"
            ApiController.commentDelete(postid, cid: commentid,done: { (error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(1115, handler: { (error) -> Void in
            println(error)
        })
    }
    func testSetDeviceInfo() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            let token = "てst"//"" の場合はtokenを変更しない
            ApiController.setDeviceInfo(token, done: { (error) -> Void in
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
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
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
//    func testGetMessageUnread() {
//        let expect = expectationWithDescription("api")
//        
//        ApiController.login(email: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
//            XCTAssertNil(error, "")
//            
//            ApiController.getMessageUnread({ (error) -> Void in
//                XCTAssertNil(error, "should success")
//                expect.fulfill()
//            })
//        }
//        
//        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
//            println(error)
//        })
//    }
    
//    func testLoginWithOpenid() {
//        let expect = expectationWithDescription("api")
//        
//        ApiController.loginWithOpenid(openid: "oav4fuKv_KZEY7UBnwxUhLWp_vIc", token: "OezXcEiiBSKSxW0eoylIeN_aoySMxUoDtAcOfOKgsZ8QxkSuLJDlq5_6YMgJ3X7t1OrHdD5pOi_PCrGZmueRypE5rx0pZLo2-LEhbW6cA0uHas2UmIQnkjEk4pNV3uh0jvG9SJHnTY52CSHY1H5MOQ", type: "wx") { (error) -> Void in
//            
//            XCTAssertNil(error, "should success")
//            expect.fulfill()
//        }
//        
//        
//        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
//            println(error)
//        })
//    }
    
    func testReadMessage() {
        let expect = expectationWithDescription("api")
        
        ApiController.login(tomoid: "wangxinguang@e-business.co.jp", password: "12345678") { (error) -> Void in
            XCTAssertNil(error, "")
            
            ApiController.readMessage("552ce7054dc3f737080cd558", done:{ (error) -> Void in
                XCTAssertNil(error, "should success")
                expect.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
            println(error)
        })
    }
    
//    func testGetMessageUnreadCount() {
//        let expect = expectationWithDescription("api")
//        
//        ApiController.getMessageUnreadCount { (error) -> Void in
//            
//        }
//        
//        waitForExpectationsWithTimeout(15, handler: { (error) -> Void in
//            println(error)
//        })
//    }
}

