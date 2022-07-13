
import AVFoundation
import XCTest

@testable import Mixalicious

final class MixaliciousScaleTests: XCTestCase, TestAssertions {
    private let mixalicious = Mixalicious()

    var fractionCompleted: Double {
        mixalicious.completionPercent
    }

    override func tearDown() async throws {
        removeFiles()
    }
}

// MARK: Scale audio

extension MixaliciousScaleTests {
    func testScaleAudioSlow() async throws {
        let asset = try loadAsset(testData: .audio)
        let multiplier: Float64 = 3.0

        assertInitialProgress()
        let url = try await mixalicious.scaleAudio(asset: asset,
                                                   multiplier: multiplier)
        assertCompletedProgress()
        assert(url: url, pathExtension: .m4a)
        assert(url: url, trackCount: 1)
        // The scaled video should be approximately 3x the length of the original
        assert(url: url, duration: asset.duration.seconds * multiplier, accuracy: 0.25)
    }

    func testScaleAudioFromVideoAsset() async throws {
        let asset = try loadAsset(testData: .videoWithAudio)
        let multiplier: Float64 = 3.0

        assertInitialProgress()
        let url = try await mixalicious.scaleAudio(asset: asset,
                                                   multiplier: multiplier)
        assertCompletedProgress()
        assert(url: url, pathExtension: .m4a)
        assert(url: url, trackCount: 1)
        // The scaled video should be approximately 3x the length of the original
        assert(url: url, duration: asset.duration.seconds * multiplier, accuracy: 0.25)
    }

    func testScaleAudioInvalidAsset() async throws {
        let multiplier: Float64 = 3.0

        assertInitialProgress()
        do {
            _ = try await mixalicious.scaleAudio(asset: AVComposition(),
                                                 multiplier: multiplier)
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error, expected: .audioTrackNotFound)
        }
    }
}

// MARK: Scale video

extension MixaliciousScaleTests {
    func testScaleVideoWithAudioSlow() async throws {
        let asset = try loadAsset(testData: .videoWithAudio)
        let multiplier: Float64 = 3.0

        assertInitialProgress()
        let url = try await mixalicious.scaleVideo(asset: asset,
                                                   multiplier: multiplier,
                                                   isAudioIncluded: true)
        assertCompletedProgress()
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: 2)
        // The scaled video should be approximately 3x the length of the original
        assert(url: url, duration: asset.duration.seconds * multiplier, accuracy: 0.25)
    }

    func testScaleVideoNoAudioSlow() async throws {
        let asset = try loadAsset(testData: .videoNoAudio)
        let multiplier: Float64 = 3.0

        assertInitialProgress()
        let url = try await mixalicious.scaleVideo(asset: asset,
                                                   multiplier: multiplier,
                                                   isAudioIncluded: false)
        assertCompletedProgress()
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: 1)
        // The scaled video should be approximately 3x the length of the original
        assert(url: url, duration: asset.duration.seconds * multiplier, accuracy: 0.25)
    }

    func testScaleVideoNoAudioFail() async throws {
        let asset = try loadAsset(testData: .videoNoAudio)
        let multiplier: Float64 = 3.0

        assertInitialProgress()
        do {
            _ = try await mixalicious.scaleVideo(asset: asset,
                                                 multiplier: multiplier,
                                                 isAudioIncluded: true)
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error, expected: .audioTrackNotFound)
        }
    }

    func testScaleVideoInvalidAsset() async throws {
        let asset = try loadAsset(testData: .audio)
        let multiplier: Float64 = 3.0

        assertInitialProgress()
        do {
            _ = try await mixalicious.scaleVideo(asset: asset,
                                                 multiplier: multiplier,
                                                 isAudioIncluded: true)
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error, expected: .videoTrackNotFound)
        }
    }
}
