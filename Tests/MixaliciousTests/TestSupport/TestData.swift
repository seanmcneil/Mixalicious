import AVFoundation
import Foundation

enum TestError: Error {
    case failedToLoadFile
}

enum TestData {
    case audio
    case videoWithAudio
    case videoNoAudio

    private var fileName: String {
        switch self {
        case .audio:
            return "audio_sample.m4a"

        case .videoWithAudio:
            return "video_sample.mp4"

        case .videoNoAudio:
            return "video_noaudio_sample.m4v"
        }
    }

    /// Loads test data
    ///
    /// - Note: This relies upon the files being located in a specific folder to locate them
    ///
    /// - Returns: Requested asset
    func getAsset() throws -> AVURLAsset {
        let fileManager = FileManager.default
        let packageURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let folderURL = packageURL.appendingPathComponent("TestData",
                                                          isDirectory: true)
        let fileURLs = try fileManager.contentsOfDirectory(at: folderURL,
                                                           includingPropertiesForKeys: nil)

        let fileURL = fileURLs.first { url in
            url.path.contains(fileName)
        }

        guard let fileURL = fileURL else {
            throw (TestError.failedToLoadFile)
        }

        return AVURLAsset(url: fileURL)
    }
}
