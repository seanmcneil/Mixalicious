@testable import Mixalicious

import AVFoundation
import Combine
import XCTest

final class SessionWriterTests: XCTestCase {
    private let sessionWriter = SessionWriter()

    private var cancelleables = Set<AnyCancellable>()

    func testCancelledError() {
        let session = MockExportSession()
        session.mockStatus = .cancelled
        let mediaType = MediaType.audio
        let outputURL = URL(mediaType: mediaType)!
        let progress = Progress()

        let expect = expectation(description: "expect")

        sessionWriter.export(session: session,
                             mediaType: mediaType,
                             outputURL: outputURL,
                             progress: progress)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case let .failure(error):
                    switch error {
                    case .exportCancelled:
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

    func testExportingError() {
        let session = MockExportSession()
        session.mockStatus = .exporting
        let mediaType = MediaType.audio
        let outputURL = URL(mediaType: mediaType)!
        let progress = Progress()

        let expect = expectation(description: "expect")

        sessionWriter.export(session: session,
                             mediaType: mediaType,
                             outputURL: outputURL,
                             progress: progress)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case let .failure(error):
                    switch error {
                    case .exportExporting:
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

    func testFailedError() {
        let session = MockExportSession()
        session.mockStatus = .failed
        let mediaType = MediaType.audio
        let outputURL = URL(mediaType: mediaType)!
        let progress = Progress()

        let expect = expectation(description: "expect")

        sessionWriter.export(session: session,
                             mediaType: mediaType,
                             outputURL: outputURL,
                             progress: progress)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case let .failure(error):
                    switch error {
                    case .exportFailed:
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

    func testUnknownError() {
        let session = MockExportSession()
        session.mockStatus = .unknown
        let mediaType = MediaType.audio
        let outputURL = URL(mediaType: mediaType)!
        let progress = Progress()

        let expect = expectation(description: "expect")

        sessionWriter.export(session: session,
                             mediaType: mediaType,
                             outputURL: outputURL,
                             progress: progress)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case let .failure(error):
                    switch error {
                    case .exportUnknown:
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

    func testWaitingError() {
        let session = MockExportSession()
        session.mockStatus = .waiting
        let mediaType = MediaType.audio
        let outputURL = URL(mediaType: mediaType)!
        let progress = Progress()

        let expect = expectation(description: "expect")

        sessionWriter.export(session: session,
                             mediaType: mediaType,
                             outputURL: outputURL,
                             progress: progress)
            .sink(receiveCompletion: { subscribers in
                switch subscribers {
                case let .failure(error):
                    switch error {
                    case .exportWaiting:
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
