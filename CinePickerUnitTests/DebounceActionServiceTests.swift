import XCTest
@testable import CinePicker

class DebounceActionServiceTests: XCTestCase {
    
    private var debounceActionService: DebounceActionService!

    override func setUp() {
        super.setUp()
        
        debounceActionService = DebounceActionService()
    }

    override func tearDown() {
        debounceActionService = nil
        
        super.tearDown()
    }
    
    func testShouldCallCallbackOnlyOnce() {
        var callingCount: Int = 0
        let promise = expectation(description: "")
        
        debounceActionService.async(delay: DispatchTimeInterval.milliseconds(5)) {
            callingCount += 1
        }
        
        debounceActionService.async(delay: DispatchTimeInterval.milliseconds(5)) {
            callingCount += 1
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertEqual(callingCount, 1)
    }

}
