import AVFoundation
import XCTest

@testable import Mixalicious

final class AVAssetExtensionTests: XCTestCase, TestSupport {
    func testIsAudioOnly() throws {
        let asset = try loadAsset(testData: .audio)
        XCTAssertTrue(asset.isAudioOnly)
    }

    func testIsAudioOnlyFail() throws {
        let asset = try loadAsset(testData: .videoWithAudio)
        XCTAssertFalse(asset.isAudioOnly)
    }

    func testIsAudioAndVideoPresent() throws {
        let asset = try loadAsset(testData: .videoWithAudio)
        XCTAssertTrue(asset.isAudioAndVideoPresent)
    }

    func testIsAudioAndVideoPresentFail() throws {
        let asset = try loadAsset(testData: .videoNoAudio)
        XCTAssertFalse(asset.isAudioAndVideoPresent)
    }

    func testHasAudioTrack() throws {
        let asset = try loadAsset(testData: .videoWithAudio)
        XCTAssertTrue(asset.hasAudioTrack)
    }

    func testHasAudioTrackFail() throws {
        let asset = try loadAsset(testData: .videoNoAudio)
        XCTAssertFalse(asset.hasAudioTrack)
    }

    func testHasVideoTrack() throws {
        let asset = try loadAsset(testData: .videoWithAudio)
        XCTAssertTrue(asset.hasVideoTrack)
    }

    func testHasVideoTrackFail() throws {
        let asset = try loadAsset(testData: .audio)
        XCTAssertFalse(asset.hasVideoTrack)
    }

    func testTimeRangeAudio() throws {
        let asset = try loadAsset(testData: .audio)
        XCTAssertEqual(asset.timeRange,
                       CMTimeRange(start: .zero, duration: asset.duration))
    }

    func testTimeRangeVideo() throws {
        let asset = try loadAsset(testData: .videoWithAudio)
        XCTAssertEqual(asset.timeRange,
                       CMTimeRange(start: .zero, duration: asset.duration))
    }
}
