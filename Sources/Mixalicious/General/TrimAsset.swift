import AVFoundation

final class TrimAsset {
    /// Trims the provided asset. This works for audio and video
    ///
    /// - Note: Asset is not mutated
    /// - Note: Precondition validates initialization values
    ///
    /// - Parameters:
    ///   - asset: AVAsset to trim. Can be audio or video
    ///   - timeRange: CMTimeRange for where to begin and end trimming of asset
    ///   - progress: Progress used to track export process
    /// - Returns: Either the URL of the trimmed asset, or an error if the operation failed
    func trim(asset: AVAsset,
              mediaType: MediaType,
              timeRange: CMTimeRange,
              progress: Progress) async throws -> URL {
        precondition(timeRange.start >= .zero)
        precondition(timeRange.end <= asset.timeRange.end)
        precondition(timeRange.start <= timeRange.end)

        return try await write(asset: asset,
                               mediaType: mediaType,
                               progress: progress,
                               timeRange: timeRange)
    }
}

extension TrimAsset: WriteAssetProtocol {}
