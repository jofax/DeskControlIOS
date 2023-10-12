//
//  ResetPasswordTest.swift
//  PulseEchoTests
//
//  Created by Joseph on 2020-01-28.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import XCTest
@testable import PulseEcho

class ResetPasswordTest: XCTestCase {

    var model: ForgotPasswordViewModel!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        model = ForgotPasswordViewModel()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        model = nil
    }
    
    func testResetPasswordInput() {
        let email = "josephpatambag1@gmail.com"
        
        do {
            let check = try model.validateEmail(username: email)
            guard check else {
                XCTAssertTrue(check)
                return
            }
            
        testRequestRestPassword()
            
        } catch let error as ForgotPasswordValidationError {
            XCTAssertTrue(false, error.description)
        } catch {
            XCTAssertTrue(false, error.localizedDescription)
        }
    }
    
    func testRequestRestPassword() {
        let email = "josephpatambag1@gmail.com"
        
        
        model.requestPinCode(email)
        model.successResponse = { (object: Any) in
            let _object = object as! GenericResponse
            
            guard _object.Success else {
                XCTAssert(_object.Success, "Error request pin code.")
                return
            }
            
            XCTAssert(_object.Success, "Success request pin code.")
        }
        
    }
    
    func testResetPasswordComplete() {
        let email = "josephpatambag1@gmail.com"
        let passsword = "abc1234566"
        let code = ""
        
        
    }

}
