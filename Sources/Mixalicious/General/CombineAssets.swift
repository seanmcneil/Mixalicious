import AVFoundation

final class CombineAssets {
    /// Connects the provided [AVAsset] together to form a single audio or video file
    ///
    /// - Note: Assets are not mutated
    /// - Note: Precondition validates initialization values
    ///
    /// - Parameters:
    ///   - assets: [AVAsset] that are connected in order to form a single asset
    ///   - mediaType: File type to export
    ///   - progress: Progress used to track export process
    /// - Returns: Either the URL of the combined asset, or an error if the operation failed
    func combine(assets: [AVAsset],
                 mediaType: MediaType,
                 progress: Progress) async throws -> URL {
        precondition(!assets.isEmpty)

        let composition = AVMutableComposition()
        var insertionTime: CMTime = .zero

        for asset in assets {
            let timeRange = CMTimeRange(start: .zero,
                                        duration: asset.duration)
            try? composition.insertTimeRange(timeRange,
                                             of: asset,
                                             at: insertionTime)

            insertionTime = CMTimeAdd(insertionTime,
                                      asset.duration)
        }

        return try await write(asset: composition,
                               mediaType: mediaType,
                               progress: progress)
    }
}

extension CombineAssets: WriteAssetProtocol {}
