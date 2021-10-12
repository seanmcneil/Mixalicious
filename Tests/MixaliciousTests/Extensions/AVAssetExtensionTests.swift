@testable import Mixalicious

import XCTest

import AVFoundation

final class AVAssetExtensionTests: XCTestCase {
    private let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                             in: .userDomainMask).first!

    func testIsAudioOnly() {
        guard let url = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        XCTAssertTrue(asset.isAudioOnly)
    }

    func testIsAudioOnlyFail() {
        guard let url = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        XCTAssertFalse(asset.isAudioOnly)
    }

    func testIsAudioAndVideoPresent() {
        guard let url = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        XCTAssertTrue(asset.isAudioAndVideoPresent)
    }

    func testIsAudioAndVideoPresentFail() {
        guard let url = loadTestAsset(name: FileName.videoOnly) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        XCTAssertFalse(asset.isAudioAndVideoPresent)
    }

    func testHasAudioTrack() {
        guard let url = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        XCTAssertTrue(asset.hasAudioTrack)
    }

    func testHasAudioTrackFail() {
        guard let url = loadTestAsset(name: FileName.videoOnly) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        XCTAssertFalse(asset.hasAudioTrack)
    }

    func testHasVideoTrack() {
        guard let url = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        XCTAssertTrue(asset.hasVideoTrack)
    }

    func testHasVideoTrackFail() {
        guard let url = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        XCTAssertFalse(asset.hasVideoTrack)
    }

    func testTimeRangeAudio() {
        guard let url = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        XCTAssertEqual(asset.timeRange,
                       CMTimeRange(start: .zero, duration: asset.duration))
    }

    func testTimeRangeVideo() {
        guard let url = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        XCTAssertEqual(asset.timeRange,
                       CMTimeRange(start: .zero, duration: asset.duration))
    }
}
