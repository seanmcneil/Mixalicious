@testable import Mixalicious

import XCTest

import AVFoundation

final class ProgressExtensionTests: XCTestCase {
    func testReset() {
        let progress = Progress(totalUnitCount: 1)
        progress.completedUnitCount = 1
        XCTAssertEqual(progress.completedUnitCount, 1)
        progress.reset()
        XCTAssertEqual(progress.completedUnitCount, 0)
    }
}
