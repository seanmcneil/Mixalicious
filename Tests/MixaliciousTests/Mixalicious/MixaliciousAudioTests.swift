@testable import Mixalicious

import AVFoundation
import Combine
import XCTest

final class MixaliciousAudioTests: XCTestCase {
    private var cancelleables = Set<AnyCancellable>()

    private let mixalicious = Mixalicious()

    override func tearDown() {
        URL.removeAllFiles(mediaType: .audio)
        URL.removeAllFiles(mediaType: .video)
    }

    func testInsertAudioAtVideoStart() {
        let expect = expectation(description: "expect")

        guard let videoURL = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        guard let audioURL = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let audio = AVURLAsset(url: audioURL)
        let video = AVURLAsset(url: videoURL)

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.insert(audio: audio,
                           target: video)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case .failure:
                    XCTFail(ErrorMessage.unexpected)

                case .finished:
                    expect.fulfill()
                }
            }) { [unowned self] url in
                XCTAssertEqual(url.pathExtension, "mp4")
                let asset = AVURLAsset(url: url)
                XCTAssertEqual(asset.tracks.count, 3)
                XCTAssertEqual(self.mixalicious.completionPercent,
                               1.0,
                               accuracy: 0.01)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // This test inserts audio at the start of a video that has no audio track
    func testInsertAudioAtMuteVideoStart() {
        let expect = expectation(description: "expect")

        guard let videoURL = loadTestAsset(name: FileName.videoOnly) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        guard let audioURL = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let audio = AVURLAsset(url: audioURL)
        let video = AVURLAsset(url: videoURL)

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.insert(audio: audio,
                           target: video)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case .failure:
                    XCTFail(ErrorMessage.unexpected)

                case .finished:
                    expect.fulfill()
                }
            }) { [unowned self] url in
                XCTAssertEqual(url.pathExtension, "mp4")
                let asset = AVURLAsset(url: url)
                XCTAssertEqual(asset.tracks.count, 2)
                XCTAssertEqual(self.mixalicious.completionPercent,
                               1.0,
                               accuracy: 0.01)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testInsertAudioIntoAudio() {
        let expect = expectation(description: "expect")

        guard let audioURL = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let audio = AVURLAsset(url: audioURL)
        let audioTarget = AVURLAsset(url: audioURL)

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.insert(audio: audio,
                           target: audioTarget)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case .failure:
                    XCTFail(ErrorMessage.unexpected)

                case .finished:
                    expect.fulfill()
                }
            }) { [unowned self] url in
                XCTAssertEqual(url.pathExtension, "m4a")
                let asset = AVURLAsset(url: url)
                XCTAssertEqual(asset.tracks.count, 1)
                XCTAssertEqual(self.mixalicious.completionPercent,
                               1.0,
                               accuracy: 0.01)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testInsertWithWrongAsset() {
        let expect = expectation(description: "expect")

        guard let videoURL = loadTestAsset(name: FileName.videoOnly) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let video = AVURLAsset(url: videoURL)

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.insert(audio: video,
                           target: video)
            .sink(receiveCompletion: { [unowned self] subscribers in
                switch subscribers {
                case let .failure(error):
                    switch error {
                    case .audioTrackNotFound:
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

    func testInsertWithUnknownAsset() {
        let expect = expectation(description: "expect")

        let audio = AVMutableComposition()
        let target = AVMutableComposition()

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.insert(audio: audio,
                           target: target)
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

    func testInsertWithNegativeInsertionTime() {
        let expect = expectation(description: "expect")

        guard let videoURL = loadTestAsset(name: FileName.videoOnly) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        guard let audioURL = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let audio = AVURLAsset(url: audioURL)
        let video = AVURLAsset(url: videoURL)
        let insertionTime = CMTime(value: -1, timescale: 600)

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.insert(audio: audio,
                           target: video,
                           insertionTime: insertionTime)
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

        guard let videoURL = loadTestAsset(name: FileName.videoOnly) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        guard let audioURL = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let audio = AVURLAsset(url: audioURL)
        let video = AVURLAsset(url: videoURL)
        let insertionTime = CMTimeAdd(video.duration, CMTime(value: 1, timescale: video.duration.timescale))

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.insert(audio: audio,
                           target: video,
                           insertionTime: insertionTime)
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

    // MARK: Combine audio

    func testCombineAudio() {
        let expect = expectation(description: "expect")
        guard let videoURL = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        guard let audioURL = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let audio = AVURLAsset(url: audioURL)
        let video = AVURLAsset(url: videoURL)
        let timescale = video.duration.timescale
        let value = Int64(timescale / Int32(2))
        let insertionTime: CMTime = CMTimeMake(value: value,
                                               timescale: timescale)

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.insert(audio: audio,
                           target: video,
                           insertionTime: insertionTime)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case .failure:
                    XCTFail(ErrorMessage.unexpected)

                case .finished:
                    expect.fulfill()
                }
            }) { [unowned self] url in
                XCTAssertEqual(url.pathExtension, "mp4")
                let asset = AVURLAsset(url: url)
                XCTAssertEqual(asset.tracks.count, 3)
                XCTAssertEqual(self.mixalicious.completionPercent,
                               1.0,
                               accuracy: 0.01)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // MARK: Extract audio

    func testExtractAudio() {
        let expect = expectation(description: "expect")
        guard let assetURL = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let video = AVURLAsset(url: assetURL)

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.extractAudio(video: video)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case .failure:
                    XCTFail(ErrorMessage.unexpected)

                case .finished:
                    expect.fulfill()
                }
            }) { [unowned self] url in
                XCTAssertEqual(url.pathExtension, "m4a")
                let asset = AVURLAsset(url: url)
                XCTAssertEqual(asset.tracks.count, 1)
                XCTAssertEqual(self.mixalicious.completionPercent,
                               1.0,
                               accuracy: 0.01)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testExtractAudioFailNoAudio() {
        let expect = expectation(description: "expect")
        guard let assetURL = loadTestAsset(name: FileName.videoOnly) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let video = AVURLAsset(url: assetURL)

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.extractAudio(video: video)
            .sink(receiveCompletion: { [unowned self] subscribers in
                switch subscribers {
                case let .failure(error):
                    switch error {
                    case .videoTrackNotFound:
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
