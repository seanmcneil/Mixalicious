
import AVFoundation

@testable import Mixalicious

final class MockExportSession: AssetExportSessionProtocol {
    var mockStatus: AVAssetExportSession.Status = .unknown
    var mockDelay: Double = 0.0

    private var mockProgress: Float = 0.0
    private var mockError: Error?

    var outputFileType: AVFileType?

    var outputURL: URL?

    var status: AVAssetExportSession.Status {
        mockStatus
    }

    var error: Error? {
        mockError
    }

    var progress: Float {
        mockProgress
    }

    func exportAsynchronously(completionHandler handler: @escaping () -> Void) {
        mockProgress = 0.0
        if mockStatus != .completed {
            mockError = mockStatus.mixaliciousError
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + mockDelay) {
            self.mockProgress = 1.0
            handler()
        }
    }
}
