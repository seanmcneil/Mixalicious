import AVFoundation
import XCTest

@testable import Mixalicious

final class MixaliciousAudioTests: XCTestCase, TestAssertions {
    private let mixalicious = Mixalicious()

    var fractionCompleted: Double {
        mixalicious.completionPercent
    }

    override func tearDown() {
        removeFiles()
    }
}

// MARK: Insertion tests

extension MixaliciousAudioTests {
    func testInsertAudioAtVideoStart() async throws {
        let audio = try loadAsset(testData: .audio)
        let video = try loadAsset(testData: .videoWithAudio)

        assertInitialProgress()
        let url = try await mixalicious.insert(audio: audio,
                                               target: video)
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: multipleAssetTracks)
        assertCompletedProgress()
    }

    func testInsertAudioAtMuteVideoStart() async throws {
        let audio = try loadAsset(testData: .audio)
        let video = try loadAsset(testData: .videoNoAudio)

        assertInitialProgress()
        let url = try await mixalicious.insert(audio: audio,
                                               target: video)
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: 2)
        assertCompletedProgress()
    }

    func testInsertAudioIntoAudio() async throws {
        let audio = try loadAsset(testData: .audio)
        let audioTarget = try loadAsset(testData: .audio)

        assertInitialProgress()
        let url = try await mixalicious.insert(audio: audio,
                                               target: audioTarget)
        assert(url: url, pathExtension: .m4a)
        assert(url: url, trackCount: 1)
        assertCompletedProgress()
    }

    func testInsertWithWrongAsset() async throws {
        let video = try loadAsset(testData: .videoWithAudio)

        assertInitialProgress()
        do {
            _ = try await mixalicious.insert(audio: video,
                                             target: video)
        } catch let error as MixaliciousError {
            assert(error: error, expected: .audioTrackNotFound)
        }
    }

    func testInsertWithUnknownAsset() async throws {
        let audio = AVMutableComposition()
        let target = AVMutableComposition()

        assertInitialProgress()

        do {
            _ = try await mixalicious.insert(audio: audio,
                                             target: target)
        } catch let error as MixaliciousError {
            assert(error: error, expected: .unknownFileType)
        }
    }

    func testInsertWithNegativeInsertionTime() async throws {
        let audio = try loadAsset(testData: .audio)
        let video = try loadAsset(testData: .videoWithAudio)
        let insertionTime = CMTime(value: -1, timescale: 600)

        assertInitialProgress()
        do {
            _ = try await mixalicious.insert(audio: audio,
                                             target: video,
                                             insertionTime: insertionTime)
        } catch let error as MixaliciousError {
            assert(error: error, expected: .invalidInsertionTime)
        }
    }

    func testInsertWithExtendedInsertionTime() async throws {
        let audio = try loadAsset(testData: .audio)
        let video = try loadAsset(testData: .videoWithAudio)
        let insertionTime = CMTimeAdd(video.duration,
                                      CMTime(value: 1, timescale: video.duration.timescale))

        assertInitialProgress()
        do {
            _ = try await mixalicious.insert(audio: audio,
                                             target: video,
                                             insertionTime: insertionTime)
        } catch let error as MixaliciousError {
            assert(error: error, expected: .invalidInsertionTime)
        }
    }
}

// MARK: Combine audio

extension MixaliciousAudioTests {
    func testLayerAudioIntoVideo() async throws {
        let audio = try loadAsset(testData: .audio)
        let video = try loadAsset(testData: .videoWithAudio)
        let timescale = video.duration.timescale
        let value = Int64(timescale / Int32(2))
        let insertionTime: CMTime = CMTimeMake(value: value,
                                               timescale: timescale)

        assertInitialProgress()
        let url = try await mixalicious.insert(audio: audio,
                                               target: video,
                                               insertionTime: insertionTime)
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: multipleAssetTracks)
        assertCompletedProgress()
    }
}

// MARK: Extract audio

extension MixaliciousAudioTests {
    func testExtractAudio() async throws {
        let video = try loadAsset(testData: .videoWithAudio)

        assertInitialProgress()
        let url = try await mixalicious.extractAudio(video: video)
        assert(url: url, pathExtension: .m4a)
        assert(url: url, trackCount: 1)
        assertCompletedProgress()
    }

    func testExtractAudioFailNoAudio() async throws {
        let video = try loadAsset(testData: .videoNoAudio)

        assertInitialProgress()
        do {
            _ = try await mixalicious.extractAudio(video: video)
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error, expected: .audioTrackNotFound)
        }
    }
}
