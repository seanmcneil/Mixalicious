
import AVFoundation
import XCTest

@testable import Mixalicious

final class SessionWriterTests: XCTestCase, TestAssertions {
    private var progress: Progress!

    var fractionCompleted: Double {
        progress.fractionCompleted
    }

    override func tearDown() async throws {
        removeFiles()
    }

    override func setUp() async throws {
        progress = Progress(totalUnitCount: 1000)
        session = MockExportSession()
    }

    private let sessionWriter = SessionWriter()

    private let outputURL = URL(mediaType: .audio)!

    private var session: MockExportSession!
}

extension SessionWriterTests {
    func testCancelledError() async throws {
        session.mockStatus = .cancelled

        do {
            _ = try await sessionWriter.export(session: session,
                                               outputURL: outputURL,
                                               progress: progress)
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error,
                   expected: .exportCancelled,
                   isCompletedProgress: false)
        }
    }

    func testExportingError() async throws {
        session.mockStatus = .exporting

        do {
            _ = try await sessionWriter.export(session: session,
                                               outputURL: outputURL,
                                               progress: progress)
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error,
                   expected: .exportExporting,
                   isCompletedProgress: false)
        }
    }

    func testFailedError() async throws {
        session.mockStatus = .failed

        do {
            _ = try await sessionWriter.export(session: session,
                                               outputURL: outputURL,
                                               progress: progress)
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error,
                   expected: .exportFailed,
                   isCompletedProgress: false)
        }
    }

    func testUnknownError() async throws {
        session.mockStatus = .unknown

        do {
            _ = try await sessionWriter.export(session: session,
                                               outputURL: outputURL,
                                               progress: progress)
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error,
                   expected: .exportUnknown,
                   isCompletedProgress: false)
        }
    }

    func testWaitingError() async throws {
        session.mockStatus = .waiting

        do {
            _ = try await sessionWriter.export(session: session,
                                               outputURL: outputURL,
                                               progress: progress)
            assertExpectedError()
        } catch let error as MixaliciousError {
            assert(error: error,
                   expected: .exportWaiting,
                   isCompletedProgress: false)
        }
    }
}
