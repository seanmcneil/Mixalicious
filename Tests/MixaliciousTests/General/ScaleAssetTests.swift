
import AVFoundation
import XCTest

@testable import Mixalicious

final class ScaleAssetTests: XCTestCase, TestAssertions {
    private let scaleAsset = ScaleAsset()

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

extension ScaleAssetTests {
    func testScaleAudioSlow() async throws {
        let asset = try loadAsset(testData: .audio)
        let multiplier: Float64 = 3.0

        let url = try await scaleAsset.scale(asset: asset,
                                             multiplier: multiplier,
                                             isAudioIncluded: true,
                                             mediaType: .audio,
                                             progress: progress)
        assert(url: url, pathExtension: .m4a)
        assert(url: url, trackCount: 1)
        // The scaled video should be approximately 3x the length of the original
        assert(url: url, duration: asset.duration.seconds * multiplier, accuracy: 0.25)
        assertCompletedProgress()
    }

    func testScaleAudioFast() async throws {
        let asset = try loadAsset(testData: .audio)
        let multiplier: Float64 = 0.33333

        let url = try await scaleAsset.scale(asset: asset,
                                             multiplier: multiplier,
                                             isAudioIncluded: true,
                                             mediaType: .audio,
                                             progress: progress)
        assert(url: url, pathExtension: .m4a)
        assert(url: url, trackCount: 1)
        // The scaled video should be approximately 1/3 the length of the original
        assert(url: url, duration: asset.duration.seconds * multiplier, accuracy: 0.1)
        assertCompletedProgress()
    }
}

// MARK: Video include audio

extension ScaleAssetTests {
    func testScaleAssetSlowIncludeAudio() async throws {
        let asset = try loadAsset(testData: .videoWithAudio)
        let multiplier: Float64 = 3.0

        let url = try await scaleAsset.scale(asset: asset,
                                             multiplier: multiplier,
                                             isAudioIncluded: true,
                                             mediaType: .video,
                                             progress: progress)
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: 2)
        // The scaled video should be approximately 3x the length of the original
        assert(url: url, duration: asset.duration.seconds * multiplier, accuracy: 0.25)
        assertCompletedProgress()
    }

    func testScaleAssetFastIncludeAudio() async throws {
        let asset = try loadAsset(testData: .videoWithAudio)
        let multiplier: Float64 = 0.33333

        let url = try await scaleAsset.scale(asset: asset,
                                             multiplier: multiplier,
                                             isAudioIncluded: true,
                                             mediaType: .video,
                                             progress: progress)
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: 2)
        // The scaled video should be approximately 1/3 the length of the original
        assert(url: url, duration: asset.duration.seconds * multiplier, accuracy: 0.1)
        assertCompletedProgress()
    }
}

// MARK: Video exclude audio

extension ScaleAssetTests {
    func testScaleAssetSlowExcludeAudio() async throws {
        let asset = try loadAsset(testData: .videoWithAudio)
        let multiplier: Float64 = 3.0

        let url = try await scaleAsset.scale(asset: asset,
                                             multiplier: multiplier,
                                             isAudioIncluded: false,
                                             mediaType: .video,
                                             progress: progress)
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: 1)
        // The scaled video should be approximately 3x the length of the original
        assert(url: url, duration: asset.duration.seconds * multiplier, accuracy: 0.25)
        assertCompletedProgress()
    }

    func testScaleAssetFastExcludeAudio() async throws {
        let asset = try loadAsset(testData: .videoWithAudio)
        let multiplier: Float64 = 0.33333

        let url = try await scaleAsset.scale(asset: asset,
                                             multiplier: multiplier,
                                             isAudioIncluded: false,
                                             mediaType: .video,
                                             progress: progress)
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: 1)
        // The scaled video should be approximately 1/3 the length of the original
        assert(url: url, duration: asset.duration.seconds * multiplier, accuracy: 0.1)
        assertCompletedProgress()
    }
}
