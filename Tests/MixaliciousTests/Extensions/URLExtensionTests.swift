@testable import Mixalicious

import XCTest

final class URLExtensionTests: XCTestCase {
    private let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                             in: .userDomainMask).first!

    override func tearDown() {
        URL.removeAllFiles(mediaType: .audio)
        URL.removeAllFiles(mediaType: .video)
        URL.removeFolder(mediaType: .audio)
        URL.removeFolder(mediaType: .video)
    }

    func testAudioURL() {
        let url = URL(mediaType: .audio)
        XCTAssertNotNil(url)
    }

    func testVideoURL() {
        let url = URL(mediaType: .video)
        XCTAssertNotNil(url)
    }

    func testDeleteAudioFolder() {
        let mediaType = MediaType.audio
        // Ensure a folder is created
        let url = URL(mediaType: mediaType)
        XCTAssertNotNil(url)
        // Delete folder
        URL.removeFolder(mediaType: mediaType)
        // Verify deletion
        let folderPath = documentDirectory.appendingPathComponent(mediaType.folderName).path
        XCTAssertFalse(FileManager.default.fileExists(atPath: folderPath))
    }

    func testDeleteVideoFolder() {
        let mediaType = MediaType.video
        // Ensure a folder is created
        let url = URL(mediaType: mediaType)
        XCTAssertNotNil(url)
        // Delete folder
        URL.removeFolder(mediaType: mediaType)
        // Verify deletion
        let folderPath = documentDirectory.appendingPathComponent(mediaType.folderName).path
        XCTAssertFalse(FileManager.default.fileExists(atPath: folderPath))
    }
}
