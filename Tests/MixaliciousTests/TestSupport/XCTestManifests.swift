import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(MixaliciousTests.allTests),
        ]
    }
#endif
