@testable import Mixalicious

import XCTest

import AVFoundation
import Combine

final class InsertAudioTests: XCTestCase {
    private var cancelleables = Set<AnyCancellable>()

    override func tearDown() {
        URL.removeAllFiles(mediaType: .audio)
        URL.removeAllFiles(mediaType: .video)
    }

    // Tests for the happy path using a video that contains an audio track
    func testInsertAudio() {
        guard let videoURL = loadTestAsset(name: FileName.video) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        guard let audioURL = loadTestAsset(name: FileName.audio) else {
            fatalError(ErrorMessage.failedToLoad)
        }

        let audio = AVURLAsset(url: audioURL)
        let video = AVURLAsset(url: videoURL)
        let progress = Progress(totalUnitCount: 1000)
        let timescale = video.duration.timescale
        let value = Int64(timescale / Int32(2))
        let insertionTime: CMTime = CMTimeMake(value: value, timescale: timescale)
        let insertAudio = InsertAudio()
        let expect = expectation(description: "expect")

        insertAudio.insert(to: video,
                           with: audio,
                           mediaType: .video,
                           insertionTime: insertionTime,
                           progress: progress)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case .failure:
                    XCTFail(ErrorMessage.unexpected)

                case .finished:
                    expect.fulfill()
                }
            }) { url in
                XCTAssertEqual(url.pathExtension, "mp4")
                let asset = AVURLAsset(url: url)
                XCTAssertEqual(asset.tracks.count, 3)
                XCTAssertEqual(progress.fractionCompleted,
                               1.0,
                               accuracy: 0.01)
            }
            .store(in: &cancelleables)

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
