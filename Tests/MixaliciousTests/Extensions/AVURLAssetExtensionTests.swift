@testable import Mixalicious

import XCTest

import AVFoundation

final class AVURLAssetExtensionTests: XCTestCase {
    // MARK: Public properties

    func testAudioSize() {
        guard let url = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        XCTAssertEqual(asset.size, "305 KB")
    }

    func testVideoSize() {
        guard let url = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        XCTAssertEqual(asset.size, "4.5 MB")
    }

    func testAudioTime() {
        guard let url = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        XCTAssertEqual(asset.time, "19")
    }

    func testVideoTime() {
        guard let url = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        XCTAssertEqual(asset.time, "20")
    }
}
