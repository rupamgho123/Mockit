//
//  Mockit
//
//  Copyright (c) 2016 Syed Sabir Salman-Al-Musawi <sabirvirtuoso@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import XCTest
import Mockit


// MARK:- A test implementation of `CallHandler` protocol


class TestCallHandler: CallHandler {

  var argumentsOfSpecificCall: [Any?]?
  
  let testCase: XCTestCase
  var stub: Stub!

  var whenCalled = false
  var verifyCalled = false
  var getArgsCalled = false

  init(withTestCase testCase: XCTestCase) {
    self.testCase = testCase
  }

  func when() -> Stub {
    whenCalled = true
    stub = Stub()
    
    return stub
  }

  func verify(verificationMode mode: VerificationMode) {
    verifyCalled = true
  }

  func getArgs(callOrder order: Int) {
    getArgsCalled = true
  }

  func accept(returnValue: Any?, ofFunction function: String, atFile file: String,
                     inLine line: UInt, withArgs args: Any?...) -> Any? {
    argumentsOfSpecificCall = args
    
    return returnValue
  }
}


// MARK:- A test implementation of VerificationMode


class TestVerificationMode: VerificationMode {

  func verify(verificationData: VerificationData, mockFailer: MockFailer) {
    // Dummy, do nothing
  }
}


// MARK:- A test implementation of `Mock` protocol


class TestMockImplementation: Mock {

  var callHandler: CallHandler

  init(withCallHandler callHandler: CallHandler) {
    self.callHandler = callHandler
  }

  func instanceType() -> TestMockImplementation {
    return self
  }

  func doSomethingWithNonOptionalArguments(arg1: String, arg2: Int) -> Int {
    return callHandler.accept(0, ofFunction: #function, atFile: #file, inLine: #line, withArgs: arg1, arg2) as! Int
  }

  func doSomethingWithNoArguments() {
    callHandler.accept(nil, ofFunction: #function, atFile: #file, inLine: #line, withArgs: nil)
  }

  func doSomethingWithSomeOptionalArguments(arg1: String?, arg2: Int) {
    callHandler.accept(nil, ofFunction: #function, atFile: #file, inLine: #line, withArgs: arg1, arg2)
  }
}


// MARK:- Test cases for Mock protocol and its extension


class MockTests: XCTestCase {

  var handler: TestCallHandler!
  var sut: TestMockImplementation!

  override func setUp() {
    handler = TestCallHandler(withTestCase: self)
    sut = TestMockImplementation(withCallHandler: handler)
  }

  func testWhenIsCalled() {
    //given
    XCTAssertFalse(handler.whenCalled)

    //when
    sut.when()

    //then
    XCTAssertTrue(handler.whenCalled)
  }

  func testCallingWhenReturnsCorrectStub() {
    //given
    XCTAssertNil(handler.stub)

    //when
    let stub = sut.when()

    //then
    XCTAssertTrue(stub === handler.stub)
  }

  func testVerifyIsCalled() {
    //given
    XCTAssertFalse(handler.verifyCalled)

    //when
    sut.verify(verificationMode: TestVerificationMode())

    //then
    XCTAssertTrue(handler.verifyCalled)
  }

  func testCallingVerifyReturnsCorrectMock() {
    //given

    //when
    let mock = sut.verify(verificationMode: TestVerificationMode())

    //then
    XCTAssertTrue((mock as AnyObject) === sut)
  }

  func testGetArgsIsCalled() {
    //given
    XCTAssertFalse(handler.getArgsCalled)

    //when
    sut.getArgs(callOrder: 1)

    //then
    XCTAssertTrue(handler.getArgsCalled)
  }

  func testCallingGetArgsReturnsCorrectMock() {
    //given

    //when
    let mock = sut.getArgs(callOrder: 1)

    //then
    XCTAssertTrue((mock as AnyObject) === sut)
  }

  func testCallingOfReturnsCorrectlyForNonOptionalArguments() {
    //given
    let testArgumentOne = "testArgument"
    let testArgumentTwo = 0

    //when
    let arguments = sut.of(sut.doSomethingWithNonOptionalArguments(testArgumentOne, arg2: testArgumentTwo))

    //then
    XCTAssertEqual((arguments![0] as! String), testArgumentOne)
    XCTAssertEqual((arguments![1] as! Int), testArgumentTwo)
  }

  func testCallingOfReturnsCorrectlyForNoArguments() {
    //given

    //when
    let arguments = sut.of(sut.doSomethingWithNoArguments())

    //then
    XCTAssertNil(arguments![0])
  }

  func testCallingOfReturnsCorrectlyForSomeOptionalArguments() {
    //given
    let testArgument = 0

    //when
    let arguments = sut.of(sut.doSomethingWithSomeOptionalArguments(nil, arg2: testArgument))

    //then
    XCTAssertNil(arguments![0])
    XCTAssertEqual((arguments![1] as! Int), testArgument)
  }
}
