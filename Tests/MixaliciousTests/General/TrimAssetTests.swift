
import AVFoundation
import XCTest

@testable import Mixalicious

final class TrimAssetTests: XCTestCase, TestAssertions {
    private var progress: Progress!

    var fractionCompleted: Double {
        progress.fractionCompleted
    }

    override func tearDown() async throws {
        removeFiles()
    }

    override func setUp() async throws {
        progress = Progress(totalUnitCount: 1000)
    }

    func testTrimAudioTimeRange() async throws {
        let trimAsset = TrimAsset()
        let asset = try loadAsset(testData: .audio)

        let url = try await trimAsset.trim(asset: asset,
                                           mediaType: .audio,
                                           timeRange: asset.midDuration,
                                           progress: progress)
        assert(url: url, pathExtension: .m4a)
        assert(url: url, trackCount: 1)
        // The trimmed video should be approximately 50% the length of the original
        assert(url: url, duration: asset.duration.seconds / 2.0)
        assertCompletedProgress()
    }
}
