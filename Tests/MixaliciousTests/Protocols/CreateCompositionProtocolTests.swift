@testable import Mixalicious

import AVFoundation
import Combine
import XCTest

private class CreateComposition: CreateCompositionProtocol {}

final class CreateCompositionProtocolTests: XCTestCase {
    private var cancelleables = Set<AnyCancellable>()

    override func tearDown() {
        URL.removeAllFiles(mediaType: .audio)
        URL.removeAllFiles(mediaType: .video)
    }

    func testCreateCompositionMissingAudio() {
        let createComposition = CreateComposition()
        let mediaType = MediaType.audio
        let asset = AVMutableComposition()
        let composition = AVMutableComposition()
        let expect = expectation(description: "expect")

        createComposition.createCompositionTrack(mediaType: mediaType,
                                                 asset: asset,
                                                 composition: composition)
            .sink(receiveCompletion: { subscriber in
                switch subscriber {
                case let .failure(error):
                    switch error {
                    case .failedToCreateAudioTrack:
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

    func testCreateCompositionMissingVideo() {
        let createComposition = CreateComposition()
        let mediaType = MediaType.video
        let asset = AVMutableComposition()
        let composition = AVMutableComposition()
        let expect = expectation(description: "expect")

        createComposition.createCompositionTrack(mediaType: mediaType,
                                                 asset: asset,
                                                 composition: composition)
            .sink(receiveCompletion: { subscriber in
                switch subscriber {
                case let .failure(error):
                    switch error {
                    case .failedToCreateVideoTrack:
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
