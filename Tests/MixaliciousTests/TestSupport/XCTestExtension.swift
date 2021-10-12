import AVFoundation
import XCTest

enum ErrorMessage {
    static let expected = "An error should occur"
    static let failedToLoad = "Failed to load asset"
    static let unexpected = "No error should occur"
    static let wrong = "This is the wrong error"
}

enum FileName {
    static let audio = "audio_sample.m4a"
    static let video = "video_sample.mp4"
    static let videoOnly = "video_noaudio_sample.m4v"
}

extension XCTest {
    var timeout: TimeInterval {
        10.0
    }

    /// Loads test data
    ///
    /// - Note: This relies upon the files being located in a specific folder to locate them
    ///
    /// - Parameter name: String representing the name of asset to load, including extension
    /// - Returns: URL of asset, or nil if not found
    func loadTestAsset(name: String) -> URL? {
        let fileManager = FileManager.default
        let packageURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let folderURL = packageURL.appendingPathComponent("TestData",
                                                          isDirectory: true)
        let fileURLs = try! fileManager.contentsOfDirectory(at: folderURL,
                                                            includingPropertiesForKeys: nil)

        for fileURL in fileURLs where fileURL.path.contains(name) {
            return fileURL
        }

        return nil
    }
}
