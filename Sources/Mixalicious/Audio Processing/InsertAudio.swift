import AVFoundation
import Combine

final class InsertAudio {
    /// Supports sink usage with write operation
    var cancelleables = Set<AnyCancellable>()

    deinit {
        cancelleables.forEach { cancelleable in
            cancelleable.cancel()
        }
    }

    /// Adds the given audio asset to an existing video asset's audio track
    ///
    /// - Note: Video is not mutated
    /// - Note: Precondition validates initialization values
    ///
    /// - Parameters:
    ///   - audio: AVAsset containing audio to combine
    ///   - video: AVAsset containing video to target
    ///   - insertionTime: CMTime representing the point to insert audio asset into video
    ///   - progress: Progress for updates on writing output
    func insert(to target: AVAsset,
                with audio: AVAsset,
                mediaType: MediaType,
                insertionTime: CMTime = .zero,
                progress: Progress) -> AnyPublisher<URL, MixaliciousError> {
        precondition(audio.isAudioOnly)
        precondition(insertionTime >= .zero)
        precondition(insertionTime <= target.timeRange.end)

        let composition = AVMutableComposition()
        var publishers = [AnyPublisher<AVMutableComposition, MixaliciousError>]()

        if target.hasVideoTrack {
            let videoTrack = createCompositionTrack(mediaType: .video,
                                                    asset: target,
                                                    composition: composition)
            publishers.append(videoTrack)
        }

        if target.hasAudioTrack {
            let sourceAudioTrack = createCompositionTrack(mediaType: .audio,
                                                          asset: target,
                                                          composition: composition)
            publishers.append(sourceAudioTrack)
        }

        let timeRange = CMTimeRangeMake(start: .zero,
                                        duration: audio.duration)

        let mergeAudioTrack = createCompositionTrack(mediaType: .audio,
                                                     asset: audio,
                                                     timeRange: timeRange,
                                                     insertionTime: insertionTime,
                                                     composition: composition)
        publishers.append(mergeAudioTrack)

        return Publishers.MergeMany(publishers)
            .flatMap { [weak self] mergedComposition -> AnyPublisher<URL, MixaliciousError> in
                guard let strongSelf = self else {
                    return Fail(error: .outOfScope)
                        .eraseToAnyPublisher()
                }

                return strongSelf.write(asset: mergedComposition,
                                        mediaType: mediaType,
                                        progress: progress)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

extension InsertAudio: AudioProcessingProtocol {}
