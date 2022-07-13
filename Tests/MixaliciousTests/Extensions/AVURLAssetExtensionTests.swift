import AVFoundation
import XCTest

@testable import Mixalicious

final class AVURLAssetExtensionTests: XCTestCase, TestSupport {
    func testAudioSize() throws {
        let asset = try loadAsset(testData: .audio)
        XCTAssertEqual(asset.size, "305 KB")
    }

    func testVideoSize() throws {
        let asset = try loadAsset(testData: .videoWithAudio)
        XCTAssertEqual(asset.size, "4.5 MB")
    }

    func testAudioTime() throws {
        let asset = try loadAsset(testData: .audio)
        XCTAssertEqual(asset.time, "19")
    }

    func testVideoTime() throws {
        let asset = try loadAsset(testData: .videoWithAudio)
        XCTAssertEqual(asset.time, "20")
    }
}
