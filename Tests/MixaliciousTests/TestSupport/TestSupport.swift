import AVFoundation
import XCTest

@testable import Mixalicious

protocol TestSupport {
    func removeFiles()
    func loadAsset(testData: TestData) throws -> AVURLAsset
}

extension TestSupport {
    func removeFiles() {
        URL.removeAllFiles(mediaType: .audio)
        URL.removeAllFiles(mediaType: .video)
    }

    func loadAsset(testData: TestData) throws -> AVURLAsset {
        try testData.getAsset()
    }

    func assertExpectedError() {
        XCTFail("Expected error did not occur")
    }
}
