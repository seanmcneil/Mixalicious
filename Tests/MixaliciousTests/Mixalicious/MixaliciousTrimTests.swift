
import AVFoundation
import XCTest

@testable import Mixalicious

final class MixaliciousTrimTests: XCTestCase, TestAssertions {
    private let mixalicious = Mixalicious()

    var fractionCompleted: Double {
        mixalicious.completionPercent
    }

    override func tearDown() async throws {
        removeFiles()
    }
}

// MARK: Trim video

extension MixaliciousTrimTests {
    func testTrimVideoStartEnd() async throws {
        let asset = try loadAsset(testData: .videoWithAudio)

        assertInitialProgress()
        let url = try await mixalicious.trim(asset: asset,
                                             start: asset.midDuration.start,
                                             end: asset.midDuration.end)
        assertCompletedProgress()
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: 2)
        // The trimmed video should be approximately 50% the length of the original
        assert(url: url, duration: asset.duration.seconds / 2.0)
    }

    func testTrimVideoTimeRange() async throws {
        let asset = try loadAsset(testData: .videoWithAudio)

        assertInitialProgress()
        let url = try await mixalicious.trim(asset: asset,
                                             timeRange: asset.midDuration)
        assertCompletedProgress()
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: 2)
        // The trimmed video should be approximately 50% the length of the original
        assert(url: url, duration: asset.duration.seconds / 2.0)
    }
}

// MARK: Trim audio

extension MixaliciousTrimTests {
    func testTrimAudioStartEnd() async throws {
        let asset = try loadAsset(testData: .audio)

        assertInitialProgress()
        let url = try await mixalicious.trim(asset: asset,
                                             start: asset.midDuration.start,
                                             end: asset.midDuration.end)
        assertCompletedProgress()
        assert(url: url, pathExtension: .m4a)
        assert(url: url, trackCount: 1)
        // The trimmed video should be approximately 50% the length of the original
        assert(url: url, duration: asset.duration.seconds / 2.0)
    }

    func testTrimAudioTimeRange() async throws {
        let asset = try loadAsset(testData: .audio)

        assertInitialProgress()
        let url = try await mixalicious.trim(asset: asset,
                                             timeRange: asset.midDuration)
        assertCompletedProgress()
        assert(url: url, pathExtension: .m4a)
        assert(url: url, trackCount: 1)
        // The trimmed video should be approximately 50% the length of the original
        assert(url: url, duration: asset.duration.seconds / 2.0)
    }

    func testTrimWithAssetTrackEmpty() async throws {
        let asset = AVMutableComposition()
        let timeRange = CMTimeRange(start: .zero,
                                    end: .zero)

        assertInitialProgress()
        do {
            _ = try await mixalicious.trim(asset: asset,
                                           timeRange: timeRange)
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error, expected: .unknownFileType)
        }
    }
}

// MARK: Invalid time range

extension MixaliciousTrimTests {
    func testInsertWithNegativeInsertionTime() async throws {
        let asset = try loadAsset(testData: .videoNoAudio)
        let start = CMTime(value: -1, timescale: asset.duration.timescale)
        let timeRange = CMTimeRange(start: start,
                                    end: asset.timeRange.end)

        assertInitialProgress()
        do {
            _ = try await mixalicious.trim(asset: asset,
                                           timeRange: timeRange)
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error, expected: .invalidInsertionTime)
        }
    }

    func testInsertWithInvalidInsertionTimeOrder() async throws {
        let asset = try loadAsset(testData: .videoNoAudio)
        let end = CMTime(value: 1, timescale: asset.duration.timescale)

        assertInitialProgress()
        do {
            _ = try await mixalicious.trim(asset: asset,
                                           start: end,
                                           end: .zero)
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error, expected: .invalidStartEndTimeOrder)
        }
    }

    func testInsertWithExtendedInsertionTime() async throws {
        let asset = try loadAsset(testData: .videoNoAudio)
        let endTime = CMTime(value: 100,
                             timescale: asset.duration.timescale)
        let end = CMTimeAdd(asset.timeRange.end, endTime)
        let timeRange = CMTimeRange(start: .zero,
                                    end: end)

        assertInitialProgress()
        do {
            _ = try await mixalicious.trim(asset: asset,
                                           timeRange: timeRange)
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error, expected: .invalidInsertionTime)
        }
    }
}
