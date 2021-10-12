@testable import Mixalicious

import XCTest

import AVFoundation
import Combine

final class TrimAssetTests: XCTestCase {
    private var cancelleables = Set<AnyCancellable>()

    override func tearDown() {
        URL.removeAllFiles(mediaType: .audio)
        URL.removeAllFiles(mediaType: .video)
    }

    func testTrimAudioTimeRange() {
        let trimAsset = TrimAsset()
        let expect = expectation(description: "expect")

        guard let url = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        let progress = Progress(totalUnitCount: 1000)
        // Calculate start time at 25% into asset
        let startTime = asset.duration.seconds * 0.25
        // Calculate start time at 75% into asset
        let endTime = asset.duration.seconds * 0.75
        // Create start & end times using video asset's timescale
        let start = CMTime(seconds: startTime,
                           preferredTimescale: asset.duration.timescale)
        let end = CMTime(seconds: endTime,
                         preferredTimescale: asset.duration.timescale)
        let timeRange = CMTimeRange(start: start,
                                    end: end)

        trimAsset.trim(asset: asset,
                       mediaType: .audio,
                       timeRange: timeRange,
                       progress: progress)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case .failure:
                    XCTFail(ErrorMessage.unexpected)

                case .finished:
                    expect.fulfill()
                }
            }) { url in
                XCTAssertEqual(url.pathExtension, "m4a")
                let trimmedAsset = AVURLAsset(url: url)
                XCTAssertEqual(trimmedAsset.tracks.count, 1)
                // The trimmed video should be approximately 50% the length of the original
                XCTAssertEqual(trimmedAsset.duration.seconds,
                               asset.duration.seconds / 2.0,
                               accuracy: 0.01)
                XCTAssertEqual(progress.fractionCompleted,
                               1.0,
                               accuracy: 0.01)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
