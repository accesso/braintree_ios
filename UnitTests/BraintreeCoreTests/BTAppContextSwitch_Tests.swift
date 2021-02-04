import XCTest

class BTAppContextSwitch_Tests: XCTestCase {
    var appSwitch = BTAppContextSwitcher.sharedInstance()

    override func setUp() {
        super.setUp()
        appSwitch = BTAppContextSwitcher.sharedInstance()
    }

    override func tearDown() {
        MockAppContextSwitchDriver.cannedCanHandle = false
        MockAppContextSwitchDriver.lastCanHandleURL = nil
        MockAppContextSwitchDriver.lastHandleReturnURL = nil
        super.tearDown()
    }

    func testHandleOpenURL_whenHandlerIsRegistered_invokesCanHandleReturnURL() {
        appSwitch.register(MockAppContextSwitchDriver.self)
        let expectedURL = URL(string: "fake://url")!

        BTAppContextSwitcher.handleOpen(expectedURL)

        XCTAssertEqual(MockAppContextSwitchDriver.lastCanHandleURL!, expectedURL)
    }

    func testHandleOpenURL_whenHandlerCanHandleOpenURL_invokesHandleReturnURL_andReturnsTrue() {
        appSwitch.register(MockAppContextSwitchDriver.self)
        MockAppContextSwitchDriver.cannedCanHandle = true
        let expectedURL = URL(string: "fake://url")!

        let handled = BTAppContextSwitcher.handleOpen(expectedURL)

        XCTAssertTrue(handled)
        XCTAssertEqual(MockAppContextSwitchDriver.lastHandleReturnURL!, expectedURL)
    }

    func testHandleOpenURL_whenHandlerCantHandleOpenURL_doesNotInvokeHandleReturnURL_andReturnsFalse() {
        appSwitch.register(MockAppContextSwitchDriver.self)
        MockAppContextSwitchDriver.cannedCanHandle = false

        let handled = BTAppContextSwitcher.handleOpen(URL(string: "fake://url")!)

        XCTAssertFalse(handled)
        XCTAssertNil(MockAppContextSwitchDriver.lastHandleReturnURL)
    }

    func testHandleOpenURLContext_whenHandlerCanHandleOpenURL_invokesHandleReturnURL_andReturnsTrue() {
        guard #available(iOS 13.0, *) else { return }

        appSwitch.register(MockAppContextSwitchDriver.self)
        MockAppContextSwitchDriver.cannedCanHandle = true

        let urlContext = MockOpenURLContext(url: URL(string: "my-url.com")!)

        let handled = BTAppContextSwitcher.handleOpenURLContext(urlContext)

        XCTAssertTrue(handled)
        XCTAssertEqual(MockAppContextSwitchDriver.lastCanHandleURL, URL(string: "my-url.com"))
        XCTAssertEqual(MockAppContextSwitchDriver.lastHandleReturnURL, URL(string: "my-url.com"))
    }

    func testHandleOpenURLContext_whenHandlerCantHandleOpenURL_doesNotInvokeHandleReturnURL_andReturnsFalse() {
        guard #available(iOS 13.0, *) else { return }

        appSwitch.register(MockAppContextSwitchDriver.self)
        MockAppContextSwitchDriver.cannedCanHandle = false

        let urlContext = MockOpenURLContext(url: URL(string: "fake://url")!)

        let handled = BTAppContextSwitcher.handleOpenURLContext(urlContext)

        XCTAssertFalse(handled)
        XCTAssertNil(MockAppContextSwitchDriver.lastHandleReturnURL)
    }

    func testHandleOpenURL_withNoAppSwitching_returnsFalse() {
        let handled = BTAppContextSwitcher.handleOpen(URL(string: "scheme://")!)
        XCTAssertFalse(handled)
    }

}

class MockAppContextSwitchDriver: BTAppContextSwitchDriver {
    static var cannedCanHandle = false
    static var lastCanHandleURL : URL? = nil
    static var lastHandleReturnURL : URL? = nil

    static func canHandleReturnURL(_ url: URL) -> Bool {
        lastCanHandleURL = url
        return cannedCanHandle
    }

    @objc static func handleReturnURL(_ url: URL) {
        lastHandleReturnURL = url
    }
}

@available(iOS 13.0, *)
class MockOpenURLContext: UIOpenURLContext {

    private let _url: URL

    override var url: URL {
        return _url
    }

    init(url: URL) {
        self._url = url
    }
}
