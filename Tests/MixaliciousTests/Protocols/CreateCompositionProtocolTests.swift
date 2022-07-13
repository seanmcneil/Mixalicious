
import AVFoundation
import XCTest

@testable import Mixalicious

private class CreateComposition: CreateCompositionProtocol {}

final class CreateCompositionProtocolTests: XCTestCase, TestSupport {
    private let createComposition = CreateComposition()

    override func tearDown() {
        removeFiles()
    }

    func testCreateCompositionMissingAudio() async throws {
        let asset = AVMutableComposition()
        let composition = AVMutableComposition()

        do {
            _ = try await createComposition.createCompositionTrack(mediaType: .audio,
                                                                   asset: asset,
                                                                   composition: composition)
            assertExpectedError()
        } catch let error as MixaliciousError {
            XCTAssertEqual(error, MixaliciousError.failedToCreateAudioTrack)
        }
    }

    func testCreateCompositionMissingVideo() async throws {
        let asset = AVMutableComposition()
        let composition = AVMutableComposition()

        do {
            _ = try await createComposition.createCompositionTrack(mediaType: .video,
                                                                   asset: asset,
                                                                   composition: composition)
            assertExpectedError()
        } catch let error as MixaliciousError {
            XCTAssertEqual(error, MixaliciousError.failedToCreateVideoTrack)
        }
    }
}
