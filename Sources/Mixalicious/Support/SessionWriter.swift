import AVFoundation
import Combine
import Foundation

final class SessionWriter {
    /// Carries out the export operation and updates progress
    ///
    /// - Parameters:
    ///   - session: ExportSession performing write
    ///   - mediaType: MediaType to export
    ///   - outputURL: URL for where to write output
    ///   - progress: Progress used to track export process
    /// - Returns: URL for exported asset, or error if process failed
    func export(session: AssetExportSessionProtocol,
                mediaType _: MediaType,
                outputURL: URL,
                progress: Progress) -> AnyPublisher<URL, MixaliciousError> {
        let totalUnitCount = progress.totalUnitCount
        // This timer is responsible for updating the progress object
        Timer.scheduledTimer(withTimeInterval: 0.1,
                             repeats: true) { _ in
            // Multiply session.progress by totalUnitCount to scale from 0-1 to 0-totalUnitCount
            // Then cast this float value to Int64 for updating completedUnitCount
            let completedUnitCount = Int64(session.progress * Float(totalUnitCount))
            progress.completedUnitCount = completedUnitCount
        }

        return Future<URL, MixaliciousError> { promise in
            DispatchQueue.global(qos: .utility).async {
                // Safety check to ensure no file is present
                // Due to how names are generated, this is unlikely to occur
                try? FileManager.default.removeItem(at: outputURL)

                session.exportAsynchronously {
                    assert(!Thread.isMainThread)

                    switch session.status {
                    case .completed:
                        progress.completedUnitCount = totalUnitCount
                        promise(.success(outputURL))

                    default:
                        progress.reset()
                        promise(.failure(session.status.mixaliciousError))
                    }
                }
            }
        }
        .subscribe(on: DispatchQueue.global(qos: .default))
        .eraseToAnyPublisher()
    }
}
