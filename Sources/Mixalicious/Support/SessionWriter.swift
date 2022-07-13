import AVFoundation
import Foundation

final class SessionWriter {
    /// Carries out the export operation and updates progress
    ///
    /// The `mediaType` property is to support future functionality
    ///
    /// - Parameters:
    ///   - session: ExportSession performing write
    ///   - outputURL: URL for where to write output
    ///   - progress: Progress used to track export process
    /// - Returns: URL for exported asset, or error if process failed
    func export(session: AssetExportSessionProtocol,
                outputURL: URL,
                progress: Progress) async throws -> URL {
        let totalUnitCount = progress.totalUnitCount
        // This timer is responsible for updating the progress object
        Timer.scheduledTimer(withTimeInterval: 0.1,
                             repeats: true) { _ in
            // Multiply session.progress by totalUnitCount to scale from 0-1 to 0-totalUnitCount
            // Then cast this float value to Int64 for updating completedUnitCount
            let completedUnitCount = Int64(session.progress * Float(totalUnitCount))
            progress.completedUnitCount = completedUnitCount
        }

        try? FileManager.default.removeItem(at: outputURL)

        return try await withCheckedThrowingContinuation { continuation in
            session.exportAsynchronously {
                assert(!Thread.isMainThread)

                switch session.status {
                case .completed:
                    progress.completedUnitCount = totalUnitCount
                    continuation.resume(returning: outputURL)

                default:
                    progress.reset()
                    continuation.resume(throwing: session.status.mixaliciousError)
                }
            }
        }
    }
}
