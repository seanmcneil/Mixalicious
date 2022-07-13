
import AVFoundation
import XCTest

@testable import Mixalicious

final class ExtractAudioTests: XCTestCase, TestAssertions {
    private let extractAudio = ExtractAudio()

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

    // Tests for the happy path using a video that contains an audio track
    func testExtractAudio() async throws {
        let video = try loadAsset(testData: .videoWithAudio)

        let url = try await extractAudio.extract(video: video,
                                                 progress: progress)
        assert(url: url, pathExtension: .m4a)
        assert(url: url, trackCount: 1)
        assertCompletedProgress()
    }

    // Tests for a scenario where a video has no audio track. This will fail
    func testNoAudioExtractAudio() async throws {
        let video = try loadAsset(testData: .videoNoAudio)

        do {
            _ = try await extractAudio.extract(video: video,
                                               progress: progress)
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error, expected: .failedToCreateAudioTrack, isCompletedProgress: false)
        }
    }
}
