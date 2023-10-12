//
//  RegistrationTest.swift
//  
//
//  Created by Joseph on 2020-01-16.
//

import XCTest
@testable import PulseEcho

class RegistrationTest: XCTestCase {
    
    var model: RegisterViewModel!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        model = RegisterViewModel()
        
    }

    override func tearDown() {
        model = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUserSignup() {
        let username = "josephpatambag1+testuser1@gmail.com"
        let password = "password123"
        let verify_password = "password123"
        
        do {
            let check = try model.checkValidInput(username: username, password: password, verify_password: verify_password)
             XCTAssertTrue(check)
        } catch let error as RegisterValidationError {
            XCTAssertTrue(false, error.description)
        } catch {
             XCTAssertTrue(false)
        }
    }
    
    func testProcessSignup() {
        let username = "josephpatambag1+testuser1@gmail.com"
        let password = "password123"
        
        let parameters = ["Email":username,
                          "Password":password]
        
        let request = model.requestSignup(parameters)
        XCTAssertNil(request, "SUCCESS")
    }

}
