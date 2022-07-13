
import AVFoundation
import XCTest

@testable import Mixalicious

final class CombineAssetsTests: XCTestCase, TestAssertions {
    private let combineAssets = CombineAssets()

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
}

// MARK: Audio

extension CombineAssetsTests {
    // This test inserts audio at the start of a video that has no audio track
    func testCombineAudio() async throws {
        let audio = try loadAsset(testData: .audio)
        let assets = [audio, audio, audio]
        let expectedDuration = audio.duration.seconds * 3.0

        assertInitialProgress()
        let url = try await combineAssets.combine(assets: assets,
                                                  mediaType: .audio,
                                                  progress: progress)
        assert(url: url, pathExtension: .m4a)
        assert(url: url, trackCount: 1)
        assert(url: url, duration: expectedDuration)
        assertCompletedProgress()
    }

    func testCombineAudioAndVideoMixedArray() async throws {
        let video = try loadAsset(testData: .videoWithAudio)
        let audio = try loadAsset(testData: .audio)
        let assets = [audio, video]
        let duration = video.duration.seconds + audio.duration.seconds

        assertInitialProgress()

        let url = try await combineAssets.combine(assets: assets,
                                                  mediaType: .audio,
                                                  progress: progress)
        assert(url: url, pathExtension: .m4a)
        assert(url: url, trackCount: 1)
        assert(url: url, duration: duration, accuracy: 0.05)
        assertCompletedProgress()
    }
}

// MARK: Video

extension CombineAssetsTests {
    // This test inserts audio at the start of a video that has no audio track
    func testCombineVideo() async throws {
        let video = try loadAsset(testData: .videoWithAudio)
        let assets = [video, video, video]
        let expectedDuration = video.duration.seconds * 3.0

        assertInitialProgress()
        let url = try await combineAssets.combine(assets: assets,
                                                  mediaType: .video,
                                                  progress: progress)
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: 2)
        assert(url: url, duration: expectedDuration, accuracy: 0.05)
        assertCompletedProgress()
    }
}
