//
//  LoginTest.swift
//  PulseEchoTests
//
//  Created by Joseph on 2020-01-16.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import XCTest
@testable import PulseEcho

class LoginTest: XCTestCase {
    
    var model: LoginViewModel!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        model = LoginViewModel()
        
        model.successResponse = { (object: Any) in
            
        }
    }

    override func tearDown() {
        model = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLogin() {
        let username = "josephpatambag1@gmail.com"
        let password  = "Abc999!"
        let exp = expectation(description: "Login successful")
        
        do {
            let check = try model.checkValidInput(username: username, password: password)
            guard check else {
                XCTAssertTrue(check)
                return
            }

            model.requestLogin(username, password, { (object: Any, user: User) in
                print("obejct: ", object)
                print("user:", user)
                exp.fulfill()
                
            })
            
            waitForExpectations(timeout: 10) { error in
              if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
              }
            }
            
        } catch let error as ValidationError {
            XCTAssertTrue(false, error.description)
        } catch {
            XCTAssertTrue(false, error.localizedDescription)
        }
        
    }
    
    func testActivateUser() {
        let username = "josephpatambag1@gmail.com"
        let password  = "Abc999!"
        let code = "Zxcvbnm"
        let exp = expectation(description: "User sucessfully validated.")
        
        do {
            
            let check = try model.checkCodeInput(code: code)
            
            guard check else {
                XCTAssertTrue(check)
                return
            }
            
            model.initializeActivateUser(email: username,
                                          code: code,
                                          password: password, closure: { (object: Any, user: User) in
                                            print("obejct: ", object)
                                            print("user:", user)
                                            exp.fulfill()
                                                            
            })
            
            waitForExpectations(timeout: 10) { error in
              if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
              }
            }

        } catch let error as ValidationError {
            XCTAssertTrue(false, error.description)
        } catch {
            XCTAssertTrue(false, error.localizedDescription)
        }
    }
    
    func testResendActivationCode() {
        let username = "josephpatambag1@gmail.com"
        let exp = expectation(description: "Resend activation sent.")
        
        model.initializeActivateUser(email: username,
                                         code: "TEST21", password: "Abc999!",
                                         closure: { (object, user) in
                        
            print("test response: ", object)
            print("closure response: ", user)
                                            
        })
        
    }

}
