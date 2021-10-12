import AVFoundation
import Combine

final class CombineVideos {
    /// Supports sink usage with write operation
    var cancelleables = Set<AnyCancellable>()

    deinit {
        cancelleables.forEach { cancelleable in
            cancelleable.cancel()
        }
    }

    /// Connects the provided AVAssets together to form a single video
    ///
    /// - Note: Videos are not mutated
    /// - Note: Precondition validates initialization values
    ///
    /// - Parameters:
    ///   - videos: [AVAsset] that are connected in order to form a single video
    ///   - progress: Progress used to track export process
    /// - Returns: Either the URL of the combined asset, or an error if the operation failed
    func combine(videos: [AVAsset],
                 progress: Progress) -> AnyPublisher<URL, MixaliciousError> {
        precondition(!videos.isEmpty)
        precondition(!videos.contains(where: { !$0.hasVideoTrack }))

        let composition = AVMutableComposition()
        var insertionTime = CMTime.zero

        for video in videos {
            let timeRange = CMTimeRange(start: .zero,
                                        duration: video.duration)
            try? composition.insertTimeRange(timeRange,
                                             of: video,
                                             at: insertionTime)

            insertionTime = CMTimeAdd(insertionTime,
                                      video.duration)
        }

        return write(asset: composition,
                     mediaType: .video,
                     progress: progress)
            .eraseToAnyPublisher()
    }
}

extension CombineVideos: WriteAssetProtocol {}
