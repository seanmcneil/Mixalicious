import AVFoundation
import XCTest

@testable import Mixalicious

enum PathExtension: CustomStringConvertible {
    case mp4
    case m4a

    var description: String {
        switch self {
        case .m4a:
            return "m4a"

        case .mp4:
            return "mp4"
        }
    }
}

protocol TestAssertions: TestSupport {
    var fractionCompleted: Double { get }
    var multipleAssetTracks: Int { get }

    func assertInitialProgress()
    func assertCompletedProgress()
    func assert(url: URL,
                pathExtension: PathExtension)
    func assert(url: URL,
                trackCount: Int)
    func assert(url: URL,
                duration: Double,
                accuracy: Double)
    func assert(error: MixaliciousError,
                expected: MixaliciousError,
                isCompletedProgress: Bool)
}

extension TestAssertions {
    /// macOS and iOS/tvOS differ on the amount of audio tracks when merging multiple tracks
    var multipleAssetTracks: Int {
        #if os(macOS)
            return 3
        #else
            return 2
        #endif
    }

    /// Assert that the progress is at 0.0
    func assertInitialProgress() {
        XCTAssertEqual(fractionCompleted, 0.0, accuracy: 0.01)
    }

    /// Assert that the progress is at 1.0, indicating completion (success or failure)
    func assertCompletedProgress() {
        XCTAssertEqual(fractionCompleted, 1.0, accuracy: 0.01)
    }

    /// Assert that the file at the provided `url` has the expected `pathExtension`
    /// - Parameters:
    ///   - url: ``URL`` to evaluate
    ///   - pathExtension: Expected pathExtension for the file
    func assert(url: URL,
                pathExtension: PathExtension) {
        XCTAssertEqual(url.pathExtension, pathExtension.description)
    }

    /// Assert that the provided `url` generates an ``AVURLAsset`` with the correct amount of tracks
    /// - Parameters:
    ///   - url: ``URL`` to evaluate
    ///   - trackCount: Expected count of asset tracks
    func assert(url: URL,
                trackCount: Int) {
        let asset = AVURLAsset(url: url)
        XCTAssertEqual(asset.tracks.count, trackCount)
    }

    /// Assert that the provided `url` generates an ``AVURLAsset`` with the correct duration
    /// - Parameters:
    ///   - url: ``URL`` to evaluate
    ///   - duration: Expected duration of the asset in seconds
    ///   - accuracy: Desired accuracy of equal operation. Default value is `0.01`
    func assert(url: URL,
                duration: Double,
                accuracy: Double = 0.01) {
        let asset = AVURLAsset(url: url)
        XCTAssertEqual(asset.duration.seconds,
                       duration,
                       accuracy: accuracy)
    }

    /// Assert that the provided `error` matches the expected ``MixaliciousError``
    ///
    /// - Note: Use the `isCompletedProgress` argument to indicate if progress
    /// should be set to 0.0 or 1.0
    ///
    /// - Parameters:
    ///   - error: Provided by the `catch` block
    ///   - expected: Expected ``MixaliciousError``
    ///   - isCompletedProgress: Indicate if `progress` should be marked as complete
    func assert(error: MixaliciousError,
                expected: MixaliciousError,
                isCompletedProgress: Bool = true) {
        XCTAssertEqual(error, expected)
        if isCompletedProgress {
            assertCompletedProgress()
        } else {
            assertInitialProgress()
        }
    }
}
