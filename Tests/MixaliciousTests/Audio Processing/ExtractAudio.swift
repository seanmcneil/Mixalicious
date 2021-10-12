@testable import Mixalicious

import XCTest

import AVFoundation
import Combine

final class ExtractAudioTests: XCTestCase {
    private var cancelleables = Set<AnyCancellable>()

    override func tearDown() {
        URL.removeAllFiles(mediaType: .audio)
        URL.removeAllFiles(mediaType: .video)
    }

    // Tests for the happy path using a video that contains an audio track
    func testExtractAudio() {
        guard let assetURL = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let video = AVURLAsset(url: assetURL)
        let progress = Progress(totalUnitCount: 1000)
        let extractAudio = ExtractAudio()
        let expect = expectation(description: "expect")

        extractAudio.extract(video: video,
                             progress: progress)
            .sink(receiveCompletion: { subscriber in
                switch subscriber {
                case .failure:
                    XCTFail(ErrorMessage.unexpected)

                case .finished:
                    XCTAssertNotEqual(progress.completedUnitCount, 0)
                    expect.fulfill()
                }
            }) { url in
                XCTAssertEqual(url.pathExtension, "m4a")
                let asset = AVURLAsset(url: url)
                XCTAssertEqual(asset.tracks.count, 1)
                XCTAssertEqual(progress.fractionCompleted,
                               1.0,
                               accuracy: 0.01)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // Tests for a scenario where a video has no audio track. This will fail
    func testNoAudioExtractAudio() {
        guard let assetURL = loadTestAsset(name: FileName.videoOnly) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let video = AVURLAsset(url: assetURL)
        let progress = Progress(totalUnitCount: 1000)
        let extractAudio = ExtractAudio()
        let expect = expectation(description: "expect")

        extractAudio.extract(video: video,
                             progress: progress)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case let .failure(error):
                    switch error {
                    case .failedToCreateAudioTrack:
                        XCTAssertEqual(progress.fractionCompleted,
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
