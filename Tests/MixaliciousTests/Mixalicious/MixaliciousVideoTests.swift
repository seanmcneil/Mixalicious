@testable import Mixalicious

import AVFoundation
import Combine
import XCTest

final class MixaliciousVideoTests: XCTestCase {
    private var cancelleables = Set<AnyCancellable>()

    private let mixalicious = Mixalicious()

    override func tearDown() {
        URL.removeAllFiles(mediaType: .audio)
        URL.removeAllFiles(mediaType: .video)
    }

    // This test inserts audio at the start of a video that has no audio track
    func testCombineVideos() {
        let expect = expectation(description: "expect")

        guard let videoURL = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let video = AVURLAsset(url: videoURL)
        let videos = [video, video, video]

        let expectedDuration = video.duration.seconds * 3.0

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.combineVideos(videos: videos)
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
                XCTAssertEqual(asset.duration.seconds,
                               expectedDuration,
                               accuracy: 0.1)
                XCTAssertEqual(self.mixalicious.completionPercent,
                               1.0,
                               accuracy: 0.01)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testCombineVideosMixedArray() {
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
        mixalicious.combineVideos(videos: [audio, video])
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

    func testCombineVideosEmptyArray() {
        let expect = expectation(description: "expect")

        XCTAssertEqual(mixalicious.completionPercent,
                       0.0,
                       accuracy: 0.01)
        mixalicious.combineVideos(videos: [])
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
