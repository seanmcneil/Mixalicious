
import AVFoundation
import XCTest

@testable import Mixalicious

final class InsertAudioTests: XCTestCase, TestAssertions {
    private let insertAudio = InsertAudio()

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
    func testInsertAudioIntoVideo() async throws {
        let video = try loadAsset(testData: .videoWithAudio)
        let audio = try loadAsset(testData: .audio)
        let timescale = video.duration.timescale
        let value = Int64(timescale / Int32(2))
        let insertionTime: CMTime = CMTimeMake(value: value, timescale: timescale)

        let url = try await insertAudio.insert(to: video,
                                               with: audio,
                                               mediaType: .video,
                                               insertionTime: insertionTime,
                                               progress: progress)
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: multipleAssetTracks)
        assertCompletedProgress()
    }

    func testInsertAudioIntoAudio() async throws {
        let audio = try loadAsset(testData: .audio)
        let timescale = audio.duration.timescale
        let value = Int64(timescale / Int32(2))
        let insertionTime: CMTime = CMTimeMake(value: value, timescale: timescale)

        let url = try await insertAudio.insert(to: audio,
                                               with: audio,
                                               mediaType: .audio,
                                               insertionTime: insertionTime,
                                               progress: progress)
        assert(url: url, pathExtension: .m4a)
        assert(url: url, trackCount: 1)
        assertCompletedProgress()
    }

    func testInsertAudioIntoUnknown() async throws {
        let audio = try loadAsset(testData: .audio)
        let asset = AVMutableComposition()

        let url = try await insertAudio.insert(to: asset,
                                               with: audio,
                                               mediaType: .video,
                                               insertionTime: .zero,
                                               progress: progress)
        assert(url: url, pathExtension: .mp4)
        assert(url: url, trackCount: 1)
        assertCompletedProgress()
    }
}
