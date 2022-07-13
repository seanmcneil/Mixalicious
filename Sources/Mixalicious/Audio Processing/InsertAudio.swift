import AVFoundation

final class InsertAudio {
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
                progress: Progress) async throws -> URL {
        precondition(audio.isAudioOnly)
        precondition(insertionTime >= .zero)
        precondition(insertionTime <= target.timeRange.end)

        let composition = AVMutableComposition()

        if target.hasVideoTrack {
            try await createCompositionTrack(mediaType: .video,
                                             asset: target,
                                             composition: composition)
        }

        if target.hasAudioTrack {
            try await createCompositionTrack(mediaType: .audio,
                                             asset: target,
                                             composition: composition)
        }

        let timeRange = CMTimeRange(duration: audio.duration)

        let mergeAudioTrack = try await createCompositionTrack(mediaType: .audio,
                                                               asset: audio,
                                                               timeRange: timeRange,
                                                               insertionTime: insertionTime,
                                                               composition: composition)

        return try await write(asset: mergeAudioTrack,
                               mediaType: mediaType,
                               progress: progress)
    }
}

extension InsertAudio: AudioProcessingProtocol {}
