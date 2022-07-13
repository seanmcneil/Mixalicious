
import AVFoundation
import XCTest

@testable import Mixalicious

final class MixaliciousCombineTests: XCTestCase, TestAssertions {
    private let mixalicious = Mixalicious()

    var fractionCompleted: Double {
        mixalicious.completionPercent
    }

    override func tearDown() async throws {
        removeFiles()
    }
}

// MARK: Combine audio

extension MixaliciousCombineTests {
    // This test inserts audio at the start of a video that has no audio track
    func testCombineAudio() async throws {
        let audio = try loadAsset(testData: .audio)
        let assets = [audio, audio, audio]
        let expectedDuration = audio.duration.seconds * 3.0

        assertInitialProgress()
        let url = try await mixalicious.combineAudio(assets: assets)
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

        let url = try await mixalicious.combineAudio(assets: assets)
        assert(url: url, pathExtension: .m4a)
        assert(url: url, trackCount: 1)
        assert(url: url, duration: duration, accuracy: 0.05)
        assertCompletedProgress()
    }

    func testCombineAudioAndNoAudioMixedArray() async throws {
        let video = try loadAsset(testData: .videoNoAudio)
        let audio = try loadAsset(testData: .audio)

        assertInitialProgress()

        do {
            _ = try await mixalicious.combineAudio(assets: [audio, video])
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error,
                   expected: .audioTrackNotFound)
        }
    }

    func testCombineAudioEmptyArray() async throws {
        assertInitialProgress()
        do {
            _ = try await mixalicious.combineAudio(assets: [])
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error,
                   expected: .assetsArrayIsEmpty)
        }
    }
}

// MARK: Combine video

extension MixaliciousCombineTests {
    // This test inserts audio at the start of a video that has no audio track
    func testCombineVideo() async throws {
        let video = try loadAsset(testData: .videoWithAudio)
        let assets = [video, video, video]
        let expectedDuration = video.duration.seconds * 3.0

        assertInitialProgress()
        let url = try await mixalicious.combineVideo(assets: assets)
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: 2)
        assert(url: url, duration: expectedDuration, accuracy: 0.05)
        assertCompletedProgress()
    }

    func testCombineVideoMixedArray() async throws {
        let video = try loadAsset(testData: .videoNoAudio)
        let audio = try loadAsset(testData: .audio)

        assertInitialProgress()
        do {
            _ = try await mixalicious.combineVideo(assets: [audio, video])
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error, expected: .videoTrackNotFound)
        }
    }

    func testCombineVideoEmptyArray() async throws {
        assertInitialProgress()
        do {
            _ = try await mixalicious.combineVideo(assets: [])
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error,
                   expected: .assetsArrayIsEmpty)
        }
    }
}
