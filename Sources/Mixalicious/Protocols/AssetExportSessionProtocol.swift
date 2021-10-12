import AVFoundation

protocol AssetExportSessionProtocol {
    var outputFileType: AVFileType? { get set }
    var outputURL: URL? { get set }
    var status: AVAssetExportSession.Status { get }
    var error: Error? { get }
    var progress: Float { get }

    func exportAsynchronously(completionHandler handler: @escaping () -> Void)
}

extension AVAssetExportSession: AssetExportSessionProtocol {}

extension AVAssetExportSession.Status {
    /// Provides a package specific error message associated with non-successful status value
    var mixaliciousError: MixaliciousError {
        switch self {
        case .cancelled:
            return .exportCancelled

        case .exporting:
            return .exportExporting

        case .failed:
            return .exportFailed

        case .waiting:
            return .exportWaiting

        case .unknown:
            return .exportUnknown

        default:
            fatalError("Unhandled session status")
        }
    }
}
