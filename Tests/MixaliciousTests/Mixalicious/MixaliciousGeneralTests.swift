@testable import Mixalicious

import AVFoundation
import Combine
import XCTest

final class MixaliciousGeneralTests: XCTestCase {
    private var cancelleables = Set<AnyCancellable>()

    private let mixalicious = Mixalicious()

    override func tearDown() {
        URL.removeAllFiles(mediaType: .audio)
        URL.removeAllFiles(mediaType: .video)
    }

    // MARK: Trim video

    func testTrimVideoStartEnd() {
        let expect = expectation(description: "expect")

        guard let url = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        // Calculate start time at 25% into asset
        let startTime = asset.duration.seconds * 0.25
        // Calculate start time at 75% into asset
        let endTime = asset.duration.seconds * 0.75
        // Create start & end times using video asset's timescale
        let start = CMTime(seconds: startTime,
                           preferredTimescale: asset.duration.timescale)
        let end = CMTime(seconds: endTime,
                         preferredTimescale: asset.duration.timescale)

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.trim(asset: asset,
                         start: start,
                         end: end)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case .failure:
                    XCTFail(ErrorMessage.unexpected)

                case .finished:
                    expect.fulfill()
                }
            }) { [unowned self] url in
                XCTAssertEqual(url.pathExtension, "mp4")
                let trimmedAsset = AVURLAsset(url: url)
                XCTAssertEqual(trimmedAsset.tracks.count, 2)
                // The trimmed video should be approximately 50% the length of the original
                XCTAssertEqual(trimmedAsset.duration.seconds,
                               asset.duration.seconds / 2.0,
                               accuracy: 0.01)
                XCTAssertEqual(self.mixalicious.completionPercent,
                               1.0,
                               accuracy: 0.01)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testTrimVideoTimeRange() {
        let expect = expectation(description: "expect")

        guard let url = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
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

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.trim(asset: asset,
                         timeRange: timeRange)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case .failure:
                    XCTFail(ErrorMessage.unexpected)

                case .finished:
                    expect.fulfill()
                }
            }) { [unowned self] url in
                XCTAssertEqual(url.pathExtension, "mp4")
                let trimmedAsset = AVURLAsset(url: url)
                XCTAssertEqual(trimmedAsset.tracks.count, 2)
                // The trimmed video should be approximately 50% the length of the original
                XCTAssertEqual(trimmedAsset.duration.seconds,
                               asset.duration.seconds / 2.0,
                               accuracy: 0.01)
                XCTAssertEqual(self.mixalicious.completionPercent,
                               1.0,
                               accuracy: 0.01)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // MARK: Trim audio

    func testTrimAudioStartEnd() {
        let expect = expectation(description: "expect")

        guard let url = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        // Calculate start time at 25% into asset
        let startTime = asset.duration.seconds * 0.25
        // Calculate start time at 75% into asset
        let endTime = asset.duration.seconds * 0.75
        // Create start & end times using video asset's timescale
        let start = CMTime(seconds: startTime,
                           preferredTimescale: asset.duration.timescale)
        let end = CMTime(seconds: endTime,
                         preferredTimescale: asset.duration.timescale)

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.trim(asset: asset,
                         start: start,
                         end: end)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case .failure:
                    XCTFail(ErrorMessage.unexpected)

                case .finished:
                    expect.fulfill()
                }
            }) { [unowned self] url in
                XCTAssertEqual(url.pathExtension, "m4a")
                let trimmedAsset = AVURLAsset(url: url)
                XCTAssertEqual(trimmedAsset.tracks.count, 1)
                // The trimmed video should be approximately 50% the length of the original
                XCTAssertEqual(trimmedAsset.duration.seconds,
                               asset.duration.seconds / 2.0,
                               accuracy: 0.01)
                XCTAssertEqual(self.mixalicious.completionPercent,
                               1.0,
                               accuracy: 0.01)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testTrimAudioTimeRange() {
        let expect = expectation(description: "expect")

        guard let url = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
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

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.trim(asset: asset,
                         timeRange: timeRange)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case .failure:
                    XCTFail(ErrorMessage.unexpected)

                case .finished:
                    expect.fulfill()
                }
            }) { [unowned self] url in
                XCTAssertEqual(url.pathExtension, "m4a")
                let trimmedAsset = AVURLAsset(url: url)
                XCTAssertEqual(trimmedAsset.tracks.count, 1)
                // The trimmed video should be approximately 50% the length of the original
                XCTAssertEqual(trimmedAsset.duration.seconds,
                               asset.duration.seconds / 2.0,
                               accuracy: 0.01)
                XCTAssertEqual(self.mixalicious.completionPercent,
                               1.0,
                               accuracy: 0.01)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testTrimWithAssetTrackEmpty() {
        let expect = expectation(description: "expect")

        let asset = AVMutableComposition()
        let timeRange = CMTimeRange(start: .zero,
                                    end: .zero)

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.trim(asset: asset,
                         timeRange: timeRange)
            .sink(receiveCompletion: { [unowned self] subscribers in
                switch subscribers {
                case let .failure(error):
                    switch error {
                    case .unknownFileType:
                        XCTAssertEqual(self.mixalicious.completionPercent,
                                       0.0,
                                       accuracy: 0.01)
                        expect.fulfill()

                    default:
                        XCTFail(ErrorMessage.wrong)
                    }

                case .finished:
                    XCTFail(ErrorMessage.expected)
                }
            }) { _ in
                XCTFail(ErrorMessage.expected)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // MARK: Invalid time range

    func testInsertWithNegativeInsertionTime() {
        let expect = expectation(description: "expect")

        guard let url = loadTestAsset(name: FileName.videoOnly) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        let start = CMTime(value: -1, timescale: asset.duration.timescale)
        let timeRange = CMTimeRange(start: start,
                                    end: asset.timeRange.end)

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.trim(asset: asset,
                         timeRange: timeRange)
            .sink(receiveCompletion: { [unowned self] subscribers in
                switch subscribers {
                case let .failure(error):
                    switch error {
                    case .invalidInsertionTime:
                        XCTAssertEqual(self.mixalicious.completionPercent,
                                       0.0,
                                       accuracy: 0.01)
                        expect.fulfill()

                    default:
                        XCTFail(ErrorMessage.wrong)
                    }

                case .finished:
                    XCTFail(ErrorMessage.expected)
                }
            }) { _ in
                XCTFail(ErrorMessage.expected)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testInsertWithExtendedInsertionTime() {
        let expect = expectation(description: "expect")

        guard let url = loadTestAsset(name: FileName.videoOnly) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let asset = AVURLAsset(url: url)
        let endTime = CMTime(value: 100,
                             timescale: asset.duration.timescale)
        let end = CMTimeAdd(asset.timeRange.end, endTime)
        let timeRange = CMTimeRange(start: .zero,
                                    end: end)

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.trim(asset: asset,
                         timeRange: timeRange)
            .sink(receiveCompletion: { [unowned self] subscribers in
                switch subscribers {
                case let .failure(error):
                    switch error {
                    case .invalidInsertionTime:
                        XCTAssertEqual(self.mixalicious.completionPercent,
                                       0.0,
                                       accuracy: 0.01)
                        expect.fulfill()

                    default:
                        XCTFail(ErrorMessage.wrong)
                    }

                case .finished:
                    XCTFail(ErrorMessage.expected)
                }
            }) { _ in
                XCTFail(ErrorMessage.expected)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
